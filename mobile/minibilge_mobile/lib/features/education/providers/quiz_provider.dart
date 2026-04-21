import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import '../models/submit_answer_response.dart';
import '../services/education_service.dart';

// Quiz State
class QuizState {
  final List<Question> questions;
  final int currentQuestionIndex;
  final Map<String, String> userAnswers; // questionId -> userAnswer
  final Map<String, SubmitAnswerResponse> results; // questionId -> result
  final bool isLoading;
  final bool isCompleted;

  QuizState({
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.userAnswers = const {},
    this.results = const {},
    this.isLoading = false,
    this.isCompleted = false,
  });

  QuizState copyWith({
    List<Question>? questions,
    int? currentQuestionIndex,
    Map<String, String>? userAnswers,
    Map<String, SubmitAnswerResponse>? results,
    bool? isLoading,
    bool? isCompleted,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Question? get currentQuestion {
    if (currentQuestionIndex < questions.length) {
      return questions[currentQuestionIndex];
    }
    return null;
  }

  int get correctCount {
    return results.values.where((r) => r.isCorrect).length;
  }

  int get wrongCount {
    return results.values.where((r) => !r.isCorrect).length;
  }

  double get successPercentage {
    if (results.isEmpty) return 0.0;
    return (correctCount / results.length) * 100;
  }
}

// Quiz Notifier
class QuizNotifier extends StateNotifier<QuizState> {
  final EducationService _educationService;

  QuizNotifier(this._educationService) : super(QuizState());

  // Quiz başlat - seviyeden soruları çek
  Future<void> startQuiz(String levelId, {int questionCount = 10}) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final questions = await _educationService.getQuestions(levelId, count: questionCount);
      state = QuizState(
        questions: questions,
        currentQuestionIndex: 0,
        userAnswers: {},
        results: {},
        isLoading: false,
        isCompleted: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  // Cevap gönder
  Future<void> submitAnswer(String answer) async {
    final currentQuestion = state.currentQuestion;
    if (currentQuestion == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final result = await _educationService.submitAnswer(
        questionId: currentQuestion.id,
        userAnswer: answer,
      );

      final newAnswers = Map<String, String>.from(state.userAnswers);
      newAnswers[currentQuestion.id] = answer;

      final newResults = Map<String, SubmitAnswerResponse>.from(state.results);
      newResults[currentQuestion.id] = result;

      state = state.copyWith(
        userAnswers: newAnswers,
        results: newResults,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  // Sonraki soruya geç
  void nextQuestion() {
    print('📊 nextQuestion called: currentIndex=${state.currentQuestionIndex}, total=${state.questions.length}');
    if (state.currentQuestionIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
      print('➡️ Moving to question ${state.currentQuestionIndex + 1}/${state.questions.length}');
    } else {
      // Quiz tamamlandı
      print('✅ Quiz completed! Setting isCompleted=true');
      state = state.copyWith(isCompleted: true);
    }
  }

  // Quiz'i sıfırla
  void resetQuiz() {
    print('🔄 Quiz reset called');
    state = QuizState();
  }

  // Belirli bir soruya git
  void goToQuestion(int index) {
    if (index >= 0 && index < state.questions.length) {
      state = state.copyWith(currentQuestionIndex: index);
    }
  }
}

// Quiz Provider
final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  final educationService = ref.read(educationServiceProvider);
  return QuizNotifier(educationService);
});
