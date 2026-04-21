import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelsAsync = ref.watch(levelListProvider(topicId));
    final selectedChild = ref.watch(selectedChildProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(topicName),
        centerTitle: true,
      ),
      body: levelsAsync.when(
        data: (levels) {
          if (levels.isEmpty) {
            return const Center(
              child: Text('Henüz seviye eklenmemiş'),
            );
          }

          // Get level results for unlock checks
          final levelResultsAsync = selectedChild != null
              ? ref.watch(levelResultsProvider(selectedChild.id))
              : null;

          return levelResultsAsync?.when(
                data: (levelResults) {
                  // Calculate topic progress
                  final completedLevelsInTopic = levelResults
                      .where((result) => levels.any((level) => level.id == result.levelId))
                      .length;
                  final totalLevels = levels.length;
                  final progressPercentage = totalLevels > 0
                      ? (completedLevelsInTopic / totalLevels) * 100
                      : 0.0;

                  return Column(
                    children: [
                      // Topic Progress Header
                      _TopicProgressHeader(
                        topicName: topicName,
                        completedCount: completedLevelsInTopic,
                        totalCount: totalLevels,
                        progressPercentage: progressPercentage,
                      ),
                      // Levels List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: levels.length,
                          itemBuilder: (context, index) {
                            final level = levels[index];
                            final isFirstLevel = index == 0;

                            // Find this level's result
                            final currentLevelResult = levelResults.firstWhereOrNull(
                              (result) => result.levelId == level.id,
                            );

                            // Check if level is unlocked
                            bool isUnlocked = isFirstLevel;

                            if (!isFirstLevel && levelResults.isNotEmpty) {
                              // Check previous level's result
                              final previousLevel = levels[index - 1];
                              final previousResult = levelResults.firstWhere(
                                (result) => result.levelId == previousLevel.id,
                                orElse: () => levelResults.first,
                              );

                              // Unlock if previous level has >=70% success
                              if (previousResult.levelId == previousLevel.id) {
                                isUnlocked = previousResult.successPercentage >= 70;
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
                                        context.push('/education/quiz/${level.id}', extra: {
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) {
                  // If no progress yet, show all levels as locked except first
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
                          padding: const EdgeInsets.all(16),
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
                                        context.push('/education/quiz/${level.id}', extra: {
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
                      padding: const EdgeInsets.all(16),
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
                                    context.push('/education/quiz/${level.id}', extra: {
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Hata: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(levelListProvider(topicId)),
                child: const Text('Tekrar Dene'),
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
    return Card(
      elevation: isLocked ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: isLocked ? 0.5 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isLocked ? Colors.grey : _getDifficultyColor(difficulty),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: isLocked
                            ? const Icon(Icons.lock, color: Colors.white, size: 24)
                            : Text(
                                level.replaceAll('Seviye ', '').replaceAll('Okul Öncesi', '👶'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
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
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  level,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isLocked ? Colors.grey : null,
                                      ),
                                ),
                              ),
                              if (isLocked)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.lock_outline, size: 14, color: Colors.grey),
                                      SizedBox(width: 4),
                                      Text(
                                        'Kilitli',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (levelResult != null && !isLocked)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle, size: 14, color: Colors.green),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Tamamlandı',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isLocked ? Colors.grey : Colors.grey[600],
                                  ),
                            ),
                          ],
                          if (isLocked) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Bir önceki seviyeyi %70+ başarı ile tamamla',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.orange[700],
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ],
                          if (levelResult != null && !isLocked) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.emoji_events, size: 16, color: Colors.amber[700]),
                                const SizedBox(width: 4),
                                Text(
                                  'En İyi: ${levelResult!.score} puan',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.amber[900],
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(width: 12),
                                ...List.generate(
                                  levelResult!.stars,
                                  (index) => const Icon(Icons.star, size: 16, color: Colors.amber),
                                ),
                                if (levelResult!.stars < 3)
                                  ...List.generate(
                                    3 - levelResult!.stars,
                                    (index) => Icon(Icons.star_border, size: 16, color: Colors.grey[400]),
                                  ),
                                const SizedBox(width: 12),
                                Text(
                                  '%${levelResult!.successPercentage.toStringAsFixed(0)}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: _getSuccessColor(levelResult!.successPercentage),
                                        fontWeight: FontWeight.bold,
                                      ),
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
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.stars,
                      label: 'Zorluk: $difficulty/10',
                      isLocked: isLocked,
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.check_circle_outline,
                      label: 'Geçme: $minCorrectToPass doğru',
                      isLocked: isLocked,
                    ),
                  ],
                ),
                if (levelResult != null && !isLocked) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, size: 16, color: Colors.blue[700]),
                        const SizedBox(width: 6),
                        Text(
                          'Daha iyi skor için tekrar çöz',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
  final IconData icon;
  final String label;
  final bool isLocked;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey[300] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
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
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'İlerleme',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedCount / $totalCount Seviye',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getPercentageColor(progressPercentage).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getPercentageColor(progressPercentage),
                    width: 2,
                  ),
                ),
                child: Text(
                  '${progressPercentage.toStringAsFixed(0)}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getPercentageColor(progressPercentage),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressPercentage / 100,
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getPercentageColor(progressPercentage),
              ),
            ),
          ),
          if (completedCount > 0 && completedCount < totalCount) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.celebration,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Harika gidiyorsun! ${totalCount - completedCount} seviye daha var.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (completedCount == totalCount && totalCount > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.emoji_events,
                  size: 16,
                  color: Colors.amber,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tebrikler! Tüm seviyeleri tamamladın! 🎉',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.amber[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (completedCount == 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.play_circle_outline,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'İlk seviyeden başla ve ilerle!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    if (percentage >= 20) return Colors.blue;
    return Colors.grey;
  }
}
