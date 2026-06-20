import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shown when English subject is tapped from Dashboard.
/// User picks a CEFR level → forwarded to TopicSelectionScreen filtered by that level.
class EnglishLevelSelectScreen extends StatelessWidget {
  final String subjectId;
  final String subjectName;

  const EnglishLevelSelectScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  static const _levels = [
    (1, 'A1', 'Başlangıç', [Color(0xFF66BB6A), Color(0xFF2E7D32)], Color(0xFF1B5E20)),
    (2, 'A2', 'Temel', [Color(0xFF26A69A), Color(0xFF00695C)], Color(0xFF004D40)),
    (3, 'B1', 'Orta Altı', [Color(0xFF29B6F6), Color(0xFF0277BD)], Color(0xFF01579B)),
    (4, 'B2', 'Orta', [Color(0xFF7E57C2), Color(0xFF4527A0)], Color(0xFF311B92)),
    (5, 'C1', 'Orta Üstü', [Color(0xFFEF5350), Color(0xFFB71C1C)], Color(0xFF7F0000)),
    (6, 'C2', 'Ustalık', [Color(0xFFFF7043), Color(0xFFBF360C)], Color(0xFF7B2400)),
  ];

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.55, 1.0],
    colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.28),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1.5),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Seviye Seç',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 28,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                                blurRadius: 0,
                                color: Color(0xFF3D35CC),
                                offset: Offset(2, 2)),
                            Shadow(
                                blurRadius: 0,
                                color: Color(0xFF3D35CC),
                                offset: Offset(-1, -1)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hangi İngilizce seviyesinde çalışmak istiyorsun?',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: _levels.map((level) {
                    final (value, code, desc, colors, shadow) = level;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _LevelButton(
                        code: code,
                        description: desc,
                        gradientColors: colors,
                        shadowColor: shadow,
                        onTap: () => context.push(
                          '/education/topics/$subjectId',
                          extra: (subjectName, value),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelButton extends StatelessWidget {
  final String code;
  final String description;
  final List<Color> gradientColors;
  final Color shadowColor;
  final VoidCallback onTap;

  const _LevelButton({
    required this.code,
    required this.description,
    required this.gradientColors,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: shadowColor,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.18),
                offset: const Offset(0, -3),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    code,
                    style: GoogleFonts.luckiestGuy(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      code,
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 22,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.28),
                            offset: const Offset(1, 2),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      description,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.75),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
