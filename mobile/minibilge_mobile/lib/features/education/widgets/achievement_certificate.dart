import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/certificate_data.dart';

class AchievementCertificate extends StatelessWidget {
  final CertificateData data;

  const AchievementCertificate({super.key, required this.data});

  String get _achievementLabel {
    if (data.scorePercentage == 100) return 'Mükemmel Başarı';
    if (data.scorePercentage >= 80) return 'Üstün Başarı';
    return 'Başarıyla Tamamlandı';
  }

  String get _date {
    final value = data.completedAt;
    return '${value.day.toString().padLeft(2, '0')}.'
        '${value.month.toString().padLeft(2, '0')}.${value.year}';
  }

  @override
  Widget build(BuildContext context) {
    final accent = data.isEnglish
        ? const Color(0xFF6C4ED9)
        : const Color(0xFF087F9D);
    return SizedBox(
      width: 768,
      height: 512,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/achievement_certificate_template.png',
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(105, 54, 105, 46),
            child: Column(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFD36A),
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    data.isEnglish
                        ? Icons.translate_rounded
                        : Icons.calculate_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'BAŞARI SERTİFİKASI',
                  style: GoogleFonts.luckiestGuy(
                    fontSize: 36,
                    color: const Color(0xFF244A72),
                    letterSpacing: 1.4,
                  ),
                ),
                Text(
                  data.studentName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${data.subjectName} dersinde',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF45637C),
                  ),
                ),
                Text(
                  data.topicName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 25,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF213E5A),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: accent, width: 1.5),
                  ),
                  child: Text(
                    '${data.correctCount}/${data.totalQuestions} Doğru  •  '
                    '%${data.scorePercentage}  •  $_achievementLabel',
                    style: GoogleFonts.nunito(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        width: 22,
                        height: 22,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'MiniBilge  •  $_date',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF61778A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
