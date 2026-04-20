import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/topic_provider.dart';

class TopicSelectionScreen extends ConsumerWidget {
  final String subjectId;
  final String subjectName;

  const TopicSelectionScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(topicListProvider(subjectId));

    return Scaffold(
      appBar: AppBar(
        title: Text(subjectName),
        centerTitle: true,
      ),
      body: topicsAsync.when(
        data: (topics) {
          if (topics.isEmpty) {
            return const Center(
              child: Text('Henüz konu eklenmemiş'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TopicCard(
                  title: topic.name,
                  description: topic.description ?? '',
                  icon: _getTopicIcon(topic.name),
                  onTap: () {
                    context.push('/education/levels/${topic.id}', extra: topic.name);
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
                onPressed: () => ref.refresh(topicListProvider(subjectId)),
                child: const Text('Tekrar Dene'),
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
    return Icons.book_outlined;
  }
}

class _TopicCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _TopicCard({
    required this.title,
    required this.description,
    required this.icon,
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
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
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
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
