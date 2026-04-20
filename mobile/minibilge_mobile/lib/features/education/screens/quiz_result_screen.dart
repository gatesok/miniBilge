import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/submit_answer_response.dart';
import 'package:confetti/confetti.dart';

class QuizResultScreen extends ConsumerStatefulWidget {
  final int correctCount;
  final int wrongCount;
  final int totalQuestions;
  final Map<String, SubmitAnswerResponse> results;

  const QuizResultScreen({
    super.key,
    required this.correctCount,
    required this.wrongCount,
    required this.totalQuestions,
    required this.results,
  });

  @override
  ConsumerState<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends ConsumerState<QuizResultScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // Başarılıysa konfeti patla
    if (_isPassed) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _confettiController.play();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  bool get _isPassed {
    final successPercentage = (widget.correctCount / widget.totalQuestions) * 100;
    return successPercentage >= 70; // 70% başarı geçme notu
  }

  @override
  Widget build(BuildContext context) {
    final successPercentage = (widget.correctCount / widget.totalQuestions) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sonuç'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Success icon and message
                Icon(
                  _isPassed ? Icons.emoji_events : Icons.mood_bad,
                  size: 100,
                  color: _isPassed ? Colors.amber : Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  _isPassed ? 'Tebrikler!' : 'Daha fazla çalışmalısın!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Score card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Circular progress
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: Stack(
                            children: [
                              Center(
                                child: SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: CircularProgressIndicator(
                                    value: successPercentage / 100,
                                    strokeWidth: 12,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _isPassed ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${successPercentage.toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'Başarı',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatItem(
                              icon: Icons.check_circle,
                              color: Colors.green,
                              label: 'Doğru',
                              value: widget.correctCount.toString(),
                            ),
                            _StatItem(
                              icon: Icons.cancel,
                              color: Colors.red,
                              label: 'Yanlış',
                              value: widget.wrongCount.toString(),
                            ),
                            _StatItem(
                              icon: Icons.quiz,
                              color: Colors.blue,
                              label: 'Toplam',
                              value: widget.totalQuestions.toString(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Action buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/dashboard');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Ana Sayfaya Dön',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
