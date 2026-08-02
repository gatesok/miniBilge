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
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
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
                            offset: Offset(2, 2),
                          ),
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
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.05,
                          ),
                      itemCount: topics.length,
                      itemBuilder: (context, index) {
                        final topic = topics[index];
                        final colors = _topicGradientColors(index);
                        return _TopicGridCard(
                          title: topic.name,
                          icon: _getTopicIcon(topic.name),
                          gradientColors: colors.$1,
                          shadowColor: colors.$2,
                          onTap: () => context.push(
                            '/education/levels/${topic.id}',
                            extra: {
                              'topicName': topic.name,
                              'subjectName': subjectName,
                            },
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (error, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Hata: $error',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () =>
                                ref.refresh(topicListProvider(subjectId)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A3FCC),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text(
                                'Tekrar Dene',
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
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
            ],
          ),
        ),
      ),
    );
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
    if (topicName.contains('Toplama')) return Icons.add_rounded;
    if (topicName.contains('Çıkarma')) return Icons.remove_rounded;
    if (topicName.contains('Çarpma')) return Icons.close_rounded;
    if (topicName.contains('Bölme')) return Icons.percent_rounded;
    if (topicName.contains('Sayı')) return Icons.numbers_rounded;
    if (topicName.contains('Problem')) return Icons.lightbulb_rounded;
    if (topicName.contains('Alfabe')) return Icons.abc_rounded;
    if (topicName.contains('Renk')) return Icons.palette_rounded;
    if (topicName.contains('Hayvan')) return Icons.pets_rounded;
    if (topicName.contains('Selaml')) return Icons.waving_hand_rounded;
    if (topicName.contains('Nesne')) return Icons.inventory_2_rounded;
    if (topicName.contains('Aile')) return Icons.family_restroom_rounded;
    if (topicName.contains('Giysi') || topicName.contains('Giyim')) {
      return Icons.checkroom_rounded;
    }
    if (topicName.contains('Gün')) return Icons.calendar_month_rounded;
    if (topicName.contains('Cümle')) return Icons.forum_rounded;
    if (topicName.contains('Deneme')) return Icons.edit_note_rounded;
    return Icons.menu_book_rounded;
  }
}

class _TopicGridCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Color> gradientColors;
  final Color shadowColor;
  final VoidCallback onTap;

  const _TopicGridCard({
    required this.title,
    required this.icon,
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
              color: shadowColor.withValues(alpha: 0.55),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
