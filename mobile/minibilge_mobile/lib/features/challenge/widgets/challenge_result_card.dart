import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Quiz result ekranında, async meydan okuma tamamlandığında
/// gösterilen sonuç kartı.
class ChallengeResultCard extends StatelessWidget {
  final String resultMessage;

  const ChallengeResultCard({super.key, required this.resultMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A5ACD), Color(0xFF9C27B0)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A5ACD).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⚔️', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              resultMessage,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
