import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/vocab_challenge_models.dart';

class VocabResultScreen extends StatefulWidget {
  final VocabChallengeResult result;
  final List<String> targetWords;
  final String level;

  const VocabResultScreen({
    super.key,
    required this.result,
    required this.targetWords,
    required this.level,
  });

  @override
  State<VocabResultScreen> createState() => _VocabResultScreenState();
}

class _VocabResultScreenState extends State<VocabResultScreen> {
  static const _bgColor = Color(0xFF0D1B2A);
  static const _cardColor = Color(0xFF1A2A3A);

  late final ConfettiController _confetti;

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

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    if (_isExcellent) _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Sonuç',
            style: GoogleFonts.nunito(
                color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54),
            onPressed: () =>
                context.canPop() ? context.pop() : context.goNamed('dashboard'),
          ),
        ],
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 20,
              colors: const [
                Color(0xFF00BFA5), Color(0xFF7C4DFF),
                Color(0xFFFFB300), Color(0xFFEF5350),
              ],
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 8),
                // Skor
                Text(_emoji, style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 8),
                Text(
                  '${widget.result.score}',
                  style: GoogleFonts.luckiestGuy(
                      color: _scoreColor, fontSize: 72),
                ),
                Text('/ 100',
                    style: GoogleFonts.nunito(
                        color: Colors.white38, fontSize: 16)),
                const SizedBox(height: 24),

                // Hedef kelime kullanımı
                _SectionCard(
                  title: '🎯 Hedef Kelimeler',
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: widget.targetWords.map((word) {
                      final used =
                          widget.result.targetWordUsage[word] ?? false;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: used
                              ? const Color(0xFF00BFA5).withOpacity(0.15)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: used
                                ? const Color(0xFF00BFA5)
                                : Colors.red.shade400,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              used ? Icons.check_circle : Icons.cancel,
                              color: used
                                  ? const Color(0xFF00BFA5)
                                  : Colors.red.shade400,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(word,
                                style: GoogleFonts.nunito(
                                    color: used
                                        ? const Color(0xFF00BFA5)
                                        : Colors.red.shade300,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Genel geri bildirim
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF26A69A), Color(0xFF00BFA5)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💬', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(widget.result.feedback,
                            style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                height: 1.5)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Düzeltmeler
                if (widget.result.corrections.isNotEmpty) ...[
                  _SectionCard(
                    title: '✏️ Düzeltmeler',
                    child: Column(
                      children:
                          widget.result.corrections.map((correction) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.close,
                                      color: Colors.redAccent, size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(correction.original,
                                        style: GoogleFonts.nunito(
                                            color: Colors.redAccent,
                                            fontSize: 13,
                                            decoration:
                                                TextDecoration.lineThrough)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check,
                                      color: Color(0xFF00BFA5), size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(correction.suggestion,
                                        style: GoogleFonts.nunito(
                                            color: const Color(0xFF00BFA5),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                ],
                              ),
                              if (correction.explanation.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Padding(
                                  padding: const EdgeInsets.only(left: 22),
                                  child: Text(correction.explanation,
                                      style: GoogleFonts.nunito(
                                          color: Colors.white54, fontSize: 12)),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Ödül
                if (widget.result.coinsEarned > 0 ||
                    widget.result.starsEarned > 0) ...[
                  _SectionCard(
                    title: '🎁 Kazanılan',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.result.coinsEarned > 0)
                          _RewardBadge(
                              icon: '🪙',
                              label: '+${widget.result.coinsEarned}'),
                        if (widget.result.coinsEarned > 0 &&
                            widget.result.starsEarned > 0)
                          const SizedBox(width: 16),
                        if (widget.result.starsEarned > 0)
                          _RewardBadge(
                              icon: '⭐',
                              label: '+${widget.result.starsEarned}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Butonlar
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('Tekrar Oyna',
                            style: GoogleFonts.nunito(
                                color: Colors.white70,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.goNamed('dashboard'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BFA5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('Ana Sayfa',
                            style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A3A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.nunito(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _RewardBadge extends StatelessWidget {
  final String icon;
  final String label;
  const _RewardBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('$icon $label',
          style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16)),
    );
  }
}
