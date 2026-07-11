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
                child: GridView.count(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.05,
                  children: _levels.map((level) {
                    final (value, code, desc, colors, shadow) = level;
                    return _LevelGridCard(
                      code: code,
                      description: desc,
                      gradientColors: colors,
                      shadowColor: shadow,
                      onTap: () => context.push(
                        '/education/english/$subjectId/level/$value/mode',
                        extra: {
                          'subjectName': subjectName,
                          'levelCode': code,
                        },
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

class _LevelGridCard extends StatelessWidget {
  final String       code;
  final String       description;
  final List<Color>  gradientColors;
  final Color        shadowColor;
  final VoidCallback onTap;

  const _LevelGridCard({
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.55),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level code badge — top-left
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                code,
                style: GoogleFonts.luckiestGuy(
                  fontSize: 18,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
            const Spacer(),
            Text(
              code,
              style: GoogleFonts.luckiestGuy(
                fontSize: 26,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    color: Color(0x44000000),
                    offset: Offset(1, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: Colors.white.withOpacity(0.82),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
