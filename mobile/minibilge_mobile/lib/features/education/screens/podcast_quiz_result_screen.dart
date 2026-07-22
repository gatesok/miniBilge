import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../flashcard/providers/flashcard_provider.dart';
import '../models/podcast_quiz_models.dart';
import '../../../core/services/ad_service.dart';

class PodcastQuizResultScreen extends ConsumerStatefulWidget {
  final PodcastQuizResult result;
  final String episodeId;

  const PodcastQuizResultScreen({
    super.key,
    required this.result,
    required this.episodeId,
  });

  @override
  ConsumerState<PodcastQuizResultScreen> createState() => _PodcastQuizResultScreenState();
}

class _PodcastQuizResultScreenState extends ConsumerState<PodcastQuizResultScreen>
    with SingleTickerProviderStateMixin {
  bool _loadingFlashcard = false;
  late final ConfettiController _confetti;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  static const _bgColor = Color(0xFF0D1B2A);
  static const _accentColor = Color(0xFF26A69A);

  bool get _isPerfect =>
      widget.result.correctCount == widget.result.totalQuestions &&
      widget.result.totalQuestions > 0;

  double get _successRate => widget.result.totalQuestions > 0
      ? widget.result.correctCount / widget.result.totalQuestions
      : 0;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4));
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaleController.forward();
      if (_isPerfect || widget.result.isFirstCompletion) {
        _confetti.play();
      }
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: SafeArea(
          child: Stack(
            children: [
              // Confetti
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirection: math.pi / 2,
                  maxBlastForce: 20,
                  minBlastForce: 8,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  gravity: 0.2,
                  colors: const [
                    Color(0xFF26A69A),
                    Color(0xFFF48FB1),
                    Color(0xFF80DEEA),
                    Color(0xFFFFF176),
                    Color(0xFFA5D6A7),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    _buildEmoji(),
                    const SizedBox(height: 16),
                    _buildTitle(),
                    const SizedBox(height: 28),
                    _buildStatsCard(),
                    if (widget.result.isFirstCompletion) ...[
                      const SizedBox(height: 16),
                      _buildRewardBanner(),
                    ],
                    const SizedBox(height: 16),
                    _buildAnswerList(),
                    const SizedBox(height: 24),
                    _buildButtons(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmoji() {
    final emoji = _isPerfect
        ? '🏆'
        : _successRate >= 0.6
            ? '⭐'
            : '💪';
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Text(emoji, style: const TextStyle(fontSize: 72)),
    );
  }

  Widget _buildTitle() {
    final title = _isPerfect
        ? 'Mükemmel!'
        : _successRate >= 0.6
            ? 'Harika gidiyorsun!'
            : 'Devam et!';
    final subtitle = '${widget.result.correctCount} / ${widget.result.totalQuestions} doğru cevap';

    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.luckiestGuy(
            fontSize: 32,
            color: Colors.white,
            shadows: const [
              Shadow(blurRadius: 0, color: Color(0xFF0D1B2A), offset: Offset(2, 2)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: GoogleFonts.nunito(
              fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white60),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2D3E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  icon: Icons.check_circle_rounded,
                  color: _accentColor,
                  value: '${widget.result.correctCount}',
                  label: 'Doğru',
                ),
                Container(width: 1, height: 48, color: Colors.white12),
                _StatItem(
                  icon: Icons.cancel_rounded,
                  color: const Color(0xFFEF5350),
                  value: '${widget.result.totalQuestions - widget.result.correctCount}',
                  label: 'Yanlış',
                ),
                Container(width: 1, height: 48, color: Colors.white12),
                _StatItem(
                  icon: Icons.bar_chart_rounded,
                  color: const Color(0xFF80DEEA),
                  value: '${(_successRate * 100).round()}%',
                  label: 'Başarı',
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _successRate,
                minHeight: 8,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _isPerfect ? _accentColor : const Color(0xFF26A69A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF26A69A), Color(0xFF00695C)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _accentColor.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'İlk tamamlama bonusu!',
                  style: GoogleFonts.nunito(
                      fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white70),
                ),
                Text(
                  '+${widget.result.starsEarned} Yıldız  •  +${widget.result.coinsEarned} Coin',
                  style: GoogleFonts.luckiestGuy(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerList() {
    if (widget.result.answerResults.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cevaplar',
            style: GoogleFonts.nunito(
                fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white38),
          ),
          const SizedBox(height: 8),
          ...widget.result.answerResults.take(5).map((r) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: r.isCorrect
                      ? _accentColor.withOpacity(0.12)
                      : const Color(0xFFEF5350).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: r.isCorrect
                        ? _accentColor.withOpacity(0.3)
                        : const Color(0xFFEF5350).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      r.isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: r.isCorrect ? _accentColor : const Color(0xFFEF5350),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        r.isCorrect
                            ? 'Doğru!'
                            : 'Doğru cevap: ${r.correctAnswer}',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Future<void> _goToFlashcards(BuildContext context) async {
    setState(() => _loadingFlashcard = true);
    try {
      final deck = await ref
          .read(flashcardDeckByEpisodeProvider(widget.episodeId).future);
      if (!context.mounted) return;
      if (deck != null) {
        context.push('/flashcard/study/${deck.id}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bu podcast için henüz flashcard eklenmemiş.'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flashcard yüklenirken hata oluştu.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingFlashcard = false);
    }
  }

  Widget _buildButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Flashcard butonu
          GestureDetector(
            onTap: _loadingFlashcard ? null : () => _goToFlashcards(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF26A69A), Color(0xFF00695C)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: _accentColor.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _loadingFlashcard
                  ? const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  : _buttonRow('🃏', 'Flashcard\'lara Bak', Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          // Tekrar çöz
          GestureDetector(
            onTap: () {
              AdService.showInterstitialAd(
                placement: AdPlacements.podcastQuizResult,
                onComplete: () {
                  if (!context.mounted) return;
                  context.pop();
                  context.push('/podcast/quiz/${widget.episodeId}');
                },
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: _accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _accentColor.withOpacity(0.4), width: 1.5),
              ),
              child: _buttonRow('🔄', 'Tekrar Çöz', _accentColor),
            ),
          ),
          const SizedBox(height: 12),
          // Ana sayfa
          GestureDetector(
            onTap: () => AdService.showInterstitialAd(
              placement: AdPlacements.podcastQuizResult,
              onComplete: () {
                if (context.mounted) context.go('/dashboard');
              },
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
              ),
              child: _buttonRow('🏠', 'Ana Sayfaya Git', Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buttonRow(String emoji, String label, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(emoji, style: const TextStyle(fontSize: 18)),
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
                fontSize: 16, fontWeight: FontWeight.w800, color: color),
          ),
        ),
        const SizedBox(width: 28),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.luckiestGuy(fontSize: 20, color: Colors.white)),
        Text(label,
            style: GoogleFonts.nunito(
                fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white54)),
      ],
    );
  }
}
