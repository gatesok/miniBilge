import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Full-screen overlay shown when a badge is earned.
///
/// Usage:
/// ```dart
/// BadgeEarnedOverlay.show(
///   context,
///   emoji: '🔥',
///   name: 'Ateş Topu',
///   description: '5 gün arka arkaya quiz tamamla',
///   rarity: 'gold',
/// );
/// ```
class BadgeEarnedOverlay extends StatefulWidget {
  final String emoji;
  final String name;
  final String description;
  final String rarity;

  const BadgeEarnedOverlay({
    super.key,
    required this.emoji,
    required this.name,
    required this.description,
    required this.rarity,
  });

  static Future<void> show(
    BuildContext context, {
    required String emoji,
    required String name,
    required String description,
    required String rarity,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'badge-earned',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => BadgeEarnedOverlay(
        emoji: emoji,
        name: name,
        description: description,
        rarity: rarity,
      ),
      transitionBuilder: (context, anim, _, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }

  @override
  State<BadgeEarnedOverlay> createState() => _BadgeEarnedOverlayState();
}

class _BadgeEarnedOverlayState extends State<BadgeEarnedOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _shimmerController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _pulse = Tween<double>(begin: 0.95, end: 1.08).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Color _rarityColor() {
    switch (widget.rarity) {
      case 'silver':
        return const Color(0xFF78909C);
      case 'gold':
        return const Color(0xFFFFB300);
      case 'legendary':
        return const Color(0xFF7B61FF);
      default:
        return const Color(0xFF8D6E63);
    }
  }

  String _rarityLabel() {
    switch (widget.rarity) {
      case 'silver':
        return '🥈 Gümüş Rozet';
      case 'gold':
        return '🥇 Altın Rozet';
      case 'legendary':
        return '💎 Efsane Rozet';
      default:
        return '🥉 Bronz Rozet';
    }
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = _rarityColor();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF5C4ECC),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // "YENİ ROZET!" banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [rarityColor, rarityColor.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '🎉 YENİ ROZET KAZANILDI!',
                      style: GoogleFonts.luckiestGuy(
                          color: Colors.white, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Pulsing emoji
                  ScaleTransition(
                    scale: _pulse,
                    child: Text(widget.emoji,
                        style: const TextStyle(fontSize: 80)),
                  ),
                  const SizedBox(height: 16),
                  // Badge name
                  Text(
                    widget.name,
                    style: GoogleFonts.luckiestGuy(
                        fontSize: 22, color: const Color(0xFF1A1A2E)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    widget.description,
                    style: GoogleFonts.nunito(
                      color: const Color(0xFF616161),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Rarity pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: rarityColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _rarityLabel(),
                      style: GoogleFonts.nunito(
                        color: rarityColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Dismiss button
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
                            colors: [Color(0xFF9C8FFF), Color(0xFF7B61FF)],
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          'HARIKA! 🎊',
                          style: GoogleFonts.luckiestGuy(
                              color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
