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
      pageBuilder: (_, _, _) => BadgeEarnedOverlay(
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
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
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
    final mediaSize = MediaQuery.sizeOf(context);
    final isTablet = mediaSize.shortestSide >= 600;
    final scale = isTablet
        ? (mediaSize.shortestSide / 600).clamp(1.2, 1.45)
        : 1.0;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 48 : 32,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 560 : double.infinity,
            ),
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF5C4ECC),
                  borderRadius: BorderRadius.circular(28 * scale),
                ),
                child: Container(
                  margin: EdgeInsets.only(bottom: 6 * scale),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28 * scale),
                  ),
                  padding: EdgeInsets.all(28 * scale),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // "YENİ ROZET!" banner
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16 * scale,
                          vertical: 6 * scale,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              rarityColor,
                              rarityColor.withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20 * scale),
                        ),
                        child: Text(
                          '🎉 YENİ ROZET KAZANILDI!',
                          style: GoogleFonts.luckiestGuy(
                            color: Colors.white,
                            fontSize: 13 * scale,
                          ),
                        ),
                      ),
                      SizedBox(height: 20 * scale),
                      // Pulsing emoji
                      ScaleTransition(
                        scale: _pulse,
                        child: Text(
                          widget.emoji,
                          style: TextStyle(fontSize: 80 * scale),
                        ),
                      ),
                      SizedBox(height: 16 * scale),
                      // Badge name
                      Text(
                        widget.name,
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 22 * scale,
                          color: const Color(0xFF1A1A2E),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8 * scale),
                      // Description
                      Text(
                        widget.description,
                        style: GoogleFonts.nunito(
                          color: const Color(0xFF616161),
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16 * scale),
                      // Rarity pill
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14 * scale,
                          vertical: 6 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: rarityColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20 * scale),
                        ),
                        child: Text(
                          _rarityLabel(),
                          style: GoogleFonts.nunito(
                            color: rarityColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 13 * scale,
                          ),
                        ),
                      ),
                      SizedBox(height: 24 * scale),
                      // Dismiss button
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF5C4ECC),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 5 * scale),
                            padding: EdgeInsets.symmetric(
                              horizontal: 40 * scale,
                              vertical: 14 * scale,
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
                              'HARIKA! 🎊',
                              style: GoogleFonts.luckiestGuy(
                                color: Colors.white,
                                fontSize: 16 * scale,
                              ),
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
        ),
      ),
    );
  }
}
