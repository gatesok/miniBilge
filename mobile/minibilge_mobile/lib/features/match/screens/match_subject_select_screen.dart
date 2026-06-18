import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../education/providers/subject_provider.dart';

class MatchSubjectSelectScreen extends ConsumerWidget {
  const MatchSubjectSelectScreen({super.key});

  (String, List<Color>, Color) _subjectConfig(String name) {
    switch (name.toLowerCase()) {
      case 'matematik':
        return ('🧮', const [Color(0xFF29B6F6), Color(0xFF0277BD)], const Color(0xFF01579B));
      case 'i̇ngilizce':
      case 'ingilizce':
        return ('🇬🇧', const [Color(0xFF26A69A), Color(0xFF00695C)], const Color(0xFF004D40));
      default:
        return ('📚', const [Color(0xFF7E57C2), Color(0xFF4527A0)], const Color(0xFF311B92));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectListProvider);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.55, 1.0],
            colors: [
              Color(0xFF7EC8F0),
              Color(0xFFAA9FE8),
              Color(0xFFC4A8E2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Ders Seç',
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
                'Hangi derste rakip bulmak istiyorsun?',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 32),
              // Subject buttons
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: subjectsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    error: (_, __) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Dersler yüklenemedi',
                              style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => ref.refresh(subjectListProvider),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    ),
                    data: (subjects) => Column(
                      children: subjects.map((subject) {
                        final config = _subjectConfig(subject.name);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _SubjectButton(
                            label: subject.name.toUpperCase(),
                            emoji: config.$1,
                            gradientColors: config.$2,
                            shadowColor: config.$3,
                            onTap: () => context.go(
                              '/match/request?subjectId=${subject.id}&subjectName=${Uri.encodeComponent(subject.name)}',
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectButton extends StatelessWidget {
  final String label;
  final String emoji;
  final List<Color> gradientColors;
  final Color shadowColor;
  final VoidCallback onTap;

  const _SubjectButton({
    required this.label,
    required this.emoji,
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                  child: Text(emoji, style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
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
