import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/collection/models/card_dto.dart';
import 'sprite_animation_widget.dart';

/// Shown after a quiz is completed when a card drop occurs.
///
/// Usage:
/// ```dart
/// CardDropAnimation.show(context, drop: drop);
/// ```
class CardDropAnimation extends StatefulWidget {
  final CardDropResult drop;

  const CardDropAnimation({super.key, required this.drop});

  static Future<void> show(BuildContext context,
      {required CardDropResult drop}) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => CardDropAnimation(drop: drop),
      transitionBuilder: (context, anim, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeIn),
        child: child,
      ),
    );
  }

  @override
  State<CardDropAnimation> createState() => _CardDropAnimationState();
}

class _CardDropAnimationState extends State<CardDropAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _flipController;
  late final AnimationController _glowController;
  late final Animation<double> _flipAnim;
  late final Animation<double> _glow;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _flipAnim =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));

    _glow = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _flipController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _revealCard() {
    if (_revealed) return;
    setState(() => _revealed = true);
    _flipController.forward();
  }

  Color _rarityColor() {
    switch (widget.drop.rarity) {
      case 'rare':
        return const Color(0xFF1565C0);
      case 'epic':
        return const Color(0xFF6A1B9A);
      case 'legendary':
        return const Color(0xFFFF8F00);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  String _rarityLabel() {
    switch (widget.drop.rarity) {
      case 'rare':
        return '💙 Nadir Kart!';
      case 'epic':
        return '💜 Epik Kart!';
      case 'legendary':
        return '🌟 EFSANE KART!';
      default:
        return '🟢 Yeni Kart!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = _rarityColor();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              _revealed ? '🎊 YENİ KART!' : '🎁 Kart Açılıyor...',
              style: GoogleFonts.luckiestGuy(
                fontSize: 24,
                color: Colors.white,
                shadows: const [
                  Shadow(
                      color: Color(0xFF7B61FF),
                      blurRadius: 12,
                      offset: Offset(0, 3))
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Flip card
            GestureDetector(
              onTap: _revealCard,
              child: AnimatedBuilder(
                animation: _flipAnim,
                builder: (_, __) {
                  final angle = _flipAnim.value * 3.14159;
                  final isBack = angle > 1.5708; // π/2

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(isBack ? angle - 3.14159 : angle),
                    child: isBack
                        ? _RevealedCard(drop: widget.drop, color: rarityColor)
                        : _CardBack(rarityColor: rarityColor, glow: _glow),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            // Tap hint / dismiss
            if (!_revealed)
              Column(
                children: [
                  AnimatedBuilder(
                    animation: _glow,
                    builder: (_, __) => Opacity(
                      opacity: _glow.value,
                      child: Text(
                        'Kartına Dokun! 👆',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Text(
                    _rarityLabel(),
                    style: GoogleFonts.luckiestGuy(
                      fontSize: 16,
                      color: rarityColor,
                      shadows: [
                        Shadow(
                            color: rarityColor.withOpacity(0.5),
                            blurRadius: 8)
                      ],
                    ),
                  ),
                  if (widget.drop.isNew) ...[
                    const SizedBox(height: 4),
                    Text('✨ İlk kez kazandın!',
                        style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ],
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF5C4ECC),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF9C8FFF),
                              Color(0xFF7B61FF),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          'DEVAM ET',
                          style: GoogleFonts.luckiestGuy(
                              color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  final Color rarityColor;
  final Animation<double> glow;

  const _CardBack({required this.rarityColor, required this.glow});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glow,
      builder: (_, __) => Container(
        width: 180,
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5C4ECC), Color(0xFF7B61FF)],
          ),
          boxShadow: [
            BoxShadow(
              color: rarityColor.withOpacity(glow.value * 0.6),
              blurRadius: 24 * glow.value,
              spreadRadius: 4 * glow.value,
            ),
          ],
          border: Border.all(
              color: Colors.white.withOpacity(0.3 + glow.value * 0.3),
              width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Yürüyen karakter animasyonu
            SpriteAnimationWidget(
              animation: HeroAnimation.walk,
              size: 80,
              fps: 10,
            ),
            const SizedBox(height: 8),
            Text(
              '?',
              style: GoogleFonts.luckiestGuy(
                  fontSize: 36, color: Colors.white.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevealedCard extends StatelessWidget {
  final CardDropResult drop;
  final Color color;

  const _RevealedCard({required this.drop, required this.color});

  String _seriesEmoji() {
    if (drop.imageAsset.contains('animals')) return '🐾';
    if (drop.imageAsset.contains('heroes')) return '⚔️';
    if (drop.imageAsset.contains('legends')) return '💫';
    return '🃏';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.6), width: 3),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 24,
              spreadRadius: 4),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: _tryImage(drop.imageAsset, _seriesEmoji()),
            ),
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      drop.cardName,
                      style: GoogleFonts.nunito(
                          color: const Color(0xFF1A1A2E),
                          fontWeight: FontWeight.w800,
                          fontSize: 11),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tryImage(String asset, String emoji) {
    try {
      return Image.asset(asset, fit: BoxFit.cover, width: double.infinity,
          errorBuilder: (_, __, ___) {
        return Container(
          color: const Color(0xFFF0EEF8),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 40))),
        );
      });
    } catch (_) {
      return Container(
        color: const Color(0xFFF0EEF8),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 40))),
      );
    }
  }
}
