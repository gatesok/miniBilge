import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_summary.dart';

class DailySummaryWidget extends StatelessWidget {
  final DailySummary summary;

  const DailySummaryWidget({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = DateFormat('d MMMM yyyy', 'tr').format(summary.date);
    final correctPct = (summary.correctAnswerRate * 100).toStringAsFixed(0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(dateLabel, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
          const SizedBox(height: 16),

          // Özet kartları
          Row(
            children: [
              Expanded(child: _StatCard(
                icon: Icons.quiz,
                label: 'Çözülen Soru',
                value: summary.totalQuestionsAnswered.toString(),
                color: Colors.blue,
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                icon: Icons.check_circle,
                label: 'Doğru',
                value: summary.correctAnswers.toString(),
                color: Colors.green,
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                icon: Icons.cancel,
                label: 'Yanlış',
                value: summary.wrongAnswers.toString(),
                color: Colors.red,
              )),
            ],
          ),

          const SizedBox(height: 16),

          // Başarı oranı
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Başarı Oranı', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: summary.correctAnswerRate,
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(6),
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          color: _rateColor(summary.correctAnswerRate),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('$correctPct%', style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _rateColor(summary.correctAnswerRate),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Puan ve yıldız
          Row(
            children: [
              Expanded(child: _StatCard(
                icon: Icons.military_tech,
                label: 'Kazanılan Puan',
                value: '+${summary.pointsEarned}',
                color: Colors.amber,
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                icon: Icons.star,
                label: 'Kazanılan Yıldız',
                value: '${summary.starsEarned} ★',
                color: Colors.orange,
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                icon: Icons.emoji_events,
                label: 'Tamamlanan Bölüm',
                value: summary.levelsCompleted.toString(),
                color: Colors.purple,
              )),
            ],
          ),

          if (summary.totalQuestionsAnswered == 0) ...[
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Icon(Icons.free_breakfast, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 8),
                  Text('Bu gün henüz soru çözülmedi', style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _rateColor(double rate) {
    if (rate >= 0.8) return Colors.green;
    if (rate >= 0.5) return Colors.orange;
    return Colors.red;
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(value, style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            )),
            const SizedBox(height: 2),
            Text(label, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
