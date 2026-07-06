import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/entertainment_models.dart';
import '../services/entertainment_service.dart';
import '../../../core/services/daily_attempt_service.dart';

// ── Topics provider ──────────────────────────────────────────────────────────

final entertainmentTopicsProvider =
    FutureProvider.autoDispose<List<EntertainmentTopicModel>>((ref) async {
  return ref.read(entertainmentServiceProvider).getTopics();
});

// ── Remaining attempts provider ──────────────────────────────────────────────

final entertainmentRemainingProvider =
    FutureProvider.autoDispose<int>((ref) async {
  return entertainmentAttempts.remaining();
});

// ── Quiz state ───────────────────────────────────────────────────────────────

class EntertainmentQuizState {
  final List<EntertainmentQuestionModel> questions;
  final int     currentIndex;
  final bool    isLoading;
  final String? error;
  final Map<int, String> answers;
  final bool    noAttemptsLeft;

  const EntertainmentQuizState({
    this.questions      = const [],
    this.currentIndex   = 0,
    this.isLoading      = false,
    this.error,
    this.answers        = const {},
    this.noAttemptsLeft = false,
  });

  EntertainmentQuizState copyWith({
    List<EntertainmentQuestionModel>? questions,
    int?    currentIndex,
    bool?   isLoading,
    String? error,
    Map<int, String>? answers,
    bool?   noAttemptsLeft,
    bool clearError = false,
  }) => EntertainmentQuizState(
    questions:      questions      ?? this.questions,
    currentIndex:   currentIndex   ?? this.currentIndex,
    isLoading:      isLoading      ?? this.isLoading,
    error:          clearError     ? null : (error ?? this.error),
    answers:        answers        ?? this.answers,
    noAttemptsLeft: noAttemptsLeft ?? this.noAttemptsLeft,
  );

  bool get isDone => currentIndex >= questions.length && questions.isNotEmpty;
  int  get correctCount => answers.entries.where((e) {
    if (e.key >= questions.length) return false;
    return questions[e.key].correctAnswer == e.value;
  }).length;
}

