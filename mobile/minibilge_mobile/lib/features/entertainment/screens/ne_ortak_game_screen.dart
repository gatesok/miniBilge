import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/entertainment_models.dart';
import '../providers/entertainment_provider.dart';
import '../../../../core/services/ad_service.dart';
import 'entertainment_result_view.dart';

class NeOrtakGameScreen extends ConsumerStatefulWidget {
  const NeOrtakGameScreen({super.key});

  @override
  ConsumerState<NeOrtakGameScreen> createState() => _NeOrtakGameScreenState();
}

class _NeOrtakGameScreenState extends ConsumerState<NeOrtakGameScreen> {
  String  _difficulty     = 'Orta';
  String? _selectedAnswer;
  bool    _answered       = false;

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end:   Alignment.bottomCenter,
    colors: [Color(0xFF1B4332), Color(0xFF0D2B1F), Color(0xFF051409)],
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(neOrtakProvider.notifier).reset());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(neOrtakProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────────────
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
                        else context.go('/entertainment');
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🔗 Ne Ortak?',
                              style: GoogleFonts.luckiestGuy(
                                  color: Colors.white, fontSize: 20)),
                          if (state.questions.isNotEmpty && !state.isDone)
                            Text(
                              '${state.currentIndex + 1} / ${state.questions.length}',
                              style: GoogleFonts.nunito(
                                  color: Colors.white60, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                    ref.watch(entertainmentRemainingProvider).maybeWhen(
                      data:   (r) => _AttemptsBadge(remaining: r),
                      orElse: ()  => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

              // ── İçerik ───────────────────────────────────────────────────
              Expanded(
                child: state.isLoading
                    ? _LoadingView()
                    : state.noAttemptsLeft
                        ? _NoAttemptsView(onWatchAd: () {
                            RewardedAdService.showRewardedAd(
                              onRewarded: () async {
                                await ref
                                    .read(neOrtakProvider.notifier)
                                    .addBonusAttempt();
                                ref.invalidate(entertainmentRemainingProvider);
                              },
                            );
                          })
                        : state.error != null
                            ? _ErrorView(onRetry: () {
                                setState(() {
                                  _selectedAnswer = null;
                                  _answered       = false;
                                });
                                ref
                                    .read(neOrtakProvider.notifier)
                                    .load(difficulty: _difficulty);
                              })
                            : state.isDone
                                ? EntertainmentResultView(
                                    correctCount: state.correctCount,
                                    totalCount:   state.questions.length,
                                  )
                                : state.questions.isEmpty
                                    ? _SelectView(
                                        difficulty:   _difficulty,
                                        onDifficulty: (d) =>
                                            setState(() => _difficulty = d),
                                        onStart: () {
                                          setState(() {
                                            _selectedAnswer = null;
                                            _answered       = false;
                                          });
                                          ref
                                              .read(neOrtakProvider.notifier)
                                              .load(difficulty: _difficulty);
                                        },
                                      )
                                    : _QuestionView(
                                        question: state.questions[
                                            state.currentIndex],
                                        index:    state.currentIndex,
                                        total:    state.questions.length,
                                        selectedAnswer: _selectedAnswer,
                                        answered:       _answered,
                                        onSelect: (a) => setState(
                                            () => _selectedAnswer = a),
                                        onSubmit: () {
                                          if (_selectedAnswer == null) return;
                                          final isCorrect = _selectedAnswer ==
                                              state
                                                  .questions[
                                                      state.currentIndex]
                                                  .correctAnswer;
                                          ref
                                              .read(neOrtakProvider.notifier)
                                              .answer(state.currentIndex,
                                                  isCorrect);
                                          setState(() => _answered = true);
                                        },
                                        onNext: () {
                                          ref
                                              .read(neOrtakProvider.notifier)
                                              .next();
                                          setState(() {
                                            _selectedAnswer = null;
                                            _answered       = false;
                                          });
                                        },
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
  final String   difficulty;
  final ValueChanged<String> onDifficulty;
  final VoidCallback         onStart;
  static const _difficulties = ['Kolay', 'Orta', 'Zor'];

  const _SelectView({
    required this.difficulty,
    required this.onDifficulty,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔗', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text('Ne Ortak?',
              style: GoogleFonts.luckiestGuy(
                  color: Colors.white, fontSize: 26)),
          const SizedBox(height: 8),
          Text(
            '4 ipucu, 1 gizli bağlantı.\nHepsinin ortak noktasını bul!',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
                color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 28),
          Text('Zorluk Seviyesi',
              style: GoogleFonts.nunito(
                  color: Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _difficulties.map((d) {
              final sel = d == difficulty;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: GestureDetector(
                  onTap: () => onDifficulty(d),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: sel
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? Colors.white : Colors.white30),
                    ),
                    child: Text(d,
                        style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight:
                                sel ? FontWeight.w800 : FontWeight.w500,
                            fontSize: 13)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D6A4F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Başla 🔍',
                  style: GoogleFonts.luckiestGuy(
                      fontSize: 16, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Soru Görünümü ─────────────────────────────────────────────────────────────

class _QuestionView extends StatefulWidget {
  final NeOrtakQuestionModel question;
  final int    index;
  final int    total;
  final String? selectedAnswer;
  final bool   answered;
  final ValueChanged<String> onSelect;
  final VoidCallback         onSubmit;
  final VoidCallback         onNext;

  const _QuestionView({
    required this.question,
    required this.index,
    required this.total,
    required this.selectedAnswer,
    required this.answered,
    required this.onSelect,
    required this.onSubmit,
    required this.onNext,
  });

  @override
  State<_QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<_QuestionView>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
  }

  @override
  void didUpdateWidget(_QuestionView old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) _anim.forward(from: 0);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect =
        widget.answered && widget.selectedAnswer == widget.question.correctAnswer;

    return FadeTransition(
      opacity: _fade,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          children: [
            // İlerleme
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (widget.index + 1) / widget.total,
                backgroundColor: Colors.white12,
                valueColor:
                    const AlwaysStoppedAnimation(Color(0xFF52B788)),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 16),

            // Soru kartı başlığı
            Text('Bu 4 şeyin ortak noktası nedir?',
                style: GoogleFonts.nunito(
                    color: Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),

            // 4 ipucu — 2×2 grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.4,
              children: widget.question.clues.map((clue) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Center(
                    child: Text(clue,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.luckiestGuy(
                            color: Colors.white,
                            fontSize: 15,
                            shadows: const [
                              Shadow(
                                  blurRadius: 0,
                                  color: Colors.black38,
                                  offset: Offset(1, 1)),
                            ])),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Şıklar
            if (!widget.answered) ...[
              ...widget.question.options.map((opt) => _OptionTile(
                    label:    opt,
                    selected: opt == widget.selectedAnswer,
                    onTap:    () => widget.onSelect(opt),
                  )),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      widget.selectedAnswer != null ? widget.onSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6A4F),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white12,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Cevapla ✓',
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
            ] else ...[
              // Cevap sonucu
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? const Color(0xFF1B8A4A).withOpacity(0.3)
                      : const Color(0xFFB81F1F).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: isCorrect
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFEF5350)),
                ),
                child: Column(
                  children: [
                    Text(
                      isCorrect ? '✅ Doğru!' : '❌ Yanlış!',
                      style: GoogleFonts.luckiestGuy(
                          color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '🔗 Ortak bağlantı: ${widget.question.correctAnswer}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.question.explanation,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                          height: 1.4),
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
                    foregroundColor: const Color(0xFF1B4332),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    widget.index + 1 < widget.total
                        ? 'Sıradaki →'
                        : 'Sonucu Gör 🏆',
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String   label;
  final bool     selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2D6A4F).withOpacity(0.5)
              : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color:
                  selected ? const Color(0xFF52B788) : Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected
                  ? const Color(0xFF52B788)
                  : Colors.white38,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: selected
                          ? FontWeight.w800
                          : FontWeight.w500,
                      fontSize: 14)),
            ),
          ],
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
            Text('Sorular hazırlanıyor...',
                style: TextStyle(color: Colors.white60)),
          ],
        ),
      );
}

class _NoAttemptsView extends StatelessWidget {
  final VoidCallback onWatchAd;
  const _NoAttemptsView({required this.onWatchAd});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🚫', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text('Günlük Hakkın Bitti',
                  style: GoogleFonts.luckiestGuy(
                      color: Colors.white, fontSize: 22)),
              const SizedBox(height: 8),
              Text('Reklam izleyerek 1 hak daha kazan!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onWatchAd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D6A4F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('📺 Reklam İzle +1 Hak',
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800, fontSize: 14)),
              ),
            ],
          ),
        ),
      );
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('Bir hata oluştu',
                style: GoogleFonts.nunito(
                    color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white24,
                  foregroundColor: Colors.white),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
}

class _AttemptsBadge extends StatelessWidget {
  final int remaining;
  const _AttemptsBadge({required this.remaining});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: remaining > 0
              ? Colors.white.withOpacity(0.12)
              : Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color:
                  remaining > 0 ? Colors.white24 : Colors.red.shade300),
        ),
        child: Text('$remaining hak',
            style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12)),
      );
}
