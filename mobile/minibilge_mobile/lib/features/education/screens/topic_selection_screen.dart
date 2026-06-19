import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/topic_provider.dart';

class TopicSelectionScreen extends ConsumerWidget {
  final String subjectId;
  final String subjectName;
  final int? englishLevel;

  const TopicSelectionScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
    this.englishLevel,
  });

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(topicListProvider(subjectId));
    // Eğer englishLevel belirtilmişse sadece o seviyedeki konuları göster
    final filteredTopicsAsync = topicsAsync.whenData(
      (topics) => englishLevel != null
          ? topics.where((t) => t.englishLevel == englishLevel).toList()
          : topics,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
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
                    Text(
                      subjectName,
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 24,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                              blurRadius: 0,
                              color: Color(0xFF3D35CC),
                              offset: Offset(2, 2))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Topics list
              Expanded(
                child: filteredTopicsAsync.when(
                  data: (topics) {
                    if (topics.isEmpty) {
                      return Center(
                        child: Text(
                          'Henüz konu eklenmemiş',
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: topics.length,
                      itemBuilder: (context, index) {
                        final topic = topics[index];
                        final colors = _topicGradientColors(index);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _TopicPillButton(
                            title: topic.name,
                            emoji: _getTopicEmoji(topic.name),
                            gradientColors: colors.$1,
                            shadowColor: colors.$2,
                            onTap: () => context.push(
                                '/education/levels/${topic.id}',
                                extra: topic.name),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.white)),
                  error: (error, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.white),
                          const SizedBox(height: 16),
                          Text(
                            'Hata: $error',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () =>
                                ref.refresh(topicListProvider(subjectId)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A3FCC),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text('Tekrar Dene',
                                  style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
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

  String _getTopicEmoji(String topicName) {
    if (topicName.contains('Toplama')) return '➕';
    if (topicName.contains('Çıkarma')) return '➖';
    if (topicName.contains('Çarpma')) return '✖️';
    if (topicName.contains('Bölme')) return '➗';
    if (topicName.contains('Sayı')) return '🔢';
    if (topicName.contains('Problem')) return '💡';
    if (topicName.contains('Alfabe')) return '🔤';
    if (topicName.contains('Renk')) return '🎨';
    if (topicName.contains('Hayvan')) return '🐾';
    if (topicName.contains('Selaml')) return '👋';
    if (topicName.contains('Nesne')) return '📦';
    if (topicName.contains('Aile')) return '👨‍👩‍👧';
    if (topicName.contains('Giysi') || topicName.contains('Giyim')) return '👕';
    if (topicName.contains('Gün')) return '📅';
    if (topicName.contains('Cümle')) return '💬';
    if (topicName.contains('Deneme')) return '📝';
    return '📚';
  }

  // Returns (gradientColors, shadowColor) by index — same order as English level screen
  (List<Color>, Color) _topicGradientColors(int index) {
    const palettes = [
      ([Color(0xFF66BB6A), Color(0xFF2E7D32)], Color(0xFF1B5E20)), // yeşil
      ([Color(0xFF26A69A), Color(0xFF00695C)], Color(0xFF004D40)), // teal
      ([Color(0xFF29B6F6), Color(0xFF0277BD)], Color(0xFF01579B)), // mavi
      ([Color(0xFF7E57C2), Color(0xFF4527A0)], Color(0xFF311B92)), // mor
      ([Color(0xFFEF5350), Color(0xFFB71C1C)], Color(0xFF7F0000)), // kırmızı
      ([Color(0xFFFF7043), Color(0xFFBF360C)], Color(0xFF7B2400)), // turuncu
      ([Color(0xFFAB47BC), Color(0xFF6A1B9A)], Color(0xFF4A148C)), // pembe-mor
    ];
    return palettes[index % palettes.length];
  }

  IconData _getTopicIcon(String topicName) {
    return Icons.book_outlined;
  }

  String? _getEnglishLevelLabel(int? englishLevel) {
    switch (englishLevel) {
      case 1: return 'A1';
      case 2: return 'A2';
      case 3: return 'B1';
      case 4: return 'B2';
      case 5: return 'C1';
      case 6: return 'C2';
      default: return null;
    }
  }
}

class _TopicPillButton extends StatelessWidget {
  final String title;
  final String emoji;
  final List<Color> gradientColors;
  final Color shadowColor;
  final VoidCallback onTap;

  const _TopicPillButton({
    required this.title,
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
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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