class EntertainmentQuizNotifier
    extends StateNotifier<EntertainmentQuizState> {
  final EntertainmentService _service;

  EntertainmentQuizNotifier(this._service)
      : super(const EntertainmentQuizState());

  Future<void> load({
    required String topicKey,
    required String difficulty,
  }) async {
    // Hak kontrolü
    final remaining = await entertainmentAttempts.remaining();
    if (remaining <= 0) {
      state = state.copyWith(noAttemptsLeft: true);
      return;
    }

    state = state.copyWith(
        isLoading: true, clearError: true, noAttemptsLeft: false,
        questions: [], currentIndex: 0, answers: {});
    try {
      final qs = await _service.generateQuestions(
          topicKey: topicKey, difficulty: difficulty, count: 10);
      // Hak tüket
      await entertainmentAttempts.consume();
      state = state.copyWith(questions: qs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addBonusAttempt() async {
    await entertainmentAttempts.addBonus();
    state = state.copyWith(noAttemptsLeft: false);
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

  void reset() => state = const EntertainmentQuizState();
}

final entertainmentQuizProvider =
    StateNotifierProvider<EntertainmentQuizNotifier, EntertainmentQuizState>(
  (ref) => EntertainmentQuizNotifier(ref.read(entertainmentServiceProvider)),
);

// ── Gerçek mi Uydurma mı? state ──────────────────────────────────────────────

class FactFictionState {
  final List<FactOrFictionQuestionModel> questions;
  final int            currentIndex;
  final bool           isLoading;
  final String?        error;
  final Map<int, bool> answers;       // index → kullanıcı "gerçek" mi dedi?
  final bool           noAttemptsLeft;

  const FactFictionState({
    this.questions      = const [],
    this.currentIndex   = 0,
    this.isLoading      = false,
    this.error,
    this.answers        = const {},
    this.noAttemptsLeft = false,
  });

  FactFictionState copyWith({
    List<FactOrFictionQuestionModel>? questions,
    int?     currentIndex,
    bool?    isLoading,
    String?  error,
    Map<int, bool>? answers,
    bool?    noAttemptsLeft,
    bool     clearError = false,
  }) => FactFictionState(
    questions:      questions      ?? this.questions,
    currentIndex:   currentIndex   ?? this.currentIndex,
    isLoading:      isLoading      ?? this.isLoading,
    error:          clearError     ? null : (error ?? this.error),
    answers:        answers        ?? this.answers,
    noAttemptsLeft: noAttemptsLeft ?? this.noAttemptsLeft,
  );

  bool get isDone =>
      currentIndex >= questions.length && questions.isNotEmpty;

  int get correctCount => answers.entries.where((e) {
    if (e.key >= questions.length) return false;
    return questions[e.key].isReal == e.value;
  }).length;
}

class FactFictionNotifier extends StateNotifier<FactFictionState> {
  final EntertainmentService _service;

  FactFictionNotifier(this._service) : super(const FactFictionState());

  Future<void> load({required String difficulty}) async {
    final remaining = await entertainmentAttempts.remaining();
    if (remaining <= 0) {
      state = state.copyWith(noAttemptsLeft: true);
      return;
    }

    state = state.copyWith(
        isLoading: true, clearError: true, noAttemptsLeft: false,
        questions: [], currentIndex: 0, answers: {});
    try {
      final items = await _service.generateFactFiction(difficulty: difficulty);
      await entertainmentAttempts.consume();
      state = state.copyWith(questions: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addBonusAttempt() async {
    await entertainmentAttempts.addBonus();
    state = state.copyWith(noAttemptsLeft: false);
  }

  void answer(int index, bool userSaysReal) {
    final a = Map<int, bool>.from(state.answers)..[index] = userSaysReal;
    state = state.copyWith(answers: a);
  }

  void next() {
    if (state.currentIndex < state.questions.length) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void reset() => state = const FactFictionState();
}

final factFictionProvider =
    StateNotifierProvider<FactFictionNotifier, FactFictionState>(
  (ref) => FactFictionNotifier(ref.read(entertainmentServiceProvider)),
);

// ── Kim Bu? state ─────────────────────────────────────────────────────────────

class KimBuState {
  final KimBuRoundModel? round;
  final int          currentSubjectIndex;
  final int          hintsRevealed;      // 1–5
  final Map<int, bool> answers;          // subject index → doğru mu?
  final bool         isLoading;
  final String?      error;
  final bool         noAttemptsLeft;

  const KimBuState({
    this.round,
    this.currentSubjectIndex = 0,
    this.hintsRevealed       = 1,
    this.answers             = const {},
    this.isLoading           = false,
    this.error,
    this.noAttemptsLeft      = false,
  });

  KimBuState copyWith({
    KimBuRoundModel? round,
    int?     currentSubjectIndex,
    int?     hintsRevealed,
    Map<int, bool>? answers,
    bool?    isLoading,
    String?  error,
    bool?    noAttemptsLeft,
    bool     clearError = false,
  }) => KimBuState(
    round:                round                ?? this.round,
    currentSubjectIndex:  currentSubjectIndex  ?? this.currentSubjectIndex,
    hintsRevealed:        hintsRevealed        ?? this.hintsRevealed,
    answers:              answers              ?? this.answers,
    isLoading:            isLoading            ?? this.isLoading,
    error:                clearError           ? null : (error ?? this.error),
    noAttemptsLeft:       noAttemptsLeft       ?? this.noAttemptsLeft,
  );

  bool get hasRound  => round != null && round!.subjects.isNotEmpty;
  /// isDone: son sorunun cevabı verildikten sonra kullanıcı "Sıradaki" butonuna
  /// bastığında true olur — cevap+açıklama gösterildikten SONRA result'a geçilir.
  bool get isDone    => hasRound && currentSubjectIndex >= round!.subjects.length;

  /// Doğru tahmin sayısı (0–5) — EntertainmentResultView'e correctCount olarak geçer.
  int get correctCount => answers.values.where((v) => v).length;

  KimBuSubjectModel? get currentSubject =>
      hasRound && currentSubjectIndex < round!.subjects.length
          ? round!.subjects[currentSubjectIndex]
          : null;
}

class KimBuNotifier extends StateNotifier<KimBuState> {
  final EntertainmentService _service;

  KimBuNotifier(this._service) : super(const KimBuState());

  Future<void> load({required String difficulty}) async {
    final remaining = await entertainmentAttempts.remaining();
    if (remaining <= 0) {
      state = state.copyWith(noAttemptsLeft: true);
      return;
    }

    state = const KimBuState(isLoading: true);
    try {
      final round = await _service.generateKimBu(difficulty: difficulty);
      await entertainmentAttempts.consume();
      state = KimBuState(round: round, hintsRevealed: 1);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Bir sonraki ipucunu açar (max 5).
  void revealNextHint() {
    final subject = state.currentSubject;
    if (subject == null) return;
    final maxHints = subject.hints.length;
    if (state.hintsRevealed < maxHints) {
      state = state.copyWith(hintsRevealed: state.hintsRevealed + 1);
    }
  }

  /// Kullanıcı cevap verdi — doğru mu kontrol et, sonraki konuya geç.
  void submitAnswer(String answer) {
    final subject = state.currentSubject;
    if (subject == null) return;
    final isCorrect = answer == subject.correctAnswer;
    final newAnswers = Map<int, bool>.from(state.answers)
      ..[state.currentSubjectIndex] = isCorrect;
    state = state.copyWith(answers: newAnswers);
  }

  /// Cevap gösterildikten sonra sonraki konuya geç.
  void nextSubject() {
    state = state.copyWith(
      currentSubjectIndex: state.currentSubjectIndex + 1,
      hintsRevealed: 1,
    );
  }

  Future<void> addBonusAttempt() async {
    await entertainmentAttempts.addBonus();
    state = state.copyWith(noAttemptsLeft: false);
  }

  void reset() => state = const KimBuState();
}

final kimBuProvider =
    StateNotifierProvider<KimBuNotifier, KimBuState>(
  (ref) => KimBuNotifier(ref.read(entertainmentServiceProvider)),
);

// ── Ne Ortak? state ───────────────────────────────────────────────────────────

class NeOrtakState {
  final List<NeOrtakQuestionModel> questions;
  final int            currentIndex;
  final Map<int, bool> answers;     // index → doğru mu?
  final bool           isLoading;
  final String?        error;
  final bool           noAttemptsLeft;

  const NeOrtakState({
    this.questions      = const [],
    this.currentIndex   = 0,
    this.answers        = const {},
    this.isLoading      = false,
    this.error,
    this.noAttemptsLeft = false,
  });

  NeOrtakState copyWith({
    List<NeOrtakQuestionModel>? questions,
    int?     currentIndex,
    Map<int, bool>? answers,
    bool?    isLoading,
    String?  error,
    bool?    noAttemptsLeft,
    bool     clearError = false,
  }) => NeOrtakState(
    questions:      questions      ?? this.questions,
    currentIndex:   currentIndex   ?? this.currentIndex,
    answers:        answers        ?? this.answers,
    isLoading:      isLoading      ?? this.isLoading,
    error:          clearError     ? null : (error ?? this.error),
    noAttemptsLeft: noAttemptsLeft ?? this.noAttemptsLeft,
  );

  bool get isDone =>
      currentIndex >= questions.length && questions.isNotEmpty;

  int get correctCount => answers.values.where((v) => v).length;
}

class NeOrtakNotifier extends StateNotifier<NeOrtakState> {
  final EntertainmentService _service;

  NeOrtakNotifier(this._service) : super(const NeOrtakState());

  Future<void> load({required String difficulty}) async {
    final remaining = await entertainmentAttempts.remaining();
    if (remaining <= 0) {
      state = state.copyWith(noAttemptsLeft: true);
      return;
    }

    state = const NeOrtakState(isLoading: true);
    try {
      final questions = await _service.generateNeOrtak(difficulty: difficulty);
      await entertainmentAttempts.consume();
      state = NeOrtakState(questions: questions);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void answer(int index, bool isCorrect) {
    final a = Map<int, bool>.from(state.answers)..[index] = isCorrect;
    state = state.copyWith(answers: a);
  }

  void next() {
    if (state.currentIndex < state.questions.length) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  Future<void> addBonusAttempt() async {
    await entertainmentAttempts.addBonus();
    state = state.copyWith(noAttemptsLeft: false);
  }

  void reset() => state = const NeOrtakState();
}

final neOrtakProvider =
    StateNotifierProvider<NeOrtakNotifier, NeOrtakState>(
  (ref) => NeOrtakNotifier(ref.read(entertainmentServiceProvider)),
);
