import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/level_provider.dart';

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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: levels.length,
            itemBuilder: (context, index) {
              final level = levels[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _LevelCard(
                  level: level.name,
                  description: level.description ?? '',
                  difficulty: level.difficulty,
                  minCorrectToPass: level.minCorrectToPass,
                  onTap: () {
                    context.push('/education/quiz/${level.id}', extra: {
                      'levelName': level.name,
                      'topicName': topicName,
                    });
                  },
                ),
              );
            },
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
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.description,
    required this.difficulty,
    required this.minCorrectToPass,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                      color: _getDifficultyColor(difficulty),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
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
                        Text(
                          level,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
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
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.check_circle_outline,
                    label: 'Geçme: $minCorrectToPass doğru',
                  ),
                ],
              ),
            ],
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
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
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
