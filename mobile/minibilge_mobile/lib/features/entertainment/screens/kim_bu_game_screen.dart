import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/entertainment_models.dart';
import '../providers/entertainment_provider.dart';
import '../../../../core/services/ad_service.dart';
import 'entertainment_result_view.dart';

class KimBuGameScreen extends ConsumerStatefulWidget {
  const KimBuGameScreen({super.key});

  @override
  ConsumerState<KimBuGameScreen> createState() => _KimBuGameScreenState();
}

class _KimBuGameScreenState extends ConsumerState<KimBuGameScreen> {
  String _difficulty = 'Orta';
  String? _selectedAnswer; // seçilen ama henüz submit edilmemiş şık
  bool _answered = false;

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A3A5C), Color(0xFF0D2237), Color(0xFF060F1A)],
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(kimBuProvider.notifier).reset());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kimBuProvider);

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
                        if (context.canPop())
                          context.pop();
                        else
                          context.go('/entertainment');
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🕵️ Kim Bu?',
                            style: GoogleFonts.luckiestGuy(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          if (state.hasRound && !state.isDone)
                            Text(
                              'Konu ${state.currentSubjectIndex + 1} / ${state.round!.subjects.length}',
                              style: GoogleFonts.nunito(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
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
                    ? _NoAttemptsView(
                        onWatchAd: () {
                          RewardedAdService.showRewardedAd(
                            placement: AdPlacements.entertainmentExtraAttempt,
                            onRewarded: () async {
                              await ref
                                  .read(kimBuProvider.notifier)
                                  .addBonusAttempt();
                              ref.invalidate(entertainmentRemainingProvider);
                              ref.invalidate(entertainmentUsageStatusProvider);
                            },
                          );
                        },
                      )
                    : state.error != null
                    ? _ErrorView(
                        onRetry: () {
                          setState(() {
                            _selectedAnswer = null;
                            _answered = false;
                          });
                          ref
                              .read(kimBuProvider.notifier)
                              .load(difficulty: _difficulty);
                        },
                      )
                    : state.isDone
                    ? EntertainmentResultView(
                        correctCount: state.correctCount,
                        totalCount: state.round!.subjects.length,
                      )
                    : !state.hasRound
                    ? _SelectView(
                        difficulty: _difficulty,
                        onDifficulty: (d) => setState(() => _difficulty = d),
                        onStart: () {
                          setState(() {
                            _selectedAnswer = null;
                            _answered = false;
                          });
                          ref
                              .read(kimBuProvider.notifier)
                              .load(difficulty: _difficulty);
                        },
                      )
                    : _SubjectView(
                        subject: state.currentSubject!,
                        hintsRevealed: state.hintsRevealed,
                        selectedAnswer: _selectedAnswer,
                        answered: _answered,
                        onSelectAnswer: (a) =>
                            setState(() => _selectedAnswer = a),
                        onSubmit: () {
                          if (_selectedAnswer == null) return;
                          ref
                              .read(kimBuProvider.notifier)
                              .submitAnswer(_selectedAnswer!);
                          setState(() => _answered = true);
                        },
                        onRevealHint: () =>
                            ref.read(kimBuProvider.notifier).revealNextHint(),
                        onNext: () {
                          ref.read(kimBuProvider.notifier).nextSubject();
                          setState(() {
                            _selectedAnswer = null;
                            _answered = false;
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
  final String difficulty;
  final ValueChanged<String> onDifficulty;
  final VoidCallback onStart;

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
          const Text('🕵️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text(
            'Kim Bu?',
            style: GoogleFonts.luckiestGuy(color: Colors.white, fontSize: 26),
          ),
          const SizedBox(height: 8),
          Text(
            '5 ipucu, 1 sır. İpuçları açıldıkça tahmin yap!\nNe kadar erken bilirsen o kadar yüksek puan.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Zorluk Seviyesi',
            style: GoogleFonts.nunito(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
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
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: sel
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? Colors.white : Colors.white30,
                      ),
                    ),
                    child: Text(
                      d,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
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
                backgroundColor: const Color(0xFF1A6CA8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Başla 🔍',
                style: GoogleFonts.luckiestGuy(fontSize: 16, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Konu (İpucu + Seçenekler) Görünümü ───────────────────────────────────────

class _SubjectView extends StatelessWidget {
  final KimBuSubjectModel subject;
  final int hintsRevealed;
  final String? selectedAnswer;
  final bool answered;
  final ValueChanged<String> onSelectAnswer;
  final VoidCallback onSubmit;
  final VoidCallback onRevealHint;
  final VoidCallback onNext;

  const _SubjectView({
    required this.subject,
    required this.hintsRevealed,
    required this.selectedAnswer,
    required this.answered,
    required this.onSelectAnswer,
    required this.onSubmit,
    required this.onRevealHint,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = answered && selectedAnswer == subject.correctAnswer;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Puan göstergesi
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${6 - hintsRevealed} puan',
                style: GoogleFonts.luckiestGuy(
                  color: const Color(0xFFFFD700),
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // İpuçları
          ...List.generate(hintsRevealed, (i) {
            return _HintTile(
              number: i + 1,
              text: subject.hints[i],
              isLast: i == hintsRevealed - 1,
            );
          }),

          const SizedBox(height: 16),

          // Cevap şıkları
          if (!answered) ...[
            ...subject.options.map(
              (opt) => _OptionTile(
                label: opt,
                selected: opt == selectedAnswer,
                onTap: () => onSelectAnswer(opt),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // İpucu iste (5. ipuçtan sonra gizlenir)
                if (hintsRevealed < subject.hints.length)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onRevealHint,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '💡 İpucu İste',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                if (hintsRevealed < subject.hints.length)
                  const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: selectedAnswer != null ? onSubmit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A6CA8),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.white12,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cevapla ✓',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Cevap sonucu
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isCorrect
                    ? const Color(0xFF1B8A4A).withOpacity(0.3)
                    : const Color(0xFFB81F1F).withOpacity(0.3),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCorrect
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFEF5350),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    isCorrect ? '✅ Doğru!' : '❌ Yanlış!',
                    style: GoogleFonts.luckiestGuy(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  if (!isCorrect) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Doğru cevap: ${subject.correctAnswer}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1A3A5C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Sıradaki →',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _HintTile extends StatelessWidget {
  final int number;
  final String text;
  final bool isLast;

  const _HintTile({
    required this.number,
    required this.text,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isLast
            ? Colors.white.withOpacity(0.12)
            : Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isLast ? Colors.white38 : Colors.white12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF1A6CA8).withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunito(
                color: Colors.white.withOpacity(isLast ? 1.0 : 0.7),
                fontSize: 14,
                fontWeight: isLast ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool selected;
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF1A6CA8).withOpacity(0.4)
              : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF4DA6FF)
                : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? const Color(0xFF4DA6FF) : Colors.white38,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
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

class _NoAttemptsView extends ConsumerWidget {
  final VoidCallback onWatchAd;
  const _NoAttemptsView({required this.onWatchAd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usage = ref.watch(entertainmentUsageStatusProvider).valueOrNull;
    final canWatchAd = usage?.canEarnRewardedBonus ?? false;
    final isPremium = usage?.isPremium ?? false;
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
              isPremium
                  ? 'Günlük Premium makul kullanım sınırına ulaştın.'
                  : canWatchAd
                  ? 'Reklam izleyerek 1 hak daha kazan!'
                  : 'Bugünkü reklam bonus haklarını kullandın.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            if (canWatchAd)
              ElevatedButton(
                onPressed: onWatchAd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A6CA8),
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
                  '📺 Reklam İzle +1 Hak',
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

class _AttemptsBadge extends StatelessWidget {
  final int remaining;
  const _AttemptsBadge({required this.remaining});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: remaining > 0
            ? Colors.white.withOpacity(0.12)
            : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: remaining > 0 ? Colors.white24 : Colors.red.shade300,
        ),
      ),
      child: Text(
        '$remaining hak',
        style: GoogleFonts.nunito(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
