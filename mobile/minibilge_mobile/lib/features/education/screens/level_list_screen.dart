import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart';
import '../providers/level_provider.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../progress/providers/progress_provider.dart';
import '../../progress/models/level_result.dart';

class LevelListScreen extends ConsumerWidget {
  final String topicId;
  final String topicName;

  const LevelListScreen({
    super.key,
    required this.topicId,
    required this.topicName,
  });

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelsAsync = ref.watch(levelListProvider(topicId));
    final selectedChild = ref.watch(selectedChildProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              color: Colors.white.withOpacity(0.5), width: 1.5),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        topicName,
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 22,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                                blurRadius: 0,
                                color: Color(0xFF3D35CC),
                                offset: Offset(2, 2))
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Levels
              Expanded(
                child: levelsAsync.when(
                  data: (levels) {
                    if (levels.isEmpty) {
                      return Center(
                        child: Text(
                          'Henüz seviye eklenmemiş',
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                      );
                    }

                    final levelResultsAsync = selectedChild != null
                        ? ref.watch(levelResultsProvider(selectedChild.id))
                        : null;

                    return levelResultsAsync?.when(
                          data: (levelResults) {
                            final completedLevelsInTopic = levelResults
                                .where((result) =>
                                    levels.any((level) => level.id == result.levelId))
                                .length;
                            final totalLevels = levels.length;
                            final progressPercentage = totalLevels > 0
                                ? (completedLevelsInTopic / totalLevels) * 100
                                : 0.0;

                            return Column(
                              children: [
                                _TopicProgressHeader(
                                  topicName: topicName,
                                  completedCount: completedLevelsInTopic,
                                  totalCount: totalLevels,
                                  progressPercentage: progressPercentage,
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                                    itemCount: levels.length,
                                    itemBuilder: (context, index) {
                                      final level = levels[index];
                                      final isFirstLevel = index == 0;
                                      final currentLevelResult =
                                          levelResults.firstWhereOrNull(
                                        (result) => result.levelId == level.id,
                                      );

                                      bool isUnlocked = isFirstLevel;
                                      if (!isFirstLevel && levelResults.isNotEmpty) {
                                        final previousLevel = levels[index - 1];
                                        final previousResult = levelResults.firstWhere(
                                          (result) =>
                                              result.levelId == previousLevel.id,
                                          orElse: () => levelResults.first,
                                        );
                                        if (previousResult.levelId == previousLevel.id) {
                                          isUnlocked =
                                              previousResult.successPercentage >= 70;
                                        }
                                      }

                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: _LevelCard(
                                          level: level.name,
                                          description: level.description ?? '',
                                          difficulty: level.difficulty,
                                          minCorrectToPass: level.minCorrectToPass,
                                          isLocked: !isUnlocked,
                                          levelResult: currentLevelResult,
                                          onTap: isUnlocked
                                              ? () {
                                                  context.push(
                                                      '/education/quiz/${level.id}',
                                                      extra: {
                                                        'levelName': level.name,
                                                        'topicName': topicName,
                                                      });
                                                }
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                          loading: () => const Center(
                              child: CircularProgressIndicator(color: Colors.white)),
                          error: (error, stack) {
                            return Column(
                              children: [
                                _TopicProgressHeader(
                                  topicName: topicName,
                                  completedCount: 0,
                                  totalCount: levels.length,
                                  progressPercentage: 0,
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                                    itemCount: levels.length,
                                    itemBuilder: (context, index) {
                                      final level = levels[index];
                                      final isFirstLevel = index == 0;
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: _LevelCard(
                                          level: level.name,
                                          description: level.description ?? '',
                                          difficulty: level.difficulty,
                                          minCorrectToPass: level.minCorrectToPass,
                                          isLocked: !isFirstLevel,
                                          levelResult: null,
                                          onTap: isFirstLevel
                                              ? () {
                                                  context.push(
                                                      '/education/quiz/${level.id}',
                                                      extra: {
                                                        'levelName': level.name,
                                                        'topicName': topicName,
                                                      });
                                                }
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ) ??
                        Column(
                          children: [
                            _TopicProgressHeader(
                              topicName: topicName,
                              completedCount: 0,
                              totalCount: levels.length,
                              progressPercentage: 0,
                            ),
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                                itemCount: levels.length,
                                itemBuilder: (context, index) {
                                  final level = levels[index];
                                  final isFirstLevel = index == 0;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _LevelCard(
                                      level: level.name,
                                      description: level.description ?? '',
                                      difficulty: level.difficulty,
                                      minCorrectToPass: level.minCorrectToPass,
                                      isLocked: !isFirstLevel,
                                      levelResult: null,
                                      onTap: isFirstLevel
                                          ? () {
                                              context.push(
                                                  '/education/quiz/${level.id}',
                                                  extra: {
                                                    'levelName': level.name,
                                                    'topicName': topicName,
                                                  });
                                            }
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
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
                            onTap: () => ref.refresh(levelListProvider(topicId)),
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
}

class _LevelCard extends StatelessWidget {
  final String level;
  final String description;
  final int difficulty;
  final int minCorrectToPass;
  final bool isLocked;
  final VoidCallback? onTap;
  final LevelResult? levelResult;

  const _LevelCard({
    required this.level,
    required this.description,
    required this.difficulty,
    required this.minCorrectToPass,
    this.isLocked = false,
    this.onTap,
    this.levelResult,
  });

  @override
  Widget build(BuildContext context) {
    final diffColor = _getDifficultyColor(difficulty);
    final isCompleted = levelResult != null && !isLocked;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isLocked ? 0.6 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isLocked ? 0.12 : 0.22),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isCompleted
                  ? Colors.green.withOpacity(0.6)
                  : Colors.white.withOpacity(0.45),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Level badge
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isLocked
                            ? Colors.white.withOpacity(0.15)
                            : diffColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isLocked
                              ? Colors.white.withOpacity(0.3)
                              : diffColor.withOpacity(0.7),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: isLocked
                            ? const Icon(Icons.lock_rounded,
                                color: Colors.white, size: 26)
                            : Text(
                                level
                                    .replaceAll('Seviye ', '')
                                    .replaceAll('Okul Öncesi', '👶'),
                                style: GoogleFonts.luckiestGuy(
                                    fontSize: 18,
                                    color: Colors.white,
                                    shadows: const [
                                      Shadow(
                                          blurRadius: 0,
                                          color: Color(0xFF3D35CC),
                                          offset: Offset(1, 1))
                                    ]),
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Level name + badges
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  level,
                                  style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16),
                                ),
                              ),
                              if (isLocked)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.3)),
                                  ),
                                  child: Text('🔒 Kilitli',
                                      style: GoogleFonts.nunito(
                                          color: Colors.white.withOpacity(0.8),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12)),
                                ),
                              if (isCompleted)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.green.withOpacity(0.6)),
                                  ),
                                  child: Text('✅ Tamamlandı',
                                      style: GoogleFonts.nunito(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12)),
                                ),
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
                          if (isLocked) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Bir önceki seviyeyi %70+ başarı ile tamamla',
                              style: GoogleFonts.nunito(
                                  color: const Color(0xFFFFCC02),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12),
                            ),
                          ],
                          if (isCompleted) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                ...List.generate(
                                    levelResult!.stars,
                                    (i) => const Text('⭐',
                                        style: TextStyle(fontSize: 14))),
                                if (levelResult!.stars < 3)
                                  ...List.generate(
                                      3 - levelResult!.stars,
                                      (i) => Text('☆',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white
                                                  .withOpacity(0.4)))),
                                const SizedBox(width: 8),
                                Text(
                                  ' %${levelResult!.successPercentage.toStringAsFixed(0)}',
                                  style: GoogleFonts.nunito(
                                      color: _getSuccessColor(
                                          levelResult!.successPercentage),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Info chips
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _InfoChip(
                        emoji: '⚡',
                        label: 'Zorluk: $difficulty/10',
                        isLocked: isLocked),
                    _InfoChip(
                        emoji: '✔️',
                        label: 'Geçme: $minCorrectToPass doğru',
                        isLocked: isLocked),
                    if (isCompleted)
                      const _InfoChip(
                          emoji: '🔄',
                          label: 'Tekrar oyna',
                          highlighted: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(int difficulty) {
    if (difficulty <= 3) return Colors.green;
    if (difficulty <= 6) return Colors.orange;
    return Colors.red;
  }

  Color _getSuccessColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }
}

class _InfoChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isLocked;
  final bool highlighted;

  const _InfoChip({
    required this.emoji,
    required this.label,
    this.isLocked = false,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: highlighted
            ? const Color(0xFF4FC3F7).withOpacity(0.25)
            : Colors.white.withOpacity(isLocked ? 0.1 : 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted
              ? const Color(0xFF4FC3F7).withOpacity(0.5)
              : Colors.white.withOpacity(isLocked ? 0.2 : 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.nunito(
                color: Colors.white.withOpacity(isLocked ? 0.6 : 0.9),
                fontWeight: FontWeight.w700,
                fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TopicProgressHeader extends StatelessWidget {
  final String topicName;
  final int completedCount;
  final int totalCount;
  final double progressPercentage;

  const _TopicProgressHeader({
    required this.topicName,
    required this.completedCount,
    required this.totalCount,
    required this.progressPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.22),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: Colors.white.withOpacity(0.45), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📈 İlerleme',
                        style: GoogleFonts.nunito(
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      '$completedCount / $totalCount Seviye',
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 20,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                              blurRadius: 0,
                              color: Color(0xFF3D35CC),
                              offset: Offset(1, 1))
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getPercentageColor(progressPercentage)
                        .withOpacity(0.25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: _getPercentageColor(progressPercentage)
                            .withOpacity(0.6),
                        width: 1.5),
                  ),
                  child: Text(
                    '${progressPercentage.toStringAsFixed(0)}%',
                    style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressPercentage / 100,
                minHeight: 12,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                    _getPercentageColor(progressPercentage)),
              ),
            ),
            if (completedCount > 0 && completedCount < totalCount) ...[
              const SizedBox(height: 10),
              Text(
                '🚀 Harika gidiyorsun! ${totalCount - completedCount} seviye daha var.',
                style: GoogleFonts.nunito(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ],
            if (completedCount == totalCount && totalCount > 0) ...[
              const SizedBox(height: 10),
              Text(
                '🎉 Tebrikler! Tüm seviyeleri tamamladın!',
                style: GoogleFonts.nunito(
                    color: const Color(0xFFFFCC02),
                    fontWeight: FontWeight.w800,
                    fontSize: 14),
              ),
            ],
            if (completedCount == 0) ...[
              const SizedBox(height: 10),
              Text(
                '▶️ Hadi başla! İlk seviye seni bekliyor.',
                style: GoogleFonts.nunito(
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 40) return Colors.orange;
    return const Color(0xFF4FC3F7);
  }
}
