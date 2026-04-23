import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weekly_summary.dart';
import '../models/daily_summary.dart';

class WeeklySummaryWidget extends StatelessWidget {
  final WeeklySummary summary;

  const WeeklySummaryWidget({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekLabel =
        '${DateFormat('d MMM', 'tr').format(summary.weekStart)} – ${DateFormat('d MMM yyyy', 'tr').format(summary.weekEnd)}';
    final correctPct = (summary.correctAnswerRate * 100).toStringAsFixed(0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(weekLabel, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
          const SizedBox(height: 16),

          // Haftalık özet kartları
          Row(
            children: [
              Expanded(child: _StatCard(
                icon: Icons.quiz, label: 'Toplam Soru',
                value: summary.totalQuestionsAnswered.toString(), color: Colors.blue,
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                icon: Icons.today, label: 'Aktif Gün',
                value: '${summary.activeDays}/7', color: Colors.teal,
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                icon: Icons.emoji_events, label: 'Bölüm',
                value: summary.levelsCompleted.toString(), color: Colors.purple,
              )),
            ],
          ),

          const SizedBox(height: 12),

          // Doğru/Yanlış + başarı oranı
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Haftalık Başarı', style: theme.textTheme.titleSmall),
                      Text('$correctPct%',
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _rateColor(summary.correctAnswerRate))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: summary.correctAnswerRate,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: _rateColor(summary.correctAnswerRate),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _LegendDot(color: Colors.green, label: 'Doğru: ${summary.correctAnswers}'),
                      const SizedBox(width: 16),
                      _LegendDot(color: Colors.red, label: 'Yanlış: ${summary.wrongAnswers}'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: _StatCard(
                icon: Icons.military_tech, label: 'Toplam Puan',
                value: '+${summary.totalPointsEarned}', color: Colors.amber,
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                icon: Icons.star, label: 'Toplam Yıldız',
                value: '${summary.totalStarsEarned} ★', color: Colors.orange,
              )),
            ],
          ),

          const SizedBox(height: 16),

          // Günlük breakdown barlar
          if (summary.dailyBreakdown.isNotEmpty) ...[
            Text('Günlük Dağılım', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            ...summary.dailyBreakdown.map((d) => _DayBar(day: d)),
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

class _DayBar extends StatelessWidget {
  final DailySummary day;
  const _DayBar({required this.day});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayLabel = DateFormat('E', 'tr').format(day.date);
    final hasActivity = day.totalQuestionsAnswered > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 32, child: Text(dayLabel, style: theme.textTheme.bodySmall)),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: hasActivity ? day.correctAnswerRate : 0,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: hasActivity ? Colors.green : Colors.grey.shade300,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(
              hasActivity ? '${day.totalQuestionsAnswered}S' : '-',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

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
              fontWeight: FontWeight.bold, color: color,
            )),
            const SizedBox(height: 2),
            Text(label, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
