import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/daily_summary.dart';
import '../models/subject_summary.dart';

class DailySummaryWidget extends StatelessWidget {
  final DailySummary summary;

  const DailySummaryWidget({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('d MMMM yyyy', 'tr').format(summary.date);
    final correctPct = (summary.correctAnswerRate * 100).toStringAsFixed(0);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Date label
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.28),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white.withOpacity(0.5), width: 1.5),
              ),
              child: Text(dateLabel,
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15)),
            ),
          ),
          const SizedBox(height: 16),
          // Stat cards row
          Row(
            children: [
              Expanded(
                  child: _GameStatCard(
                      icon: '🧩',
                      label: 'Çözülen\nSoru',
                      value: summary.totalQuestionsAnswered.toString(),
                      color: const Color(0xFF4FC3F7))),
              const SizedBox(width: 10),
              Expanded(
                  child: _GameStatCard(
                      icon: '✅',
                      label: 'Doğru',
                      value: summary.correctAnswers.toString(),
                      color: const Color(0xFF66BB6A))),
              const SizedBox(width: 10),
              Expanded(
                  child: _GameStatCard(
                      icon: '❌',
                      label: 'Yanlış',
                      value: summary.wrongAnswers.toString(),
                      color: const Color(0xFFEF5350))),
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
                    Text('🏆 Başarı Oranı',
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
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Points/stars/levels row
          Row(
            children: [
              Expanded(
                  child: _GameStatCard(
                      icon: '⭐',
                      label: 'Puan',
                      value: '+${summary.pointsEarned}',
                      color: const Color(0xFFFFB300))),
              const SizedBox(width: 10),
              Expanded(
                  child: _GameStatCard(
                      icon: '🌟',
                      label: 'Yıldız',
                      value: '${summary.starsEarned}',
                      color: const Color(0xFFFF8C00))),
              const SizedBox(width: 10),
              Expanded(
                  child: _GameStatCard(
                      icon: '🎖️',
                      label: 'Bölüm',
                      value: '${summary.levelsCompleted}',
                      color: const Color(0xFFAB47BC))),
            ],
          ),
          if (summary.totalQuestionsAnswered == 0) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: Colors.white.withOpacity(0.45), width: 1.5),
              ),
              child: Column(
                children: [
                  const Text('☀️', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 12),
                  Text('Bu gün henüz soru çözülmedi',
                      style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ],
          // ── Derse Göre Dağılım ──────────────────────
          if (summary.subjectBreakdown.isNotEmpty) ...[
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '📚 Derse Göre Dağılım',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
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
        return '🧭';
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
