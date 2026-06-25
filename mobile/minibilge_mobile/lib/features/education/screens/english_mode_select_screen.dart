import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// İngilizce seviyesi seçildikten sonra açılır.
/// Kullanıcı: "Alıştırmalar" (quiz) veya "Podcast" (dinleme) seçer.
class EnglishModeSelectScreen extends StatelessWidget {
  final String subjectId;
  final String subjectName;
  final int englishLevel;      // 1=A1 … 6=C2
  final String levelCode;      // "A1", "B2" vb.

  const EnglishModeSelectScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.englishLevel,
    required this.levelCode,
  });

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
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'İngilizce · $levelCode',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 26,
                          color: Colors.white,
                          shadows: const [
                            Shadow(blurRadius: 0, color: Color(0xFF3D35CC), offset: Offset(2, 2)),
                            Shadow(blurRadius: 0, color: Color(0xFF3D35CC), offset: Offset(-1, -1)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Nasıl çalışmak istersin?',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.88),
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _ModeCard(
                      emoji: '📝',
                      title: 'Alıştırmalar',
                      subtitle: 'Sorular çöz, puan kazan',
                      colors: const [Color(0xFF29B6F6), Color(0xFF0277BD)],
                      shadowColor: const Color(0xFF01579B),
                      onTap: () => context.push(
                        '/education/topics/$subjectId',
                        extra: (subjectName, englishLevel),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _ModeCard(
                      emoji: '🎧',
                      title: 'Podcast',
                      subtitle: 'Gerçek diyalogları dinle',
                      colors: const [Color(0xFF26A69A), Color(0xFF00695C)],
                      shadowColor: const Color(0xFF004D40),
                      onTap: () => context.push(
                        '/education/podcasts/$subjectId/$englishLevel',
                        extra: levelCode,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _ModeCard(
                      emoji: '📚',
                      title: 'Kelime Kartları',
                      subtitle: 'Kelime kartlarıyla çalış',
                      colors: const [Color(0xFF9C27B0), Color(0xFF4A148C)],
                      shadowColor: const Color(0xFF1A0030),
                      onTap: () => context.push(
                        '/flashcard/decks/$englishLevel',
                        extra: levelCode,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _ModeCard(
                      emoji: '✍️',
                      title: 'Yazma Pratiği',
                      subtitle: 'GPT ile yazını geliştir',
                      colors: const [Color(0xFFE64A19), Color(0xFF8D1F00)],
                      shadowColor: const Color(0xFF4E0D00),
                      onTap: () => context.pushNamed(
                        'writing-practice',
                        queryParameters: {'level': levelCode},
                      ),
                    ),
                    const SizedBox(height: 20),
                    _ModeCard(
                      emoji: '🎯',
                      title: 'Kelime Meydan Okuması',
                      subtitle: 'Öğrendiğin kelimeleri kullan',
                      colors: const [Color(0xFF00897B), Color(0xFF00574B)],
                      shadowColor: const Color(0xFF003D36),
                      onTap: () => context.pushNamed(
                        'vocab-challenge',
                        queryParameters: {'level': levelCode},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final Color shadowColor;
  final VoidCallback onTap;

  const _ModeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: shadowColor.withOpacity(0.55), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            const SizedBox(width: 28),
            Text(emoji, style: const TextStyle(fontSize: 52)),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.luckiestGuy(
                          fontSize: 26, color: Colors.white,
                          shadows: const [Shadow(blurRadius: 0, color: Colors.black26, offset: Offset(1, 2))])),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: GoogleFonts.nunito(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: Colors.white.withOpacity(0.85))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 18),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
