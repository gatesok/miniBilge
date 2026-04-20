import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/question.dart';
import '../providers/quiz_provider.dart';
import '../widgets/answer_widget.dart';

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

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!_isInitialized) {
        await ref.read(quizProvider.notifier).startQuiz(widget.levelId);
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);

    if (quizState.isCompleted && _isInitialized) {
      Future.microtask(() {
        context.go('/education/quiz-result', extra: {
          'correctCount': quizState.correctCount,
          'wrongCount': quizState.wrongCount,
          'totalQuestions': quizState.questions.length,
          'results': quizState.results,
        });
      });
    }

    if (!_isInitialized || quizState.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.topicName),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (quizState.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.topicName),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              const Text('Bu seviyede henüz soru bulunmuyor'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Geri Dön'),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = quizState.currentQuestion;
    if (currentQuestion == null) {
      return const Scaffold(
        body: Center(child: Text('Soru yüklenemedi')),
      );
    }

    final progress = (quizState.currentQuestionIndex + 1) / quizState.questions.length;
    final questionNumber = quizState.currentQuestionIndex + 1;
    final totalQuestions = quizState.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.topicName} - ${widget.levelName}'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '$questionNumber/$totalQuestions',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
          ),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Soru $questionNumber',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                currentQuestion.questionText,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnswerWidget(
                        question: currentQuestion,
                        onAnswerSubmitted: (answer) async {
                          if (_isProcessingAnswer) return;
                          
                          setState(() {
                            _isProcessingAnswer = true;
                          });
                          
                          await ref.read(quizProvider.notifier).submitAnswer(answer);
                          
                          final quizState = ref.read(quizProvider);
                          final result = quizState.results[currentQuestion.id];
                          
                          if (result != null && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(
                                      result.isCorrect ? Icons.check_circle : Icons.cancel,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            result.isCorrect ? '✓ Doğru!' : '✗ Yanlış',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          if (!result.isCorrect)
                                            Text(
                                              'Doğru cevap: ${result.correctAnswer}',
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          if (result.explanation != null && result.explanation!.isNotEmpty)
                                            Text(
                                              result.explanation!,
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: result.isCorrect ? Colors.green : Colors.red,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                          
                          await Future.delayed(const Duration(seconds: 2));
                          if (mounted) {
                            ref.read(quizProvider.notifier).nextQuestion();
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
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                'Sonraki soruya geçiliyor...',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
