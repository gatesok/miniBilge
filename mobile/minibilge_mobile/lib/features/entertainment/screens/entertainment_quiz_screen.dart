import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import '../models/entertainment_models.dart';
import '../providers/entertainment_provider.dart';
import '../../../../core/services/ad_service.dart';

class EntertainmentQuizScreen extends ConsumerStatefulWidget {
  final String topicKey;
  final String difficulty;

  const EntertainmentQuizScreen({
    super.key,
    required this.topicKey,
    required this.difficulty,
  });

  @override
  ConsumerState<EntertainmentQuizScreen> createState() =>
      _EntertainmentQuizScreenState();
}

class _EntertainmentQuizScreenState
    extends ConsumerState<EntertainmentQuizScreen> {
  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(entertainmentQuizProvider.notifier).load(
            topicKey:   widget.topicKey,
            difficulty: widget.difficulty,
          );
    });
  }

  @override
  void dispose() {
    ref.read(entertainmentQuizProvider.notifier).reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(entertainmentQuizProvider);

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
                          Text('🎉 Eğlence Quiz',
                              style: GoogleFonts.luckiestGuy(
                                  color: Colors.white,
                                  fontSize: 18,
                                  shadows: const [
                                    Shadow(
                                        blurRadius: 0,
                                        color: Color(0xFF004D40),
                                        offset: Offset(1, 1))
                                  ])),
                          Text('${widget.difficulty} · ${widget.topicKey}',
                              style: GoogleFonts.nunito(
                                  color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: state.isLoading
                    ? _LoadingView()
                    : state.error != null
                        ? _ErrorView(
                            onRetry: () => ref
                                .read(entertainmentQuizProvider.notifier)
                                .load(
                                  topicKey:   widget.topicKey,
                                  difficulty: widget.difficulty,
                                ))
                        : state.isDone
                            ? _ResultView(state: state)
                            : state.questions.isEmpty
                                ? _LoadingView()
                                : _QuestionView(
                                    question: state.questions[state.currentIndex],
                                    index:    state.currentIndex,
                                    total:    state.questions.length,
                                    given:    state.answers[state.currentIndex],
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
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 14),
          Text('Sorular hazırlanıyor...',
              style: GoogleFonts.nunito(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ]),
      );
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('😔', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          Text('Sorular yüklenemedi',
              style: GoogleFonts.nunito(
                  color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF11998E)),
              child: const Text('Tekrar Dene')),
        ]),
      );
}

// ── Question ──────────────────────────────────────────────────────────────────

class _QuestionView extends ConsumerWidget {
  final EntertainmentQuestionModel question;
  final int     index;
  final int     total;
  final String? given;

  const _QuestionView({
    required this.question,
    required this.index,
    required this.total,
    this.given,
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
            value: (index + 1) / total,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation(Colors.white),
            borderRadius: BorderRadius.circular(4),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('${index + 1} / $total',
                textAlign: TextAlign.right,
                style: GoogleFonts.nunito(
                    color: Colors.white60, fontSize: 12)),
          ),
          // Soru metni
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Text(question.questionText,
                style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.4)),
          ),
          const SizedBox(height: 14),
          // Şıklar
          ...List.generate(4, (i) {
            final letter   = letters[i];
            final text     = question.options[i];
            final selected = given == letter;
            final correct  = given != null && letter == question.correctAnswer;
            final wrong    = selected && !correct;

            Color bg     = Colors.white.withOpacity(0.15);
            Color border = Colors.white.withOpacity(0.3);
            if (given != null) {
              if (correct)  { bg = const Color(0xFF43A047); border = const Color(0xFF66BB6A); }
              else if (wrong){ bg = const Color(0xFFE53935); border = const Color(0xFFEF5350); }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: given != null
                    ? null
                    : () => ref
                        .read(entertainmentQuizProvider.notifier)
                        .answer(index, letter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border, width: 1.5),
                  ),
                  child: Row(children: [
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
                                fontSize: 14))),
                  ]),
                ),
              ),
            );
          }),
          // Açıklama
          if (given != null && question.explanation != null)
            Container(
              margin: const EdgeInsets.only(top: 6),
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
          // Sıradaki / Sonuç butonu
          if (given != null)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: ElevatedButton(
                onPressed: () => ref
                    .read(entertainmentQuizProvider.notifier)
                    .next(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF11998E),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  index + 1 < total ? 'Sıradaki Soru →' : 'Sonucu Gör 🏆',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Result ────────────────────────────────────────────────────────────────────

class _ResultView extends StatefulWidget {
  final EntertainmentQuizState state;
  const _ResultView({required this.state});

  @override
  State<_ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<_ResultView> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti =
        ConfettiController(duration: const Duration(seconds: 4));
    final pct = widget.state.questions.isNotEmpty
        ? widget.state.correctCount / widget.state.questions.length
        : 0.0;
    if (pct >= 0.8) _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final correct = widget.state.correctCount;
    final total   = widget.state.questions.length;
    final pct     = total > 0 ? correct / total : 0.0;

    final (emoji, title) = switch (pct) {
      >= 1.0  => ('🏆', 'Mükemmel!'),
      >= 0.8  => ('🌟', 'Harika!'),
      >= 0.6  => ('⭐', 'İyi!'),
      _       => ('💪', 'Devam Et!'),
    };

    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 72)),
                const SizedBox(height: 12),
                Text('$correct / $total Doğru',
                    style: GoogleFonts.luckiestGuy(
                        color: Colors.white,
                        fontSize: 28,
                        shadows: const [
                          Shadow(
                              blurRadius: 0,
                              color: Color(0xFF004D40),
                              offset: Offset(2, 2))
                        ])),
                const SizedBox(height: 6),
                Text(title,
                    style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      AdService.showInterstitialAd(onComplete: () {
                        if (context.mounted) {
                          if (context.canPop()) context.pop();
                          else context.go('/dashboard');
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF11998E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Ana Sayfaya Dön',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800,
                            fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 30,
            colors: const [
              Colors.green, Colors.teal, Colors.cyan,
              Colors.yellow, Colors.white
            ],
          ),
        ),
      ],
    );
  }
}
