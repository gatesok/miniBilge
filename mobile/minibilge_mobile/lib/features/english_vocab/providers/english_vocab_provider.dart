import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/english_vocab_models.dart';
import '../services/english_vocab_service.dart';

/// Kelime Oyunu durum sınıfı — kota YOK; entertainment quiz'in sadeleştirilmiş eşi.
class EnglishVocabQuizState {
  final List<VocabQuestionModel> questions;
  final int currentIndex;
  final bool isLoading;
  final String? error;
  final Map<int, String> answers; // soru index → seçim (A/B/C/D)
  final Set<int> shownIds;        // DB kelimelerinin oturum içi tekrarını önlemek için
  final DateTime? startedAt;      // süre ölçümü için

  const EnglishVocabQuizState({
    this.questions = const [],
    this.currentIndex = 0,
    this.isLoading = false,
    this.error,
    this.answers = const {},
    this.shownIds = const {},
    this.startedAt,
  });

  bool get isDone => currentIndex >= questions.length && questions.isNotEmpty;

  int get correctCount => answers.entries.where((e) {
    if (e.key >= questions.length) return false;
    return questions[e.key].correctAnswer == e.value;
  }).length;

  EnglishVocabQuizState copyWith({
    List<VocabQuestionModel>? questions,
    int? currentIndex,
    bool? isLoading,
    String? error,
    bool clearError = false,
    Map<int, String>? answers,
    Set<int>? shownIds,
    DateTime? startedAt,
  }) {
    return EnglishVocabQuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      answers: answers ?? this.answers,
      shownIds: shownIds ?? this.shownIds,
      startedAt: startedAt ?? this.startedAt,
    );
  }
}

class EnglishVocabQuizNotifier extends StateNotifier<EnglishVocabQuizState> {
  final EnglishVocabService _service;

  EnglishVocabQuizNotifier(this._service)
      : super(const EnglishVocabQuizState());

  Future<void> load({required String levelCode}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      questions: [],
      currentIndex: 0,
      answers: {},
    );

    try {
      final qs = await _service.generateQuestions(
        levelCode: levelCode,
        count: 10,
        excludeIds: state.shownIds.toList(),
      );
      if (!mounted) return;

      if (qs.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Bu seviyede henüz kelime yok.',
        );
        return;
      }

      final newIds = qs.where((q) => q.id > 0).map((q) => q.id).toSet();
      state = state.copyWith(
        questions: qs,
        isLoading: false,
        shownIds: {...state.shownIds, ...newIds},
        startedAt: DateTime.now(),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void answer(int index, String choice) {
    final a = Map<int, String>.from(state.answers)..[index] = choice;
    state = state.copyWith(answers: a);
  }

  void next() {
    if (state.currentIndex < state.questions.length) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }
}

final englishVocabQuizProvider = StateNotifierProvider.autoDispose<
    EnglishVocabQuizNotifier, EnglishVocabQuizState>(
  (ref) => EnglishVocabQuizNotifier(
    ref.read(englishVocabServiceProvider),
  ),
);
