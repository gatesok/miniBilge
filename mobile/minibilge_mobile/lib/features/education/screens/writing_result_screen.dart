import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/writing_models.dart';
import '../providers/writing_provider.dart';

class WritingResultScreen extends ConsumerStatefulWidget {
  final WritingEvaluationResult result;
  final String level;

  const WritingResultScreen({
    super.key,
    required this.result,
    required this.level,
  });

  @override
  ConsumerState<WritingResultScreen> createState() =>
      _WritingResultScreenState();
}

class _WritingResultScreenState extends ConsumerState<WritingResultScreen>
    with SingleTickerProviderStateMixin {
  static const _bgColor = Color(0xFF0D1B2A);
  static const _cardColor = Color(0xFF1A2A3A);

  late final ConfettiController _confetti;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  bool get _isExcellent => widget.result.score >= 80;
  bool get _isGood => widget.result.score >= 50;

  Color get _scoreColor {
    if (_isExcellent) return const Color(0xFF26A69A);
    if (_isGood) return const Color(0xFFFFB300);
    return const Color(0xFFEF5350);
  }

  String get _emoji {
    if (_isExcellent) return '🏆';
    if (_isGood) return '⭐';
    return '💪';
  }

  String get _title {
    if (_isExcellent) return 'Harika iş!';
    if (_isGood) return 'İyi gidiyorsun!';
    return 'Devam et!';
  }

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
      if (_isExcellent) _confetti.play();
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
                    Color(0xFF7C4DFF),
                    Color(0xFF26A69A),
                    Color(0xFF80DEEA),
                    Color(0xFFFFF176),
                    Color(0xFFF48FB1),
                  ],
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 36),
                    _buildScoreHero(),
                    const SizedBox(height: 24),
                    _buildFeedbackCard(),
                    if (widget.result.corrections.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildCorrectionsCard(),
                    ],
                    if (widget.result.coinsEarned > 0 ||
                        widget.result.starsEarned > 0) ...[
                      const SizedBox(height: 16),
                      _buildRewardBanner(),
                    ],
                    const SizedBox(height: 28),
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

  // ─── Score Hero ──────────────────────────────────────────────────────────────

  Widget _buildScoreHero() {
    return Column(
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: Text(_emoji, style: const TextStyle(fontSize: 64)),
        ),
        const SizedBox(height: 12),
        Text(
          _title,
          style: GoogleFonts.luckiestGuy(
            fontSize: 30,
            color: Colors.white,
            shadows: const [
              Shadow(
                blurRadius: 0,
                color: Color(0xFF0D1B2A),
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Skor dairesi
        ScaleTransition(
          scale: _scaleAnimation,
          child: SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: widget.result.score / 100,
                    strokeWidth: 10,
                    backgroundColor: Colors.white12,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(_scoreColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.result.score}',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '/ 100',
                      style: GoogleFonts.nunito(
                          color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Seviye: ${widget.level}',
          style: GoogleFonts.nunito(
              color: Colors.white38, fontSize: 13),
        ),
      ],
    );
  }

  // ─── Feedback ────────────────────────────────────────────────────────────────

  Widget _buildFeedbackCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💬', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Geri Bildirim',
                style: GoogleFonts.nunito(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.result.feedback,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Corrections ─────────────────────────────────────────────────────────────

  Widget _buildCorrectionsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✏️', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Düzeltmeler',
                style: GoogleFonts.nunito(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.result.corrections.length}',
                  style: GoogleFonts.nunito(
                      color: Colors.white60, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.result.corrections.map(
            (c) => _CorrectionTile(correction: c),
          ),
        ],
      ),
    );
  }

  // ─── Reward Banner ───────────────────────────────────────────────────────────

  Widget _buildRewardBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7C4DFF).withOpacity(0.3),
            const Color(0xFF26A69A).withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF7C4DFF).withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.result.coinsEarned > 0) ...[
            const Text('🪙', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 6),
            Text(
              '+${widget.result.coinsEarned}',
              style: GoogleFonts.nunito(
                color: const Color(0xFFFFD700),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          if (widget.result.coinsEarned > 0 && widget.result.starsEarned > 0)
            const SizedBox(width: 20),
          if (widget.result.starsEarned > 0) ...[
            const Text('⭐', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 6),
            Text(
              '+${widget.result.starsEarned}',
              style: GoogleFonts.nunito(
                color: const Color(0xFFFFF176),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Buttons ─────────────────────────────────────────────────────────────────

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        // Tekrar Dene
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C4DFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              ref.read(writingProvider.notifier).reset();
              // pop result + pop writing-practice → yeni writing-practice push
              while (context.canPop()) {
                context.pop();
              }
              context.pushNamed(
                'writing-practice',
                queryParameters: {'level': widget.level},
              );
            },
            child: Text(
              '✍️  Tekrar Dene',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Ana Sayfa
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              ref.read(writingProvider.notifier).reset();
              context.goNamed('dashboard');
            },
            child: Text(
              'Ana Sayfa',
              style: GoogleFonts.nunito(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Correction Tile ─────────────────────────────────────────────────────────

class _CorrectionTile extends StatelessWidget {
  final WritingCorrection correction;

  const _CorrectionTile({required this.correction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Orijinal → Düzeltme
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: correction.original,
                        style: GoogleFonts.nunito(
                          color: const Color(0xFFEF5350),
                          fontSize: 13,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: const Color(0xFFEF5350),
                        ),
                      ),
                      const TextSpan(text: '  →  '),
                      TextSpan(
                        text: correction.suggestion,
                        style: GoogleFonts.nunito(
                          color: const Color(0xFF26A69A),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Açıklama
          Text(
            correction.explanation,
            style: GoogleFonts.nunito(
              color: Colors.white54,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
