import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/ad_service.dart';
import '../models/flashcard_models.dart';

class FlashcardSessionResultScreen extends StatefulWidget {
  final FlashcardSessionResult result;

  const FlashcardSessionResultScreen({
    super.key,
    required this.result,
  });

  @override
  State<FlashcardSessionResultScreen> createState() =>
      _FlashcardSessionResultScreenState();
}

class _FlashcardSessionResultScreenState
    extends State<FlashcardSessionResultScreen>
    with SingleTickerProviderStateMixin {
  late final ConfettiController _confetti;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.55, 1.0],
    colors: [Color(0xFF7B1FA2), Color(0xFF4A148C), Color(0xFF1A0030)],
  );

  bool get _isPerfect =>
      widget.result.learnedCount == widget.result.totalCards &&
      widget.result.totalCards > 0;

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
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: _gradient),
          child: SafeArea(
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
                      Color(0xFFCE93D8),
                      Color(0xFFF48FB1),
                      Color(0xFF80DEEA),
                      Color(0xFFFFF176),
                      Color(0xFFA5D6A7),
                    ],
                  ),
                ),
                // Main content
                Column(
                  children: [
                    const SizedBox(height: 32),
                    _buildEmoji(),
                    const SizedBox(height: 20),
                    _buildTitle(),
                    const SizedBox(height: 32),
                    _buildStatsCard(),
                    if (widget.result.isFirstCompletion) ...[
                      const SizedBox(height: 20),
                      _buildCoinBanner(),
                    ],
                    const Spacer(),
                    _buildButtons(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmoji() {
    final emoji = _isPerfect ? '🏆' : widget.result.learnedCount > 0 ? '⭐' : '💪';
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Text(emoji, style: const TextStyle(fontSize: 72)),
    );
  }

  Widget _buildTitle() {
    final title = _isPerfect
        ? 'Mükemmel!'
        : widget.result.learnedCount > widget.result.totalCards / 2
            ? 'Harika gidiyorsun!'
            : 'Devam et!';
    final subtitle = _isPerfect
        ? 'Tüm kartları öğrendin!'
        : '${widget.result.learnedCount} / ${widget.result.totalCards} kart öğrenildi';

    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.luckiestGuy(
            fontSize: 34,
            color: Colors.white,
            shadows: const [
              Shadow(
                  blurRadius: 0,
                  color: Color(0xFF1A0030),
                  offset: Offset(2, 2)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.nunito(
              fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    final progress = widget.result.totalCards > 0
        ? widget.result.learnedCount / widget.result.totalCards
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border:
              Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF66BB6A),
                  value: '${widget.result.learnedCount}',
                  label: 'Öğrenildi',
                ),
                Container(
                    width: 1,
                    height: 48,
                    color: Colors.white.withOpacity(0.15)),
                _StatItem(
                  icon: Icons.style_rounded,
                  color: const Color(0xFFCE93D8),
                  value: '${widget.result.totalCards}',
                  label: 'Toplam',
                ),
                Container(
                    width: 1,
                    height: 48,
                    color: Colors.white.withOpacity(0.15)),
                _StatItem(
                  icon: Icons.bar_chart_rounded,
                  color: const Color(0xFF80DEEA),
                  value: '${(progress * 100).round()}%',
                  label: 'Başarı',
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.white.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _isPerfect ? const Color(0xFF66BB6A) : const Color(0xFFCE93D8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFA000), Color(0xFFFF6F00)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.orange.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'İlk tamamlama bonusu!',
                  style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70),
                ),
                Text(
                  '+${widget.result.starEarned} Yıldız Kazandın',
                  style: GoogleFonts.luckiestGuy(
                      fontSize: 18, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Tekrar çalış
          if (!_isPerfect)
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.purple.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Text(
                  '🔄  Tekrar Çalış',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
              ),
            ),
          if (!_isPerfect) const SizedBox(height: 12),
          // Deste listesine dön / Ana sayfaya git
          GestureDetector(
            onTap: () => _isPerfect
                ? AdService.showInterstitialAd(
                    onComplete: () {
                      if (context.mounted) context.go('/dashboard');
                    },
                  )
                : context.pop(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: Colors.white.withOpacity(0.25), width: 1.5),
              ),
              child: Text(
                _isPerfect ? '🏠  Ana Sayfaya Git' : '📚  Deste Listesine Dön',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
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
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(value,
            style: GoogleFonts.luckiestGuy(fontSize: 22, color: Colors.white)),
        Text(label,
            style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white54)),
      ],
    );
  }
}
