import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/submit_answer_response.dart';
import 'package:confetti/confetti.dart';
import '../../progress/services/progress_service.dart';
import '../../progress/models/save_progress_request.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../child_profile/providers/child_profile_provider.dart';
import '../../child_profile/models/child_profile_dto.dart';

class QuizResultScreen extends ConsumerStatefulWidget {
  final String levelId;
  final int correctCount;
  final int wrongCount;
  final int totalQuestions;
  final Map<String, SubmitAnswerResponse> results;

  const QuizResultScreen({
    super.key,
    required this.levelId,
    required this.correctCount,
    required this.wrongCount,
    required this.totalQuestions,
    required this.results,
  });

  @override
  ConsumerState<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends ConsumerState<QuizResultScreen> {
  ConfettiController? _confettiController;
  int? _earnedScore;
  int? _earnedStars;
  bool _progressSaved = false;
  bool _confettiStarted = false;

  @override
  void initState() {
    super.initState();
    print('🎊 QuizResultScreen initState - levelId: ${widget.levelId}');
    print('📊 Results: ${widget.correctCount}/${widget.totalQuestions} correct');
    
    try {
      _confettiController = ConfettiController(duration: const Duration(seconds: 3));
      
      // Başarılıysa konfeti hemen başlat
      if (_isPassed && !_confettiStarted) {
        _confettiStarted = true;
        // PostFrameCallback içinde başlat - mounted garantili
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _confettiController != null) {
            try {
              print('🎉 Playing confetti animation');
              _confettiController!.play();
            } catch (e) {
              print('⚠️ Error playing confetti: $e');
            }
          }
        });
      }
    } catch (e) {
      print('⚠️ Error creating confetti controller: $e');
    }
    
    // Progress'i kaydet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _saveProgress();
      }
    });
  }

  Future<void> _saveProgress() async {
    if (!mounted) {
      print('⚠️ Widget not mounted, skipping progress save');
      return;
    }
    
    try {
      ChildProfileDto? selectedChild;
      ProgressService? progressService;
      
      // Ref kullanımını try-catch içinde yap
      try {
        selectedChild = ref.read(selectedChildProvider);
        progressService = ref.read(progressServiceProvider);
      } catch (e) {
        print('❌ Error reading ref: $e');
        return;
      }
      
      if (selectedChild == null) {
        print('Selected child bulunamadı');
        return;
      }
      
      if (progressService == null) {
        print('Progress service bulunamadı');
        return;
      }

      final successPercentage = (widget.correctCount / widget.totalQuestions) * 100;

      final request = SaveProgressRequest(
        childId: selectedChild.id,
        levelId: widget.levelId,
        correctCount: widget.correctCount,
        totalQuestions: widget.totalQuestions,
        successPercentage: successPercentage,
      );

      print('💾 Saving progress...');
      final response = await progressService.saveProgress(request);
      
      if (!mounted) {
        print('⚠️ Widget unmounted after saveProgress');
        return;
      }
      
      if (mounted) {
        setState(() {
          _earnedScore = response['score'] as int?;
          _earnedStars = response['stars'] as int?;
          _progressSaved = true;
        });
      }

      print('Progress kaydedildi: Score=$_earnedScore, Stars=$_earnedStars');
      
      // Not: Child profiles refresh etmiyoruz çünkü router redirect'e sebep oluyor
      // Dashboard kendi verilerini zaten çekiyor, oraya döndüğünde güncel değerleri görecek
      
    } catch (e, stackTrace) {
      print('❌ Progress kaydedilirken hata: $e');
      print('Stack trace: $stackTrace');
      // Hata olsa bile kullanıcı deneyimini bozmuyoruz
    }
  }

  @override
  void dispose() {
    print('🗑️ QuizResultScreen dispose called');
    _confettiController?.dispose();
    _confettiController = null;
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
          onPressed: () {
            print('🔙 Going back to dashboard');
            context.go('/dashboard');
          },
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
                        // Kazanılan puan ve yıldız
                        if (_progressSaved && _earnedScore != null) ...[
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _RewardItem(
                                icon: Icons.emoji_events,
                                color: Colors.amber,
                                label: 'Kazanılan Puan',
                                value: '+$_earnedScore',
                              ),
                              _RewardItem(
                                icon: Icons.star,
                                color: Colors.orange,
                                label: 'Yıldız',
                                value: '${'⭐' * (_earnedStars ?? 0)}',
                              ),
                            ],
                          ),
                        ],
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
                      print('🔙 Going to dashboard');
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
          if (_confettiController != null)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController!,
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

class _RewardItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _RewardItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
