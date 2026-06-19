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
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: topics.length,
                      itemBuilder: (context, index) {
                        final topic = topics[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TopicCard(
                            title: topic.name,
                            description: topic.description ?? '',
                            icon: _getTopicIcon(topic.name),
                            englishLevelLabel: _getEnglishLevelLabel(topic.englishLevel),
                            onTap: () {
                              context.push(
                                  '/education/levels/${topic.id}',
                                  extra: topic.name);
                            },
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

  IconData _getTopicIcon(String topicName) {
    if (topicName.contains('Toplama')) return Icons.add_circle_outline;
    if (topicName.contains('Çıkarma')) return Icons.remove_circle_outline;
    if (topicName.contains('Çarpma')) return Icons.close;
    if (topicName.contains('Bölme')) return Icons.percent;
    if (topicName.contains('Sayı')) return Icons.numbers;
    if (topicName.contains('Problem')) return Icons.lightbulb_outline;
    if (topicName.contains('Alfabe')) return Icons.abc;
    if (topicName.contains('Renk')) return Icons.palette_outlined;
    if (topicName.contains('Hayvan')) return Icons.pets;
    if (topicName.contains('Selaml')) return Icons.waving_hand_outlined;
    if (topicName.contains('Nesne')) return Icons.category_outlined;
    if (topicName.contains('Aile')) return Icons.family_restroom;
    if (topicName.contains('Giysi') || topicName.contains('Giyim')) return Icons.checkroom;
    if (topicName.contains('Gün')) return Icons.calendar_today;
    if (topicName.contains('Cümle')) return Icons.chat_bubble_outline;
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

class _TopicCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? englishLevelLabel;
  final VoidCallback onTap;

  const _TopicCard({
    required this.title,
    required this.description,
    required this.icon,
    this.englishLevelLabel,
    required this.onTap,
  });

  // Deterministic color from title
  Color _cardColor(String name) {
    final colors = [
      const Color(0xFF3498DB),
      const Color(0xFF2ECC71),
      const Color(0xFFE67E22),
      const Color(0xFF9B59B6),
      const Color(0xFFE74C3C),
      const Color(0xFF1ABC9C),
      const Color(0xFFF39C12),
    ];
    int hash = 0;
    for (var c in name.runes) {
      hash = (hash * 31 + c) & 0xFFFFFF;
    }
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _cardColor(title);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.22),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: Colors.white.withOpacity(0.45), width: 1.5),
        ),
        child: Row(
          children: [
            // Icon badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color.withOpacity(0.7), width: 2),
              ),
              child: Icon(icon, size: 28, color: Colors.white),
            ),
            const SizedBox(width: 16),
            // Title + description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 17),
                        ),
                      ),
                      if (englishLevelLabel != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF27AE60).withOpacity(0.85),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            englishLevelLabel!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.nunito(
                          color: Colors.white.withOpacity(0.75),
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            // Arrow
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white.withOpacity(0.35)),
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
