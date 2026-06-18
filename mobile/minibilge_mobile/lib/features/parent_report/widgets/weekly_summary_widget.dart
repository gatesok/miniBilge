import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/weekly_summary.dart';
import '../models/daily_summary.dart';
import '../models/subject_summary.dart';

class WeeklySummaryWidget extends StatelessWidget {
  final WeeklySummary summary;

  const WeeklySummaryWidget({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final weekLabel =
        '${DateFormat('d MMM', 'tr').format(summary.weekStart)} – ${DateFormat('d MMM yyyy', 'tr').format(summary.weekEnd)}';
    final correctPct = (summary.correctAnswerRate * 100).toStringAsFixed(0);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Week label
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.28),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white.withOpacity(0.5), width: 1.5),
              ),
              child: Text(weekLabel,
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15)),
            ),
          ),
          const SizedBox(height: 16),
          // Stats row 1
          Row(
            children: [
              Expanded(
                  child: _GameStatCard(
                      icon: '🧩',
                      label: 'Toplam\nSoru',
                      value: summary.totalQuestionsAnswered.toString(),
                      color: const Color(0xFF4FC3F7))),
              const SizedBox(width: 10),
              Expanded(
                  child: _GameStatCard(
                      icon: '📅',
                      label: 'Aktif\nGün',
                      value: '${summary.activeDays}/7',
                      color: const Color(0xFF26C6DA))),
              const SizedBox(width: 10),
              Expanded(
                  child: _GameStatCard(
                      icon: '🏅',
                      label: 'Bölüm',
                      value: summary.levelsCompleted.toString(),
                      color: const Color(0xFFAB47BC))),
            ],
          ),
          const SizedBox(height: 14),
          // Success rate card
          Container(
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
                    Text('📊 Haftalık Başarı',
                        style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _rateColor(summary.correctAnswerRate)
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: _rateColor(summary.correctAnswerRate)
                                .withOpacity(0.6)),
                      ),
                      child: Text('$correctPct%',
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: summary.correctAnswerRate,
                    minHeight: 14,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                        _rateColor(summary.correctAnswerRate)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _LegendDot(
                        color: Colors.green,
                        label: 'Doğru: ${summary.correctAnswers}'),
                    const SizedBox(width: 16),
                    _LegendDot(
                        color: Colors.red,
                        label: 'Yanlış: ${summary.wrongAnswers}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Points/stars row
          Row(
            children: [
              Expanded(
                  child: _GameStatCard(
                      icon: '⭐',
                      label: 'Toplam\nPuan',
                      value: '+${summary.totalPointsEarned}',
                      color: const Color(0xFFFFB300))),
              const SizedBox(width: 10),
              Expanded(
                  child: _GameStatCard(
                      icon: '🌟',
                      label: 'Toplam\nYıldız',
                      value: '${summary.totalStarsEarned}',
                      color: const Color(0xFFFF8C00))),
            ],
          ),
          const SizedBox(height: 14),
          // Daily breakdown
          if (summary.dailyBreakdown.isNotEmpty) ...[
            Text('📈 Günlük Dağılım',
                style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: Colors.white.withOpacity(0.45), width: 1.5),
              ),
              child: Column(
                children: summary.dailyBreakdown
                    .map((d) => _DayBar(day: d))
                    .toList(),
              ),
            ),
          ],
          // Derse Göre Dağılım
          if (summary.subjectBreakdown.isNotEmpty) ...[            
            const SizedBox(height: 14),
            Text('📚 Derse Göre Dağılım',
                style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16)),
            const SizedBox(height: 10),
            ...summary.subjectBreakdown.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SubjectBreakdownCard(subject: s),
            )),
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
    final dayLabel = DateFormat('E', 'tr').format(day.date);
    final hasActivity = day.totalQuestionsAnswered > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
              width: 32,
              child: Text(dayLabel,
                  style: GoogleFonts.nunito(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w700,
                      fontSize: 12))),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: hasActivity ? day.correctAnswerRate : 0,
                minHeight: 10,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                    hasActivity ? Colors.green : Colors.white.withOpacity(0.2)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              hasActivity ? '${day.totalQuestionsAnswered}S' : '-',
              style: GoogleFonts.nunito(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameStatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _GameStatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.45), width: 1.5),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.nunito(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w700,
                  fontSize: 11),
              textAlign: TextAlign.center),
        ],
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
        Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: GoogleFonts.nunito(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w700,
                fontSize: 13)),
      ],
    );
  }
}

class _SubjectBreakdownCard extends StatelessWidget {
  final SubjectSummary subject;

  const _SubjectBreakdownCard({required this.subject});

  Color _subjectColor(String name) {
    switch (name.toLowerCase()) {
      case 'matematik':
        return const Color(0xFF29B6F6);
      case 'i̇ngilizce':
      case 'ingilizce':
        return const Color(0xFF26A69A);
      default:
        return const Color(0xFF7E57C2);
    }
  }

  String _subjectEmoji(String name) {
    switch (name.toLowerCase()) {
      case 'matematik':
        return '🧮';
      case 'i̇ngilizce':
      case 'ingilizce':
        return '🇬🇧';
      default:
        return '📚';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = (subject.correctAnswerRate * 100).toStringAsFixed(0);
    final color = _subjectColor(subject.subjectName);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_subjectEmoji(subject.subjectName),
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                subject.subjectName,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$pct%',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: subject.correctAnswerRate,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _MiniStat(label: 'Soru', value: subject.totalQuestions.toString(), color: Colors.white70),
              const SizedBox(width: 16),
              _MiniStat(label: 'Doğru', value: subject.correctAnswers.toString(), color: const Color(0xFF66BB6A)),
              const SizedBox(width: 16),
              _MiniStat(label: 'Yanlış', value: subject.wrongAnswers.toString(), color: const Color(0xFFEF5350)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          value,
          style: GoogleFonts.nunito(
              color: color, fontWeight: FontWeight.w800, fontSize: 14),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.nunito(
              color: Colors.white60, fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ],
    );
  }
}
