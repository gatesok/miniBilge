import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/submit_answer_response.dart';
import '../models/question.dart';
import 'package:confetti/confetti.dart';
import '../../progress/services/progress_service.dart';
import '../../progress/models/save_progress_request.dart';
import '../../progress/providers/progress_provider.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../child_profile/providers/child_profile_provider.dart';
import '../../child_profile/models/child_profile_dto.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/services/streak_service.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/network/dio_provider.dart';
import '../services/topic_explanation_service.dart';
import '../../../core/widgets/card_drop_animation.dart';
import '../../collection/models/card_dto.dart';
import '../../collection/providers/collection_provider.dart';

class QuizResultScreen extends ConsumerStatefulWidget {
  final String levelId;
  final int correctCount;
  final int wrongCount;
  final int totalQuestions;
  final Map<String, SubmitAnswerResponse> results;
  final List<Question> questions;
  final String subjectName;
  final String topicName;

  const QuizResultScreen({
    super.key,
    required this.levelId,
    required this.correctCount,
    required this.wrongCount,
    required this.totalQuestions,
    required this.results,
    this.questions = const [],
    this.subjectName = '',
    this.topicName = '',
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
  CardDropResult? _cardDrop;
  List<String> _earnedBadges = [];
  bool _isLoadingExplanation = false;

  bool get _isEnglish {
    final s = widget.subjectName.toLowerCase();
    return s.contains('ingilizce') || s.contains('english');
  }

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
  );

  @override
  void initState() {
    super.initState();
    print('🎊 QuizResultScreen initState - levelId: ${widget.levelId}');
    print('📊 Results: ${widget.correctCount}/${widget.totalQuestions} correct');

    try {
      _confettiController =
          ConfettiController(duration: const Duration(seconds: 3));
      if (_isPassed && !_confettiStarted) {
        _confettiStarted = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _confettiController != null) {
            try {
              print('🎉 Playing confetti animation');
              _confettiController!.play();
              SoundService.playWin();
            } catch (e) {
              print('⚠️ Error playing confetti: $e');
            }
          }
        });
      } else if (!_isPassed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          SoundService.playLose();
        });
      }
    } catch (e) {
      print('⚠️ Error creating confetti controller: $e');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _saveProgress();
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
      final successPercentage =
          (widget.correctCount / widget.totalQuestions) * 100;
      final isEnglish = widget.subjectName.toLowerCase().contains('ingilizce') ||
          widget.subjectName.toLowerCase().contains('english');
      final request = SaveProgressRequest(
        childId: selectedChild.id,
        levelId: widget.levelId,
        correctCount: widget.correctCount,
        totalQuestions: widget.totalQuestions,
        successPercentage: successPercentage,
        subjectName: widget.subjectName.isNotEmpty ? widget.subjectName : null,
        englishLevel: isEnglish ? 'english' : null,
      );
      print('💾 Saving progress...');
      final response = await progressService.saveProgress(request);

      // Always invalidate providers after successful save, regardless of mount state.
      ref.invalidate(childProgressProvider(selectedChild.id));
      ref.invalidate(levelResultsProvider(selectedChild.id));

      if (!mounted) {
        print('⚠️ Widget unmounted after saveProgress — providers invalidated, skipping UI update');
        return;
      }

      // Kart drop parse et
      CardDropResult? cardDrop;
      if (response['cardDrop'] != null) {
        try {
          cardDrop = CardDropResult.fromJson(
              response['cardDrop'] as Map<String, dynamic>);
        } catch (e) {
          print('⚠️ cardDrop parse hatası: $e');
        }
      }

      // Kazanılan rozetler
      List<String> badges = [];
      if (response['earnedBadges'] is List) {
        badges = (response['earnedBadges'] as List)
            .map((e) => e.toString())
            .toList();
      }

      setState(() {
        _earnedScore = response['score'] as int?;
        _earnedStars = response['stars'] as int?;
        _progressSaved = true;
        _cardDrop = cardDrop;
        _earnedBadges = badges;
      });
      print('Progress kaydedildi: Score=$_earnedScore, Stars=$_earnedStars, card=$cardDrop, badges=$badges');

      // Kart animasyonu göster + koleksiyon cache'i temizle
      if (cardDrop != null) {
        ref.invalidate(cardCollectionProvider(selectedChild.id));
        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 600));
          if (mounted) {
            await CardDropAnimation.show(context, drop: cardDrop);
          }
        }
      }

      // Rozet gelince badge cache'i de temizle
      if (badges.isNotEmpty) {
        ref.invalidate(badgeCollectionProvider(selectedChild.id));
      }

      // Streak güncelle
      await StreakService.recordActivity(selectedChild.id);
      await ref.read(childProfileProvider.notifier).loadProfiles();
    } catch (e, stackTrace) {
      print('❌ Progress kaydedilirken hata: $e');
      print('Stack trace: $stackTrace');
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
    final successPercentage =
        (widget.correctCount / widget.totalQuestions) * 100;
    return successPercentage >= 70;
  }

  // ─── Konu Anlatımı ────────────────────────────────────────────────────────

  String get _cefrLevel {
    final child = ref.read(selectedChildProvider);
    return child?.englishLevel?.toUpperCase() ?? 'B1';
  }

  void _requestExplanation() {
    setState(() => _isLoadingExplanation = true);
    // Soru metni + yanlış cevap + doğru cevap bilgisini birleştir
    final questionMap = {for (final q in widget.questions) q.id: q};
    final wrongTopics = widget.results.entries
        .where((e) => !e.value.isCorrect)
        .map((e) {
          final q = questionMap[e.key];
          final questionText = q?.questionText ?? '';
          final correctAnswer = e.value.correctAnswer;
          if (questionText.isNotEmpty) {
            return 'Soru: "$questionText" → Doğru cevap: "$correctAnswer"';
          }
          return 'Doğru cevap: "$correctAnswer"';
        })
        .toList();
    RewardedAdService.showRewardedAd(
      onRewarded: () async {
        try {
          final service = TopicExplanationService(ref.read(dioProvider));
          final topicLabel = widget.topicName.isNotEmpty
              ? widget.topicName
              : widget.subjectName;
          final explanation = await service.explain(
            level: _cefrLevel,
            subjectName: topicLabel,
            wrongTopics: wrongTopics,
          );
          if (!mounted) return;
          _showExplanationSheet(explanation);
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Konu anlatımı yüklenemedi, tekrar dene.')),
          );
        }
      },
      onComplete: () {
        if (mounted) setState(() => _isLoadingExplanation = false);
      },
    );
  }

  void _showExplanationSheet(dynamic explanation) {
    setState(() => _isLoadingExplanation = false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TopicExplanationSheet(
        subjectName: widget.topicName.isNotEmpty ? widget.topicName : widget.subjectName,
        explanation: explanation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final successPercentage =
        (widget.correctCount / widget.totalQuestions) * 100;
    final successColor = _isPassed ? Colors.green : Colors.orange;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            print('🔙 Going back to dashboard');
                            AdService.showInterstitialAd(
                              onComplete: () {
                                if (context.mounted) context.go('/dashboard');
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.28),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 1.5),
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Sonuç',
                          style: GoogleFonts.luckiestGuy(
                            fontSize: 24,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                  blurRadius: 0,
                                  color: Color(0xFF3D35CC),
                                  offset: Offset(2, 2))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          // Big emoji + title
                          Text(
                            _isPassed ? '🏆' : '😤',
                            style: const TextStyle(fontSize: 80),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isPassed ? 'Tebrikler!' : 'Daha fazla çalışmalısın!',
                            style: GoogleFonts.luckiestGuy(
                              fontSize: 28,
                              color: Colors.white,
                              shadows: const [
                                Shadow(
                                    blurRadius: 0,
                                    color: Color(0xFF3D35CC),
                                    offset: Offset(2, 2))
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          // Score card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.45),
                                  width: 1.5),
                            ),
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
                                            strokeWidth: 14,
                                            backgroundColor: Colors.white
                                                .withOpacity(0.2),
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    successColor),
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${successPercentage.toStringAsFixed(0)}%',
                                              style: GoogleFonts.luckiestGuy(
                                                fontSize: 36,
                                                color: Colors.white,
                                                shadows: const [
                                                  Shadow(
                                                      blurRadius: 0,
                                                      color: Color(0xFF3D35CC),
                                                      offset: Offset(2, 2))
                                                ],
                                              ),
                                            ),
                                            Text(
                                              'Başarı',
                                              style: GoogleFonts.nunito(
                                                  fontSize: 13,
                                                  color: Colors.white
                                                      .withOpacity(0.85),
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 28),
                                // Stats row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _StatItem(
                                        emoji: '✅',
                                        label: 'Doğru',
                                        value: widget.correctCount.toString(),
                                        color: Colors.green),
                                    _StatItem(
                                        emoji: '❌',
                                        label: 'Yanlış',
                                        value: widget.wrongCount.toString(),
                                        color: Colors.red),
                                    _StatItem(
                                        emoji: '🧩',
                                        label: 'Toplam',
                                        value:
                                            widget.totalQuestions.toString(),
                                        color: const Color(0xFF4FC3F7)),
                                  ],
                                ),
                                // Rewards
                                if (_progressSaved &&
                                    _earnedScore != null) ...[
                                  const SizedBox(height: 20),
                                  Container(
                                    height: 1,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _RewardCard(
                                          emoji: '⭐',
                                          label: 'Kazanılan Puan',
                                          value: '+$_earnedScore',
                                          color: const Color(0xFFFFB300),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: _RewardCard(
                                          emoji: '🌟',
                                          label: 'Yıldız',
                                          value: _buildStarString(
                                              _earnedStars ?? 0),
                                          color: const Color(0xFFFF8C00),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Kart banner
                                  if (_cardDrop != null) ...[
                                    const SizedBox(height: 12),
                                    _CardEarnedBanner(drop: _cardDrop!),
                                  ],
                                  // Rozet banner
                                  if (_earnedBadges.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    _BadgeEarnedBanner(
                                        badgeCount: _earnedBadges.length),
                                  ],
                                ] else if (!_progressSaved) ...[
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white)),
                                      const SizedBox(width: 10),
                                      Text('Sonuç kaydediliyor...',
                                          style: GoogleFonts.nunito(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13)),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Action buttons
                          if (_isEnglish) ...[                            _Game3DButton(
                              label: _isLoadingExplanation
                                  ? 'Yükleniyor...'
                                  : '📚 Konuyu Öğren',
                              gradientColors: const [
                                Color(0xFF26A69A),
                                Color(0xFF00BFA5),
                              ],
                              shadowColor: const Color(0xFF00695C),
                              onTap: _isLoadingExplanation
                                  ? () {}
                                  : _requestExplanation,
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (_isPassed) ...[
                            _Game3DButton(
                              label: '🏆 Sıralamayı Gör',
                              gradientColors: const [
                                Color(0xFF9B59B6),
                                Color(0xFF7B61FF)
                              ],
                              shadowColor: const Color(0xFF4A2072),
                              onTap: () => context.push('/leaderboard'),
                            ),
                            const SizedBox(height: 12),
                          ],
                          _Game3DButton(
                            label: 'Ana Sayfaya Dön',
                            gradientColors: const [
                              Color(0xFF3498DB),
                              Color(0xFF4FC3F7)
                            ],
                            shadowColor: const Color(0xFF1A5A8A),
                            onTap: () {
                              print('🔙 Going to dashboard');
                              AdService.showInterstitialAd(
                                onComplete: () {
                                  if (context.mounted) context.go('/dashboard');
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
        ),
      ),
    );
  }

  String _buildStarString(int stars) {
    return '${'⭐' * stars}${'☆' * (3 - stars)}';
  }
}

class _StatItem extends StatelessWidget {
  final String emoji;
  final Color color;
  final String label;
  final String value;

  const _StatItem(
      {required this.emoji,
      required this.color,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(value,
            style: GoogleFonts.luckiestGuy(
                fontSize: 28,
                color: Colors.white,
                shadows: const [
                  Shadow(
                      blurRadius: 0,
                      color: Color(0xFF3D35CC),
                      offset: Offset(1, 1))
                ])),
        Text(label,
            style: GoogleFonts.nunito(
                fontSize: 13,
                color: Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _RewardCard extends StatelessWidget {
  final String emoji;
  final Color color;
  final String label;
  final String value;

  const _RewardCard(
      {required this.emoji,
      required this.color,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.luckiestGuy(
                  fontSize: 22,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                        blurRadius: 0,
                        color: Color(0xFF3D35CC),
                        offset: Offset(1, 1))
                  ])),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.nunito(
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w700,
                  fontSize: 12),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Game3DButton extends StatelessWidget {
  final String label;
  final List<Color> gradientColors;
  final Color shadowColor;
  final VoidCallback onTap;

  const _Game3DButton(
      {required this.label,
      required this.gradientColors,
      required this.shadowColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 62,
        decoration: BoxDecoration(
          color: shadowColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.luckiestGuy(
                  fontSize: 18,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                        blurRadius: 0,
                        color: shadowColor,
                        offset: const Offset(1, 1))
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
class _CardEarnedBanner extends StatelessWidget {
  final CardDropResult drop;
  const _CardEarnedBanner({required this.drop});

  Color get _rarityColor {
    switch (drop.rarity.toLowerCase()) {
      case 'legendary':
        return const Color(0xFFFFB300);
      case 'epic':
        return const Color(0xFF9B59B6);
      case 'rare':
        return const Color(0xFF3498DB);
      default:
        return const Color(0xFF27AE60);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _rarityColor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.55), width: 1.5),
      ),
      child: Row(
        children: [
          Text('🃏', style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Yeni Kart Kazandın!',
                    style: GoogleFonts.luckiestGuy(
                        fontSize: 14,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                              blurRadius: 0,
                              color: Color(0xFF3D35CC),
                              offset: Offset(1, 1))
                        ])),
                const SizedBox(height: 2),
                Text(drop.cardName,
                    style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.6)),
            ),
            child: Text(
              drop.rarity.toUpperCase(),
              style: GoogleFonts.nunito(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeEarnedBanner extends StatelessWidget {
  final int badgeCount;
  const _BadgeEarnedBanner({required this.badgeCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF7B61FF).withOpacity(0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: const Color(0xFF7B61FF).withOpacity(0.55), width: 1.5),
      ),
      child: Row(
        children: [
          Text('🏅', style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              badgeCount == 1
                  ? 'Yeni Rozet Kazandın!'
                  : '$badgeCount Yeni Rozet Kazandın!',
              style: GoogleFonts.luckiestGuy(
                  fontSize: 14,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                        blurRadius: 0,
                        color: Color(0xFF3D35CC),
                        offset: Offset(1, 1))
                  ]),
            ),
          ),
          const Text('✨', style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}

// ─── Konu Anlatımı Bottom Sheet ───────────────────────────────────────────────

class _TopicExplanationSheet extends StatelessWidget {
  final String subjectName;
  final dynamic explanation; // TopicExplanation

  const _TopicExplanationSheet({
    required this.subjectName,
    required this.explanation,
  });

  static const _bg = Color(0xFF0D1B2A);
  static const _card = Color(0xFF1A2A3A);
  static const _accent = Color(0xFF26A69A);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Başlık
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text('📚', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      subjectName,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            // İçerik
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                children: [
                  // Kural
                  _Section(
                    icon: '💡',
                    title: 'Kural',
                    color: _accent,
                    child: Text(
                      explanation.rule as String,
                      style: GoogleFonts.nunito(
                          color: Colors.white, fontSize: 14, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Örnekler
                  _Section(
                    icon: '✍️',
                    title: 'Örnekler',
                    color: const Color(0xFF7C4DFF),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (explanation.examples as List<String>)
                          .map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('→ ',
                                        style: TextStyle(
                                            color: Color(0xFF7C4DFF),
                                            fontWeight: FontWeight.bold)),
                                    Expanded(
                                      child: Text(e,
                                          style: GoogleFonts.nunito(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontStyle: FontStyle.italic)),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Sık yapılan hatalar
                  _Section(
                    icon: '⚠️',
                    title: 'Sık Yapılan Hatalar',
                    color: Colors.orangeAccent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (explanation.commonMistakes as List<String>)
                          .map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ',
                                        style: TextStyle(
                                            color: Colors.orangeAccent,
                                            fontWeight: FontWeight.bold)),
                                    Expanded(
                                      child: Text(e,
                                          style: GoogleFonts.nunito(
                                              color: Colors.white70,
                                              fontSize: 13)),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // İpucu banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF26A69A), Color(0xFF00BFA5)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Text('🎯', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            explanation.tip as String,
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String icon;
  final String title;
  final Color color;
  final Widget child;

  const _Section({
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A3A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.nunito(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}