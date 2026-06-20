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
  final String subjectName;

  const LevelListScreen({
    super.key,
    required this.topicId,
    required this.topicName,
    this.subjectName = '',
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
                                                        'subjectName': subjectName,
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
                                                        'subjectName': subjectName,
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
                                                    'subjectName': subjectName,
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
        opacity: isLocked ? 0.55 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF5C4ECC),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.22),
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                // Level badge
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: isLocked ? const Color(0xFFE0E0E0) : diffColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isLocked
                        ? const Icon(Icons.lock_rounded, color: Color(0xFFBDBDBD), size: 26)
                        : isCompleted
                            ? Text(
                                _getStarEmoji(levelResult!.stars),
                                style: const TextStyle(fontSize: 24),
                              )
                            : Text(
                                level.replaceAll('Seviye ', '').replaceAll('Okul Öncesi', '👶'),
                                style: GoogleFonts.luckiestGuy(
                                    fontSize: 18,
                                    color: diffColor),
                              ),
                  ),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level,
                        style: GoogleFonts.nunito(
                            color: isLocked ? const Color(0xFF9E9E9E) : const Color(0xFF1A1A2E),
                            fontWeight: FontWeight.w800,
                            fontSize: 17),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          description,
                          style: GoogleFonts.nunito(
                              color: const Color(0xFF616161),
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      if (isLocked)
                        Text(
                          '🔒 Önceki seviyeyi %70+ tamamla',
                          style: GoogleFonts.nunito(
                              color: const Color(0xFFF57C00),
                              fontWeight: FontWeight.w700,
                              fontSize: 12),
                        )
                      else if (isCompleted)
                        Row(
                          children: [
                            ...List.generate(levelResult!.stars, (_) => const Text('⭐', style: TextStyle(fontSize: 13))),
                            ...List.generate(3 - levelResult!.stars, (_) => const Text('☆', style: TextStyle(fontSize: 13, color: Color(0xFFBDBDBD)))),
                            const SizedBox(width: 8),
                            Text(
                              '%${levelResult!.successPercentage.toStringAsFixed(0)} başarı',
                              style: GoogleFonts.nunito(
                                  color: _getSuccessColor(levelResult!.successPercentage),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('Tekrar oyna',
                                  style: GoogleFonts.nunito(
                                      color: const Color(0xFF2E7D32),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11)),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            _SmallChip(
                              color: diffColor,
                              label: 'Zorluk $difficulty/10',
                            ),
                            const SizedBox(width: 6),
                            _SmallChip(
                              color: const Color(0xFF5C4ECC),
                              label: '$minCorrectToPass doğru gerekli',
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (!isLocked)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: isCompleted ? const Color(0xFF4CAF50) : const Color(0xFF5C4ECC),
                    size: 18,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getStarEmoji(int stars) {
    if (stars >= 3) return '🌟';
    if (stars == 2) return '⭐';
    return '✅';
  }

  Color _getDifficultyColor(int difficulty) {
    if (difficulty <= 3) return const Color(0xFF2E7D32);
    if (difficulty <= 6) return const Color(0xFFF57C00);
    return const Color(0xFFC62828);
  }

  Color _getSuccessColor(double percentage) {
    if (percentage >= 80) return const Color(0xFF2E7D32);
    if (percentage >= 50) return const Color(0xFFF57C00);
    return const Color(0xFFC62828);
  }
}

class _SmallChip extends StatelessWidget {
  final Color color;
  final String label;
  const _SmallChip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 11),
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
    final pColor = _getPercentageColor(progressPercentage);
    final motivationText = completedCount == totalCount && totalCount > 0
        ? '🎉 Tüm seviyeleri tamamladın!'
        : completedCount > 0
            ? '🚀 ${totalCount - completedCount} seviye daha var!'
            : '▶️ İlk seviye seni bekliyor!';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF5C4ECC),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.15),
                offset: const Offset(0, -2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('İlerleme',
                            style: GoogleFonts.nunito(
                                color: const Color(0xFF757575),
                                fontWeight: FontWeight.w700,
                                fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(
                          '$completedCount / $totalCount Seviye',
                          style: GoogleFonts.luckiestGuy(
                              fontSize: 20,
                              color: const Color(0xFF1A1A2E)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: pColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${progressPercentage.toStringAsFixed(0)}%',
                      style: GoogleFonts.nunito(
                          color: pColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progressPercentage / 100,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFE8E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(pColor),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                motivationText,
                style: GoogleFonts.nunito(
                    color: const Color(0xFF5C4ECC),
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 80) return const Color(0xFF2E7D32);
    if (percentage >= 40) return const Color(0xFFF57C00);
    return const Color(0xFF5C4ECC);
  }
}
