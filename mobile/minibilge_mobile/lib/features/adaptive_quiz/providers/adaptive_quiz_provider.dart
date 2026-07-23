import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/adaptive_quiz_models.dart';
import '../models/adaptive_quiz_config.dart';
import '../services/adaptive_quiz_service.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../usage/services/daily_usage_service.dart';

// ── Kalan hak provider (autoDispose → her izlenmede taze veri) ───────────────

final adaptiveUsageStatusProvider = FutureProvider.autoDispose((ref) async {
  final childId = ref.watch(selectedChildProvider)?.id;
  if (childId == null) return null;
  return ref
      .read(dailyUsageServiceProvider)
      .getStatus(childId: childId, featureKey: adaptiveQuizUsageKey);
});

final remainingAttemptsProvider = FutureProvider.autoDispose<int>((ref) async {
  final status = await ref.watch(adaptiveUsageStatusProvider.future);
  return status?.remaining ?? 0;
});

// ── Zayıf Konu Provider ──────────────────────────────────────────────────────
// NOT autoDispose — navigasyon arasında cache'lenir, her açılışta API tetiklenmez

final weakTopicsProvider = FutureProvider<List<WeakTopicModel>>((ref) async {
  final child = ref.watch(selectedChildProvider);
  if (child == null) return [];
  final service = ref.read(adaptiveQuizServiceProvider);
  return service.getWeakTopics(child.id);
});

// ── Soru Üretim State ────────────────────────────────────────────────────────

class AdaptiveQuizState {
  final List<AdaptiveQuestionModel> questions;
  final int currentIndex;
  final bool isLoading;
  final String? error;
  final Map<String, String> answers;
  final AdaptiveQuizRewardModel? reward;
  final bool rewardLoading;
  final int remainingAttempts;
  final bool noAttemptsLeft;
  final String? currentTopicName;

  const AdaptiveQuizState({
    this.questions = const [],
    this.currentIndex = 0,
    this.isLoading = false,
    this.error,
    this.answers = const {},
    this.reward,
    this.rewardLoading = false,
    this.remainingAttempts = 3,
    this.noAttemptsLeft = false,
    this.currentTopicName,
  });

  AdaptiveQuizState copyWith({
    List<AdaptiveQuestionModel>? questions,
    int? currentIndex,
    bool? isLoading,
    String? error,
    Map<String, String>? answers,
    AdaptiveQuizRewardModel? reward,
    bool? rewardLoading,
    int? remainingAttempts,
    bool? noAttemptsLeft,
    String? currentTopicName,
    bool clearError = false,
  }) => AdaptiveQuizState(
    questions: questions ?? this.questions,
    currentIndex: currentIndex ?? this.currentIndex,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    answers: answers ?? this.answers,
    reward: reward ?? this.reward,
    rewardLoading: rewardLoading ?? this.rewardLoading,
    remainingAttempts: remainingAttempts ?? this.remainingAttempts,
    noAttemptsLeft: noAttemptsLeft ?? this.noAttemptsLeft,
    currentTopicName: currentTopicName ?? this.currentTopicName,
  );

  bool get isDone => currentIndex >= questions.length && questions.isNotEmpty;
  int get correctCount => answers.entries.where((e) {
    final q = questions.firstWhere(
      (q) => q.id == e.key,
      orElse: () => questions.first,
    );
    return q.correctAnswer == e.value;
  }).length;
}

class AdaptiveQuizNotifier extends StateNotifier<AdaptiveQuizState> {
  final AdaptiveQuizService _service;
  final DailyUsageService _usageService;
  final String? _childId;

  AdaptiveQuizNotifier(this._service, this._usageService, this._childId)
    : super(const AdaptiveQuizState());

  Future<void> loadFromConfig(AdaptiveQuizConfig config) async {
    // Hak kontrolü
    if (_childId == null) {
      state = state.copyWith(error: 'Profil seçilemedi.');
      return;
    }
    final usage = await _usageService.getStatus(
      childId: _childId,
      featureKey: adaptiveQuizUsageKey,
    );
    final remaining = usage.remaining;
    if (remaining <= 0) {
      state = state.copyWith(noAttemptsLeft: true, remainingAttempts: 0);
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      questions: [],
      currentIndex: 0,
      answers: {},
      reward: null,
      rewardLoading: false,
      noAttemptsLeft: false,
      currentTopicName: config.topicName,
    );
    try {
      final questions = await _service.generateQuestions(
        childId: _childId,
        topicName: config.topicName,
        subjectName: config.subjectName,
        gradeLevel: config.gradeLevel,
        difficulty: config.difficulty,
        englishLevel: config.englishLevel,
        count: 5,
      );
      // Hak tüket (sorular başarıyla gelince)
      final newRemaining = (remaining - 1).clamp(0, remaining);
      state = state.copyWith(
        questions: questions,
        isLoading: false,
        remainingAttempts: newRemaining,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadQuestions(WeakTopicModel topic, int gradeLevel) async {
    final config = AdaptiveQuizConfig(
      subjectName: topic.subjectName,
      levelDisplay: topic.englishLevel ?? topic.topicName,
      topicName: topic.topicName,
      gradeLevel: gradeLevel,
      difficulty: topic.suggestedDifficulty,
      englishLevel: topic.englishLevel,
    );
    return loadFromConfig(config);
  }

  Future<void> submitAnswer(String questionId, String answer) async {
    final newAnswers = Map<String, String>.from(state.answers)
      ..[questionId] = answer;
    state = state.copyWith(answers: newAnswers);
    try {
      if (_childId != null) {
        await _service.submitAnswer(
          childId: _childId,
          questionId: questionId,
          givenAnswer: answer,
        );
      }
    } catch (_) {}
  }

  void nextQuestion() {
    if (state.currentIndex < state.questions.length) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  /// Quiz bittikten sonra ödülleri alır.
  Future<void> fetchReward() async {
    if (_childId == null || state.rewardLoading || state.reward != null) return;
    state = state.copyWith(rewardLoading: true);
    try {
      final reward = await _service.awardQuiz(
        childId: _childId,
        correctCount: state.correctCount,
        totalCount: state.questions.length,
        topicName: state.currentTopicName ?? '',
      );
      state = state.copyWith(reward: reward, rewardLoading: false);
    } catch (_) {
      state = state.copyWith(rewardLoading: false);
    }
  }

  /// Reklam izleyince +1 hak ekle ve state güncelle.
  Future<void> addBonusAttempt() async {
    if (_childId == null) return;
    final usage = await _usageService.grantRewardedBonus(
      childId: _childId,
      featureKey: adaptiveQuizUsageKey,
    );
    state = state.copyWith(
      remainingAttempts: usage.remaining,
      noAttemptsLeft: usage.remaining <= 0,
    );
  }

  void reset() => state = const AdaptiveQuizState();
}

final adaptiveQuizProvider =
    StateNotifierProvider<AdaptiveQuizNotifier, AdaptiveQuizState>((ref) {
      final childId = ref.watch(selectedChildProvider)?.id;
      return AdaptiveQuizNotifier(
        ref.read(adaptiveQuizServiceProvider),
        ref.read(dailyUsageServiceProvider),
        childId,
      );
    });
