import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/challenge_models.dart';
import '../providers/challenge_provider.dart';

class AdultChallengeQuizScreen extends ConsumerStatefulWidget {
  const AdultChallengeQuizScreen({super.key, required this.challenge});
  final ChallengeDto challenge;
  @override
  ConsumerState<AdultChallengeQuizScreen> createState() => _State();
}

class _State extends ConsumerState<AdultChallengeQuizScreen> {
  late final List<Map<String, dynamic>> questions;
  int index = 0, score = 0;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    questions = (jsonDecode(widget.challenge.questionPayload ?? '[]') as List)
        .cast<Map<String, dynamic>>();
  }

  Future<void> answer(String value) async {
    if (busy) return;
    if (questions[index]['CorrectAnswer'] == value) score++;
    if (index + 1 < questions.length) {
      setState(() => index++);
      return;
    }
    setState(() => busy = true);
    try {
      await ref
          .read(challengeNotifierProvider.notifier)
          .submitScore(widget.challenge.id, score);
      if (mounted) context.go('/challenges');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty)
      return const Scaffold(body: Center(child: Text('Sorular bulunamadı.')));
    final q = questions[index];
    final options = {
      'A': q['OptionA'],
      'B': q['OptionB'],
      'C': q['OptionC'],
      'D': q['OptionD'],
    };
    return Scaffold(
      appBar: AppBar(title: const Text('⚔️ Meydan Okuma')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4FACFE), Color(0xFF9B8FE8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (index + 1) / questions.length,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 30),
            Text(
              '${index + 1}/${questions.length}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Text(
              q['QuestionText']?.toString() ?? '',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 28),
            ...options.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: busy ? null : () => answer(e.key),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(17),
                      alignment: Alignment.centerLeft,
                    ),
                    child: Text(
                      '${e.key}) ${e.value}',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
            ),
            if (busy) const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
