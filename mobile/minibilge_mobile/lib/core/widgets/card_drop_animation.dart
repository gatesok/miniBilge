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

  static Future<void> show(
    BuildContext context, {
    required CardDropResult drop,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, _, _) => CardDropAnimation(drop: drop),
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

    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _glow = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
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
        return 'Nadir Kart';
      case 'epic':
        return 'Epik Kart';
      case 'legendary':
        return 'Efsane Kart';
      default:
        return 'Yeni Kart';
    }
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = _rarityColor();
    final mediaSize = MediaQuery.sizeOf(context);
    final isTablet = mediaSize.shortestSide >= 600;
    final tabletScale = isTablet
        ? (mediaSize.shortestSide / 560).clamp(1.25, 1.55)
        : 1.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: isTablet ? 36 : 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _revealed
                          ? Icons.auto_awesome_rounded
                          : Icons.style_rounded,
                      color: Colors.white,
                      size: 30 * tabletScale,
                    ),
                    SizedBox(width: 8 * tabletScale),
                    Text(
                      _revealed ? 'YENİ KART!' : 'Kart Açılıyor...',
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 24 * tabletScale,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            color: Color(0xFF7B61FF),
                            blurRadius: 12,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32 * tabletScale),
                // Flip card
                GestureDetector(
                  onTap: _revealCard,
                  child: AnimatedBuilder(
                    animation: _flipAnim,
                    builder: (_, _) {
                      final angle = _flipAnim.value * 3.14159;
                      final isBack = angle > 1.5708; // π/2

                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(isBack ? angle - 3.14159 : angle),
                        child: isBack
                            ? _RevealedCard(
                                drop: widget.drop,
                                color: rarityColor,
                                scale: tabletScale,
                              )
                            : _CardBack(
                                rarityColor: rarityColor,
                                glow: _glow,
                                scale: tabletScale,
                              ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 32 * tabletScale),
                // Tap hint / dismiss
                if (!_revealed)
                  AnimatedBuilder(
                    animation: _glow,
                    builder: (_, _) => Opacity(
                      opacity: _glow.value,
                      child: Text(
                        'Kartına Dokun!',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16 * tabletScale,
                        ),
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _rarityIcon(),
                            color: rarityColor,
                            size: 21 * tabletScale,
                          ),
                          SizedBox(width: 6 * tabletScale),
                          Text(
                            _rarityLabel(),
                            style: GoogleFonts.luckiestGuy(
                              fontSize: 16 * tabletScale,
                              color: rarityColor,
                              shadows: [
                                Shadow(
                                  color: rarityColor.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (widget.drop.isNew) ...[
                        SizedBox(height: 4 * tabletScale),
                        Text(
                          'İlk kez kazandın!',
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13 * tabletScale,
                          ),
                        ),
                      ],
                      if (!widget.drop.isNew &&
                          widget.drop.shardsAwarded > 0) ...[
                        SizedBox(height: 4 * tabletScale),
                        Text(
                          'Kopya kart: +${widget.drop.shardsAwarded} parça',
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13 * tabletScale,
                          ),
                        ),
                      ],
                      SizedBox(height: 4 * tabletScale),
                      Text(
                        'Bugün ${widget.drop.dailyRemaining} kart hakkın kaldı'
                        ' • Garantiye ${widget.drop.pityRemaining}',
                        style: GoogleFonts.nunito(
                          color: Colors.white70,
                          fontWeight: FontWeight.w700,
                          fontSize: 11 * tabletScale,
                        ),
                      ),
                      SizedBox(height: 20 * tabletScale),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF5C4ECC),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 5 * tabletScale),
                            padding: EdgeInsets.symmetric(
                              horizontal: 40 * tabletScale,
                              vertical: 14 * tabletScale,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFF9C8FFF), Color(0xFF7B61FF)],
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              'DEVAM ET',
                              style: GoogleFonts.luckiestGuy(
                                color: Colors.white,
                                fontSize: 16 * tabletScale,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _rarityIcon() {
    switch (widget.drop.rarity) {
      case 'rare':
        return Icons.water_drop_rounded;
      case 'epic':
        return Icons.bolt_rounded;
      case 'legendary':
        return Icons.diamond_rounded;
      default:
        return Icons.style_rounded;
    }
  }
}

class _CardBack extends StatelessWidget {
  final Color rarityColor;
  final Animation<double> glow;
  final double scale;

  const _CardBack({
    required this.rarityColor,
    required this.glow,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glow,
      builder: (_, _) => Container(
        width: 180 * scale,
        height: 240 * scale,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20 * scale),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5C4ECC), Color(0xFF7B61FF)],
          ),
          boxShadow: [
            BoxShadow(
              color: rarityColor.withValues(alpha: glow.value * 0.6),
              blurRadius: 24 * glow.value * scale,
              spreadRadius: 4 * glow.value * scale,
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3 + glow.value * 0.3),
            width: 2 * scale,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Yürüyen karakter animasyonu
            SpriteAnimationWidget(
              animation: HeroAnimation.walk,
              size: 80 * scale,
              fps: 10,
            ),
            SizedBox(height: 8 * scale),
            Text(
              '?',
              style: GoogleFonts.luckiestGuy(
                fontSize: 36 * scale,
                color: Colors.white.withValues(alpha: 0.6),
              ),
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
  final double scale;

  const _RevealedCard({
    required this.drop,
    required this.color,
    required this.scale,
  });

  IconData _seriesIcon() {
    if (drop.imageAsset.contains('animals')) return Icons.pets_rounded;
    if (drop.imageAsset.contains('heroes')) return Icons.shield_rounded;
    if (drop.imageAsset.contains('legends')) return Icons.auto_awesome_rounded;
    return Icons.style_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180 * scale,
      height: 240 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: color.withValues(alpha: 0.6),
          width: 3 * scale,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 24 * scale,
            spreadRadius: 4 * scale,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17 * scale),
        child: Column(
          children: [
            Expanded(flex: 3, child: _tryImage(drop.imageAsset, _seriesIcon())),
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 8 * scale,
                  vertical: 4 * scale,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      drop.cardName,
                      style: GoogleFonts.nunito(
                        color: const Color(0xFF1A1A2E),
                        fontWeight: FontWeight.w800,
                        fontSize: 11 * scale,
                      ),
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

  Widget _tryImage(String asset, IconData fallbackIcon) {
    try {
      return Image.asset(
        asset,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, _, _) {
          return Container(
            color: const Color(0xFFF0EEF8),
            child: Center(
              child: Icon(
                fallbackIcon,
                color: const Color(0xFF7B61FF),
                size: 56 * scale,
              ),
            ),
          );
        },
      );
    } catch (_) {
      return Container(
        color: const Color(0xFFF0EEF8),
        child: Center(
          child: Icon(
            fallbackIcon,
            color: const Color(0xFF7B61FF),
            size: 56 * scale,
          ),
        ),
      );
    }
  }
}
