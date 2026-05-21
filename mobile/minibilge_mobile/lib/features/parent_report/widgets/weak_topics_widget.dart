import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weak_topic.dart';

class WeakTopicsWidget extends StatelessWidget {
  final List<WeakTopic> topics;

  const WeakTopicsWidget({super.key, required this.topics});

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              Text('Harika! Henüz zayıf konu yok.',
                  style: GoogleFonts.luckiestGuy(
                      color: Colors.white,
                      fontSize: 22,
                      shadows: const [
                        Shadow(
                            blurRadius: 0,
                            color: Color(0xFF3D35CC),
                            offset: Offset(2, 2))
                      ])),
              const SizedBox(height: 10),
              Text(
                'En az 3 soru çözülen konular burada görünür.',
                style: GoogleFonts.nunito(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w700,
                    fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: topics.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final topic = topics[index];
        final pct = (topic.successRate * 100).toStringAsFixed(0);
        final color = _rateColor(topic.successRate);

        return Container(
          padding: const EdgeInsets.all(16),
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
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(topic.topicName,
                            style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(topic.subjectName,
                            style: GoogleFonts.nunito(
                                color: Colors.white.withOpacity(0.75),
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withOpacity(0.6)),
                    ),
                    child: Text('$pct%',
                        style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: topic.successRate,
                  minHeight: 10,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${topic.correctAttempts} doğru / ${topic.totalAttempts} deneme',
                style: GoogleFonts.nunito(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
              ),
            ],
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
