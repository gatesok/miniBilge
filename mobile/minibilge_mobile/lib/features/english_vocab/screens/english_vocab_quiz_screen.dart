import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/english_vocab_models.dart';
import '../providers/english_vocab_provider.dart';
import 'english_vocab_result_view.dart';

class EnglishVocabQuizScreen extends ConsumerStatefulWidget {
  final String levelCode; // "A1".."C2"

  const EnglishVocabQuizScreen({super.key, required this.levelCode});

  @override
  ConsumerState<EnglishVocabQuizScreen> createState() =>
      _EnglishVocabQuizScreenState();
}

class _EnglishVocabQuizScreenState
    extends ConsumerState<EnglishVocabQuizScreen> {
  static const int kSecondsPerQuestion = 20;

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF5E60CE), Color(0xFF5E35B1), Color(0xFF3D2C8D)],
  );

  Timer? _timer;
  int _timeLeft = kSecondsPerQuestion;
  int? _timerIndex; // sayacın hangi soru index'i için çalıştığı

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(englishVocabQuizProvider.notifier)
          .load(levelCode: widget.levelCode);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(int index) {
    _timer?.cancel();
    _timerIndex = index;
    setState(() => _timeLeft = kSecondsPerQuestion);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_timeLeft <= 1) {
        t.cancel();
        // Süre doldu: cevaplanmadıysa boş seçim (yanlış) — doğru şık açığa çıkar.
        final state = ref.read(englishVocabQuizProvider);
        if (state.answers[index] == null) {
          ref.read(englishVocabQuizProvider.notifier).answer(index, '');
        }
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timerIndex = null;
  }

  /// Görünen soruya göre sayacı senkronize eder (build sonrası çağrılır).
  void _syncTimer(EnglishVocabQuizState state) {
    final showingQuestion = !state.isLoading &&
        state.error == null &&
        !state.isDone &&
        state.questions.isNotEmpty;
    if (!showingQuestion) {
      _stopTimer();
      return;
    }
    final index = state.currentIndex;
    final answered = state.answers[index] != null;
    if (answered) {
      _timer?.cancel(); // cevaplandı; geri sayımı durdur
      return;
    }
    if (_timerIndex != index) {
      _startTimer(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(englishVocabQuizProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncTimer(state);
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    if (!state.isDone)
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/dashboard');
                          }
                        },
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kelime Oyunu',
                            style: GoogleFonts.luckiestGuy(
                              color: Colors.white,
                              fontSize: 18,
                              shadows: const [
                                Shadow(
                                  blurRadius: 0,
                                  color: Color(0xFF2A1F6B),
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'İngilizce · ${widget.levelCode}',
                            style: GoogleFonts.nunito(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!state.isDone &&
                        !state.isLoading &&
                        state.error == null &&
                        state.questions.isNotEmpty)
                      _TimerBadge(secondsLeft: _timeLeft),
                  ],
                ),
              ),

              Expanded(
                child: state.isLoading
                    ? const _LoadingView()
                    : state.error != null
                    ? _ErrorView(
                        message: state.error!,
                        onRetry: () => ref
                            .read(englishVocabQuizProvider.notifier)
                            .load(levelCode: widget.levelCode),
                      )
                    : state.isDone
                    ? EnglishVocabResultView(
                        correctCount: state.correctCount,
                        totalCount: state.questions.length,
                        levelCode: widget.levelCode,
                        startedAt: state.startedAt,
                      )
                    : state.questions.isEmpty
                    ? const _LoadingView()
                    : _QuestionView(
                        question: state.questions[state.currentIndex],
                        index: state.currentIndex,
                        total: state.questions.length,
                        given: state.answers[state.currentIndex],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Timer badge ────────────────────────────────────────────────────────────────

class _TimerBadge extends StatelessWidget {
  final int secondsLeft;
  const _TimerBadge({required this.secondsLeft});

  @override
  Widget build(BuildContext context) {
    final urgent = secondsLeft <= 5;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: urgent
            ? const Color(0xFFC62828)
            : Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            '$secondsLeft',
            style: GoogleFonts.luckiestGuy(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// ── Question view ───────────────────────────────────────────────────────────────

class _QuestionView extends ConsumerWidget {
  final VocabQuestionModel question;
  final int index;
  final int total;
  final String? given;

  const _QuestionView({
    required this.question,
    required this.index,
    required this.total,
    required this.given,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final letters = ['A', 'B', 'C', 'D'];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: (index + 1) / total,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation(Colors.white),
            borderRadius: BorderRadius.circular(4),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '${index + 1} / $total',
              textAlign: TextAlign.right,
              style: GoogleFonts.nunito(color: Colors.white60, fontSize: 12),
            ),
          ),
          // Kelime kartı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  question.englishWord,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.luckiestGuy(
                    fontSize: 34,
                    color: const Color(0xFF3D2C8D),
                  ),
                ),
                if (given != null &&
                    (question.exampleSentence?.isNotEmpty ?? false)) ...[
                  const SizedBox(height: 10),
                  Text(
                    question.exampleSentence!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Türkçe anlamı hangisi?',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          // Şıklar
          ...List.generate(4, (i) {
            final letter = letters[i];
            final text = question.options[i];
            final selected = given == letter;
            final correct = given != null && letter == question.correctAnswer;
            final wrong = selected && !correct;

            Color bg = const Color(0xFF3D2C8D);
            if (given != null) {
              if (correct) {
                bg = const Color(0xFF1B5E20);
              } else if (wrong) {
                bg = const Color(0xFFB71C1C);
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: given != null
                    ? null
                    : () => ref
                        .read(englishVocabQuizProvider.notifier)
                        .answer(index, letter),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          letter,
                          style: GoogleFonts.luckiestGuy(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          text,
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (correct)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                        )
                      else if (wrong)
                        const Icon(Icons.cancel_rounded, color: Colors.white),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (given != null)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: ElevatedButton(
                onPressed: () =>
                    ref.read(englishVocabQuizProvider.notifier).next(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF5E35B1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  index + 1 < total ? 'Sıradaki Kelime' : 'Sonucu Gör',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Loading & error ──────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: Colors.white),
        const SizedBox(height: 16),
        Text(
          'Kelimeler hazırlanıyor...',
          style: GoogleFonts.nunito(color: Colors.white70, fontSize: 14),
        ),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.sentiment_dissatisfied_rounded,
            color: Colors.white,
            size: 56,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF5E35B1),
            ),
            child: Text(
              'Tekrar Dene',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    ),
  );
}
