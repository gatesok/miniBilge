import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/entertainment_models.dart';
import '../providers/entertainment_provider.dart';
import 'entertainment_result_view.dart';

class FactFictionGameScreen extends ConsumerStatefulWidget {
  const FactFictionGameScreen({super.key});

  @override
  ConsumerState<FactFictionGameScreen> createState() =>
      _FactFictionGameScreenState();
}

class _FactFictionGameScreenState extends ConsumerState<FactFictionGameScreen> {
  String _difficulty = 'Orta';

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2D0B5A), Color(0xFF1A063B), Color(0xFF0D0226)],
  );

  @override
  void initState() {
    super.initState();
    // Her açılışta önceki oyun sonucunu temizle
    Future.microtask(() => ref.read(factFictionProvider.notifier).reset());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(factFictionProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/entertainment');
                        }
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gerçek mi Uydurma mı?',
                            style: GoogleFonts.luckiestGuy(
                              color: Colors.white,
                              fontSize: 17,
                            ),
                          ),
                          if (state.questions.isNotEmpty && !state.isDone)
                            Text(
                              '${state.currentIndex + 1} / ${state.questions.length}',
                              style: GoogleFonts.nunito(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Hak badge
                    ref
                        .watch(entertainmentRemainingProvider)
                        .maybeWhen(
                          data: (r) => _AttemptsBadge(remaining: r),
                          orElse: () => const SizedBox.shrink(),
                        ),
                  ],
                ),
              ),

              // ── İçerik ───────────────────────────────────────────────────
              Expanded(
                child: state.isLoading
                    ? _LoadingView()
                    : state.noAttemptsLeft
                    ? _NoAttemptsView(onWatchAd: () => context.push('/premium'))
                    : state.error != null
                    ? _ErrorView(
                        onRetry: () => ref
                            .read(factFictionProvider.notifier)
                            .load(difficulty: _difficulty),
                      )
                    : state.isDone
                    ? EntertainmentResultView(
                        correctCount: state.correctCount,
                        totalCount: state.questions.length,
                        funCategoryKey: 'gercek_uydurma',
                        difficulty: _difficulty,
                        startedAt: state.startedAt,
                      )
                    : state.questions.isEmpty
                    ? _SelectView(
                        difficulty: _difficulty,
                        onDifficulty: (d) => setState(() => _difficulty = d),
                        onStart: () => ref
                            .read(factFictionProvider.notifier)
                            .load(difficulty: _difficulty),
                      )
                    : _QuestionView(
                        question: state.questions[state.currentIndex],
                        index: state.currentIndex,
                        total: state.questions.length,
                        given: state.answers[state.currentIndex],
                        onAnswer: (isReal) {
                          ref
                              .read(factFictionProvider.notifier)
                              .answer(state.currentIndex, isReal);
                        },
                        onNext: () =>
                            ref.read(factFictionProvider.notifier).next(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Zorluk Seçimi ─────────────────────────────────────────────────────────────

class _SelectView extends StatelessWidget {
  final String difficulty;
  final ValueChanged<String> onDifficulty;
  final VoidCallback onStart;

  static const _difficulties = ['Kolay', 'Orta', 'Zor'];
  static const _accent = Color(0xFF6A11CB);

  const _SelectView({
    required this.difficulty,
    required this.onDifficulty,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.20),
              shape: BoxShape.circle,
              border: Border.all(
                color: _accent.withValues(alpha: 0.65),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: 52,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Gerçek mi Uydurma mı?',
            textAlign: TextAlign.center,
            style: GoogleFonts.luckiestGuy(color: Colors.white, fontSize: 24),
          ),
          const SizedBox(height: 10),
          Text(
            'Her ifadeyi gerçek mi yoksa uydurma mı olduğunu söyle!\n10 soru, dikkatli ol...',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Zorluk Seç',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _difficulties.map((d) {
              final sel = d == difficulty;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: d == _difficulties.last ? 0 : 8,
                  ),
                  child: GestureDetector(
                    onTap: () => onDifficulty(d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: sel
                            ? _difficultyColor(d)
                            : Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: sel
                              ? Colors.white.withValues(alpha: 0.78)
                              : Colors.white38,
                          width: sel ? 2 : 1.5,
                        ),
                        boxShadow: sel
                            ? [
                                BoxShadow(
                                  color: _difficultyColor(
                                    d,
                                  ).withValues(alpha: 0.45),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _difficultyIcon(d),
                            color: Colors.white,
                            size: 17,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            d,
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow_rounded, size: 24),
                  const SizedBox(width: 6),
                  Text(
                    'Başla',
                    style: GoogleFonts.luckiestGuy(
                      fontSize: 17,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Zorluk renk/ikon yardımcıları ───────────────────────────────────────────

Color _difficultyColor(String d) {
  switch (d) {
    case 'Kolay':
      return const Color(0xFF43A047);
    case 'Zor':
      return const Color(0xFFE05252);
    default:
      return const Color(0xFFE2A52C);
  }
}

IconData _difficultyIcon(String d) {
  switch (d) {
    case 'Kolay':
      return Icons.sentiment_satisfied_alt_rounded;
    case 'Zor':
      return Icons.local_fire_department_rounded;
    default:
      return Icons.psychology_alt_rounded;
  }
}

// ── Soru Kartı ────────────────────────────────────────────────────────────────

class _QuestionView extends StatefulWidget {
  final FactOrFictionQuestionModel question;
  final int index;
  final int total;
  final bool? given; // kullanıcı cevap verdiyse: true=gerçek, false=uydurma
  final ValueChanged<bool> onAnswer;
  final VoidCallback onNext;

  const _QuestionView({
    required this.question,
    required this.index,
    required this.total,
    required this.given,
    required this.onAnswer,
    required this.onNext,
  });

  @override
  State<_QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<_QuestionView>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeIn = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
  }

  @override
  void didUpdateWidget(_QuestionView old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      _anim.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final answered = widget.given != null;
    final correct = answered && widget.given == widget.question.isReal;

    return FadeTransition(
      opacity: _fadeIn,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // İlerleme çubuğu
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (widget.index + 1) / widget.total,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation(Color(0xFF6A11CB)),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 20),

            // İfade kartı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Text(
                widget.question.statement,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Cevap butonları
            if (!answered) ...[
              Row(
                children: [
                  Expanded(
                    child: _AnswerButton(
                      label: 'Gerçek',
                      color: const Color(0xFF1B8A4A),
                      onTap: () => widget.onAnswer(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AnswerButton(
                      label: 'Uydurma',
                      color: const Color(0xFFB81F1F),
                      onTap: () => widget.onAnswer(false),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Cevap gösterimi
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: correct
                      ? const Color(0xFF1B8A4A).withValues(alpha: 0.3)
                      : const Color(0xFFB81F1F).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: correct
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFEF5350),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      correct ? 'Doğru!' : 'Yanlış!',
                      style: GoogleFonts.luckiestGuy(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.question.explanation,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6A11CB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    widget.index + 1 < widget.total
                        ? 'Sıradaki →'
                        : 'Sonucu Gör',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.luckiestGuy(color: Colors.white, fontSize: 15),
          ),
        ),
      ),
    );
  }
}

// ── Yardımcı görünümler ───────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: Colors.white54),
        SizedBox(height: 16),
        Text(
          'Sorular hazırlanıyor...',
          style: TextStyle(color: Colors.white60),
        ),
      ],
    ),
  );
}

class _NoAttemptsView extends StatelessWidget {
  final VoidCallback onWatchAd;
  const _NoAttemptsView({required this.onWatchAd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🚫', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Günlük Hakkın Bitti',
              style: GoogleFonts.luckiestGuy(color: Colors.white, fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              'Premium ile günlük daha fazla oyun hakkı kazan!',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onWatchAd,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A11CB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Premium’u İncele',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.push('/premium'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white70),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                '✨ Premium\'a Geç',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'Bir hata oluştu',
            style: GoogleFonts.nunito(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white24,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }
}

// ── Attempts Badge ────────────────────────────────────────────────────────────

class _AttemptsBadge extends StatelessWidget {
  final int remaining;
  const _AttemptsBadge({required this.remaining});

  @override
  Widget build(BuildContext context) {
    final color = remaining > 0
        ? const Color(0xFF43A047)
        : const Color(0xFFE53935);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.8), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, color: Color(0xFFFFD55A), size: 19),
          const SizedBox(width: 5),
          Text(
            '$remaining',
            style: GoogleFonts.luckiestGuy(color: Colors.white, fontSize: 19),
          ),
          const SizedBox(width: 4),
          Text(
            'quiz',
            style: GoogleFonts.nunito(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
