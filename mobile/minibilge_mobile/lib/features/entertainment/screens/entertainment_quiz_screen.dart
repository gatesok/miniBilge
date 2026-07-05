import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import '../models/entertainment_models.dart';
import '../providers/entertainment_provider.dart';
import '../services/entertainment_service.dart';
import '../../adaptive_quiz/models/adaptive_quiz_models.dart';
import '../../collection/models/card_dto.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/widgets/card_drop_animation.dart';

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
    // Ekrandan çıkınca hak sayısını yenile
    ref.invalidate(entertainmentRemainingProvider);
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
                    : state.noAttemptsLeft
                        ? const _NoAttemptsView()
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

// ── No Attempts ───────────────────────────────────────────────────────────────

class _NoAttemptsView extends ConsumerWidget {
  const _NoAttemptsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⏳', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text('Günlük hakkın doldu',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.luckiestGuy(
                      color: Colors.white,
                      fontSize: 22,
                      shadows: const [
                        Shadow(
                            blurRadius: 0,
                            color: Color(0xFF004D40),
                            offset: Offset(2, 2))
                      ])),
              const SizedBox(height: 10),
              Text(
                'Günde 3 ücretsiz Eğlence Quiz hakkın var.\nReklam izleyerek +1 hak kazanabilirsin.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () {
                  RewardedAdService.showRewardedAd(
                    onRewarded: () async {
                      await ref
                          .read(entertainmentQuizProvider.notifier)
                          .addBonusAttempt();
                      ref.invalidate(entertainmentRemainingProvider);
                      if (context.mounted) context.pop();
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF11998E),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('📺 Reklam İzle (+1 Hak)',
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800, fontSize: 15)),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () {
                  if (context.canPop()) context.pop();
                  else context.go('/dashboard');
                },
                child: Text('Geri Dön',
                    style: GoogleFonts.nunito(
                        color: Colors.white60,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );
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
  AdaptiveQuizRewardModel? _reward;
  bool _rewardLoading = false;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4));
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchReward());
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _fetchReward() async {
    if (!mounted) return;
    setState(() => _rewardLoading = true);
    try {
      final childId = context
          .findAncestorWidgetOfExactType<EntertainmentQuizScreen>()
          ?.topicKey; // fallback — real childId comes from provider below
      // Get childId from Riverpod via context
      final container = ProviderScope.containerOf(context);
      final child = container.read(selectedChildProvider);
      if (child == null) return;

      final service = container.read(entertainmentServiceProvider);
      final reward  = await service.awardQuiz(
        childId:      child.id,
        correctCount: widget.state.correctCount,
        totalCount:   widget.state.questions.length,
      );

      if (!mounted) return;
      setState(() { _reward = reward; _rewardLoading = false; });

      // Kart animasyonu
      if (reward.cardDropped && reward.cardName != null) {
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) {
          await CardDropAnimation.show(
            context,
            drop: CardDropResult(
              cardId:     '',
              cardName:   reward.cardName!,
              rarity:     reward.cardRarity     ?? 'common',
              imageAsset: reward.cardImageAsset ?? '',
              isNew:      true,
            ),
          );
        }
      }

      // Konfeti (%80+)
      final pct = widget.state.questions.isNotEmpty
          ? widget.state.correctCount / widget.state.questions.length
          : 0.0;
      if (pct >= 0.8 && mounted) _confetti.play();
    } catch (_) {
      if (mounted) setState(() => _rewardLoading = false);
    }
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

              // Ödüller
              const SizedBox(height: 20),
              if (_rewardLoading)
                const CircularProgressIndicator(color: Colors.white54)
              else if (_reward != null && _reward!.starsEarned > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text('+${_reward!.starsEarned} Yıldız',
                          style: GoogleFonts.luckiestGuy(
                              color: Colors.white, fontSize: 18)),
                      if (_reward!.badgeCount > 0) ...[
                        const SizedBox(width: 16),
                        const Text('🏅', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 6),
                        Text('+${_reward!.badgeCount} Rozet',
                            style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                      ],
                    ],
                  ),
                ),

              const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Hak sayısını geri dönmeden ÖNCE invalidate et
                      ProviderScope.containerOf(context)
                          .invalidate(entertainmentRemainingProvider);
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
