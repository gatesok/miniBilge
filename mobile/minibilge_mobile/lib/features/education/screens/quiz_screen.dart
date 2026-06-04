import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/quiz_provider.dart';
import '../widgets/answer_widget.dart';
import '../../../shared/widgets/math_text_widget.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String levelId;
  final String levelName;
  final String topicName;

  const QuizScreen({
    super.key,
    required this.levelId,
    required this.levelName,
    required this.topicName,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  bool _isInitialized = false;
  bool _isProcessingAnswer = false;
  bool _hasNavigatedToResult = false;

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
  }

  @override
  void didUpdateWidget(QuizScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.levelId != widget.levelId) {
      setState(() {
        _isInitialized = false;
        _hasNavigatedToResult = false;
      });
      _initializeQuiz();
    }
  }

  void _initializeQuiz() {
    Future.microtask(() async {
      if (!_isInitialized) {
        ref.read(quizProvider.notifier).resetQuiz();
        await ref.read(quizProvider.notifier).startQuiz(widget.levelId);
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _hasNavigatedToResult = false;
          });
        }
      }
    });
  }

  void _retryQuiz() {
    setState(() {
      _isInitialized = false;
      _hasNavigatedToResult = false;
    });
    _initializeQuiz();
  }

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
  );

  Widget _gradientScaffold(Widget body) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(child: body),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);

    if (quizState.isCompleted && _isInitialized && !_hasNavigatedToResult) {
      print('🎉 Quiz completed! Navigating to result screen...');
      print('Correct: ${quizState.correctCount}, Wrong: ${quizState.wrongCount}');
      _hasNavigatedToResult = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          print('🚀 Going to quiz result screen with context.go');
          context.go('/education/quiz-result', extra: {
            'levelId': widget.levelId,
            'correctCount': quizState.correctCount,
            'wrongCount': quizState.wrongCount,
            'totalQuestions': quizState.questions.length,
            'results': quizState.results,
          });
        }
      });
    }

    if (quizState.hasError) {
      return _gradientScaffold(
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('😵', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text(
                  quizState.errorMessage ?? 'Sorular yüklenemedi.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _retryQuiz,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A3FCC),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text('Tekrar Dene',
                        style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isInitialized || quizState.isLoading) {
      return _gradientScaffold(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (quizState.questions.isEmpty) {
      return _gradientScaffold(
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 16),
                Text('Bu seviyede henüz soru bulunmuyor',
                    style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A3FCC),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text('Geri Dön',
                        style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentQuestion = quizState.currentQuestion;
    if (currentQuestion == null) {
      return _gradientScaffold(
        Center(
          child: Text('Soru yüklenemedi',
              style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
        ),
      );
    }

    final progress =
        (quizState.currentQuestionIndex + 1) / quizState.questions.length;
    final questionNumber = quizState.currentQuestionIndex + 1;
    final totalQuestions = quizState.questions.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar: back + topic + question counter
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.28),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1.5),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${widget.topicName} – ${widget.levelName}',
                        style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.28),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.5), width: 1.5),
                      ),
                      child: Text(
                        '$questionNumber/$totalQuestions',
                        style: GoogleFonts.luckiestGuy(
                            fontSize: 16,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                  blurRadius: 0,
                                  color: Color(0xFF3D35CC),
                                  offset: Offset(1, 1))
                            ]),
                      ),
                    ),
                  ],
                ),
              ),
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF7B61FF)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Quiz content
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Question card
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.45),
                                  width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Soru $questionNumber',
                                  style: GoogleFonts.nunito(
                                      color: Colors.white.withOpacity(0.75),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13),
                                ),
                                const SizedBox(height: 10),
                                MathText(
                                  text: currentQuestion.questionText,
                                  hasLatex: currentQuestion.hasLatex,
                                  style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          AnswerWidget(
                            question: currentQuestion,
                            onAnswerSubmitted: (answer) async {
                              if (_isProcessingAnswer) return;

                              setState(() {
                                _isProcessingAnswer = true;
                              });

                              await ref
                                  .read(quizProvider.notifier)
                                  .submitAnswer(answer);

                              final updatedState = ref.read(quizProvider);
                              final result =
                                  updatedState.results[currentQuestion.id];

                              if (result != null && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Text(
                                          result.isCorrect ? '✅' : '❌',
                                          style:
                                              const TextStyle(fontSize: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                result.isCorrect
                                                    ? '✓ Doğru!'
                                                    : '✗ Yanlış',
                                                style: GoogleFonts.nunito(
                                                    fontWeight:
                                                        FontWeight.w800,
                                                    fontSize: 16,
                                                    color: Colors.white),
                                              ),
                                              if (!result.isCorrect)
                                                Text(
                                                  'Doğru cevap: ${result.correctAnswer}',
                                                  style: GoogleFonts.nunito(
                                                      fontSize: 14,
                                                      color: Colors.white),
                                                ),
                                              if (result.explanation !=
                                                      null &&
                                                  result.explanation!
                                                      .isNotEmpty)
                                                Text(
                                                  result.explanation!,
                                                  style: GoogleFonts.nunito(
                                                      fontSize: 12,
                                                      color: Colors.white),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: result.isCorrect
                                        ? Colors.green
                                        : Colors.red,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }

                              await Future.delayed(
                                  const Duration(seconds: 2));
                              if (mounted) {
                                ref
                                    .read(quizProvider.notifier)
                                    .nextQuestion();
                                setState(() {
                                  _isProcessingAnswer = false;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    if (_isProcessingAnswer)
                      Container(
                        color: Colors.black.withOpacity(0.45),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.45),
                                  width: 1.5),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(
                                    color: Colors.white),
                                const SizedBox(height: 16),
                                Text(
                                  'Sonraki soruya geçiliyor...',
                                  style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
