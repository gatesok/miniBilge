import 'package:flutter/material.dart';
import '../models/weak_topic.dart';

class WeakTopicsWidget extends StatelessWidget {
  final List<WeakTopic> topics;

  const WeakTopicsWidget({super.key, required this.topics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (topics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 72, color: Colors.green.shade300),
            const SizedBox(height: 16),
            Text('Harika! Henüz zayıf konu yok.', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('En az 3 soru çözülen konular burada görünür.',
                style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: topics.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final topic = topics[index];
        final pct = (topic.successRate * 100).toStringAsFixed(0);
        final color = _rateColor(topic.successRate);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(topic.topicName,
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                          Text(topic.subjectName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withOpacity(0.4)),
                      ),
                      child: Text('$pct%',
                          style: theme.textTheme.labelLarge?.copyWith(
                              color: color, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: topic.successRate,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  color: color,
                ),
                const SizedBox(height: 6),
                Text(
                  '${topic.correctAttempts} doğru / ${topic.totalAttempts} deneme',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _rateColor(double rate) {
    if (rate >= 0.7) return Colors.green;
    if (rate >= 0.4) return Colors.orange;
    return Colors.red;
  }
}
