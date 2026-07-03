import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/adaptive_quiz_config.dart';
import '../models/adaptive_quiz_models.dart';
import '../providers/adaptive_quiz_provider.dart';
import '../../child_profile/providers/selected_child_provider.dart';

class AdaptiveQuizScreen extends ConsumerStatefulWidget {
  final AdaptiveQuizConfig config;
  const AdaptiveQuizScreen({super.key, required this.config});

  @override
  ConsumerState<AdaptiveQuizScreen> createState() =>
      _AdaptiveQuizScreenState();
}

class _AdaptiveQuizScreenState extends ConsumerState<AdaptiveQuizScreen> {
  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4FACFE), Color(0xFF7B2FBE), Color(0xFF4776E6)],
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(adaptiveQuizProvider.notifier)
          .loadFromConfig(widget.config);
    });
  }

  @override
  void dispose() {
    ref.read(adaptiveQuizProvider.notifier).reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adaptiveQuizProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                      onPressed: () {
                        if (context.canPop()) context.pop();
                        else context.go('/dashboard');
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🤖 Sana Özel Quiz',
                              style: GoogleFonts.luckiestGuy(
                                  color: Colors.white,
                                  fontSize: 18,
                                  shadows: const [
                                    Shadow(
                                        blurRadius: 0,
                                        color: Color(0xFF2C0654),
                                        offset: Offset(1, 1))
                                  ])),
                          Text(
                            '${widget.config.subjectName} · ${widget.config.levelDisplay}',
                            style: GoogleFonts.nunito(
                                color: Colors.white70, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Body
              Expanded(
                child: state.isLoading
                    ? _LoadingView()
                    : state.error != null
                        ? _ErrorView(
                            error: state.error!,
                            onRetry: () => ref
                                .read(adaptiveQuizProvider.notifier)
                                .loadFromConfig(widget.config),
                          )
                        : state.isDone
                            ? _ResultView(state: state)
                            : state.questions.isEmpty
                                ? _LoadingView()
                                : _QuestionView(
                                    question: state.questions[state.currentIndex],
                                    questionNumber: state.currentIndex + 1,
                                    total: state.questions.length,
                                    givenAnswer: state.answers[
                                        state.questions[state.currentIndex].id],
                                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Loading ───────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text('AI sorular hazırlanıyor...',
                style: GoogleFonts.nunito(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('😔', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 12),
              Text('Sorular yüklenemedi',
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF7B2FBE)),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
}

// ── Question ──────────────────────────────────────────────────────────────────

class _QuestionView extends ConsumerWidget {
  final AdaptiveQuestionModel question;
  final int questionNumber;
  final int total;
  final String? givenAnswer;

  const _QuestionView({
    required this.question,
    required this.questionNumber,
    required this.total,
    this.givenAnswer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final letters = ['A', 'B', 'C', 'D'];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress
          LinearProgressIndicator(
            value: questionNumber / total,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation(Colors.white),
            borderRadius: BorderRadius.circular(4),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('$questionNumber / $total',
                textAlign: TextAlign.right,
                style: GoogleFonts.nunito(
                    color: Colors.white60, fontSize: 12)),
          ),
          // Question text
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Text(
              question.questionText,
              style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          // Options
          ...List.generate(4, (i) {
            final letter  = letters[i];
            final text    = question.options[i];
            final isSelected = givenAnswer == letter;
            final isCorrect  = givenAnswer != null && letter == question.correctAnswer;
            final isWrong    = isSelected && !isCorrect;

            Color bg = Colors.white.withOpacity(0.15);
            Color border = Colors.white.withOpacity(0.3);
            if (givenAnswer != null) {
              if (isCorrect)  { bg = const Color(0xFF43A047); border = const Color(0xFF66BB6A); }
              else if (isWrong){ bg = const Color(0xFFE53935); border = const Color(0xFFEF5350); }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: givenAnswer != null
                    ? null
                    : () async {
                        await ref
                            .read(adaptiveQuizProvider.notifier)
                            .submitAnswer(question.id, letter);

                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(letter,
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(text,
                            style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Explanation (cevap verildikten sonra)
          if (givenAnswer != null && question.explanation != null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(question.explanation!,
                        style: GoogleFonts.nunito(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),

          // Sıradaki Soru butonu
          if (givenAnswer != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => ref
                      .read(adaptiveQuizProvider.notifier)
                      .nextQuestion(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF7B2FBE),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    questionNumber < total
                        ? 'Sıradaki Soru →'
                        : 'Sonucu Gör 🏆',
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Result ────────────────────────────────────────────────────────────────────

class _ResultView extends StatelessWidget {
  final AdaptiveQuizState state;
  const _ResultView({required this.state});

  @override
  Widget build(BuildContext context) {
    final correct = state.correctCount;
    final total   = state.questions.length;
    final pct     = total > 0 ? (correct / total * 100).round() : 0;

    final emoji   = pct >= 80 ? '🏆' : pct >= 50 ? '⭐' : '💪';
    final msg     = pct >= 80
        ? 'Harika! Çok iyi yaptın!'
        : pct >= 50
            ? 'İyi iş! Biraz daha pratik yap.'
            : 'Devam et, pratik yaparsan gelişirsin!';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            Text('$correct / $total Doğru',
                style: GoogleFonts.luckiestGuy(
                    color: Colors.white,
                    fontSize: 28,
                    shadows: const [
                      Shadow(
                          blurRadius: 0,
                          color: Color(0xFF2C0654),
                          offset: Offset(2, 2))
                    ])),
            const SizedBox(height: 8),
            Text(msg,
                style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (context.canPop()) context.pop();
                  else context.go('/dashboard');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF7B2FBE),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Ana Sayfaya Dön',
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
