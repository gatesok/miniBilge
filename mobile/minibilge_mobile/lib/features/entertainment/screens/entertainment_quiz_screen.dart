import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/entertainment_models.dart';
import '../providers/entertainment_provider.dart';
import '../../../../core/services/ad_service.dart';
import 'entertainment_result_view.dart';

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
    colors: [Color(0xFF0D4F4F), Color(0xFF0A3D3D), Color(0xFF062E2E)],
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(entertainmentQuizProvider.notifier)
          .load(topicKey: widget.topicKey, difficulty: widget.difficulty);
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
                          context.go('/dashboard');
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🎉 Eğlence Quiz',
                            style: GoogleFonts.luckiestGuy(
                              color: Colors.white,
                              fontSize: 18,
                              shadows: const [
                                Shadow(
                                  blurRadius: 0,
                                  color: Color(0xFF004D40),
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${widget.difficulty} · ${widget.topicKey}',
                            style: GoogleFonts.nunito(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
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
                              topicKey: widget.topicKey,
                              difficulty: widget.difficulty,
                            ),
                      )
                    : state.isDone
                    ? EntertainmentResultView(
                        correctCount: state.correctCount,
                        totalCount: state.questions.length,
                      )
                    : state.questions.isEmpty
                    ? _LoadingView()
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

// ── No Attempts ───────────────────────────────────────────────────────────────

class _NoAttemptsView extends ConsumerWidget {
  const _NoAttemptsView();

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
            const Text('⏳', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Günlük hakkın doldu',
              textAlign: TextAlign.center,
              style: GoogleFonts.luckiestGuy(
                color: Colors.white,
                fontSize: 22,
                shadows: const [
                  Shadow(
                    blurRadius: 0,
                    color: Color(0xFF004D40),
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isPremium
                  ? 'Günlük Premium makul kullanım sınırına ulaştın.'
                  : canWatchAd
                  ? 'Günde 3 ücretsiz Eğlence Quiz hakkın var.\nReklam izleyerek +1 hak kazanabilirsin.'
                  : 'Bugünkü ücretsiz ve reklam bonus haklarını kullandın.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 28),
            if (canWatchAd)
              ElevatedButton(
                onPressed: () {
                  RewardedAdService.showRewardedAd(
                    placement: AdPlacements.entertainmentExtraAttempt,
                    onRewarded: () async {
                      await ref
                          .read(entertainmentQuizProvider.notifier)
                          .addBonusAttempt();
                      ref.invalidate(entertainmentRemainingProvider);
                      ref.invalidate(entertainmentUsageStatusProvider);
                      if (context.mounted) context.pop();
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF11998E),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  '📺 Reklam İzle (+1 Hak)',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () {
                if (context.canPop())
                  context.pop();
                else
                  context.go('/dashboard');
              },
              child: Text(
                'Geri Dön',
                style: GoogleFonts.nunito(
                  color: Colors.white60,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
        const SizedBox(height: 14),
        Text(
          'Sorular hazırlanıyor...',
          style: GoogleFonts.nunito(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('😔', style: TextStyle(fontSize: 52)),
        const SizedBox(height: 12),
        Text(
          'Sorular yüklenemedi',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF11998E),
          ),
          child: const Text('Tekrar Dene'),
        ),
      ],
    ),
  );
}

// ── Question ──────────────────────────────────────────────────────────────────

class _QuestionView extends ConsumerWidget {
  final EntertainmentQuestionModel question;
  final int index;
  final int total;
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
            child: Text(
              '${index + 1} / $total',
              textAlign: TextAlign.right,
              style: GoogleFonts.nunito(color: Colors.white60, fontSize: 12),
            ),
          ),
          // Soru metni — beyaz kart, koyu yazı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              question.questionText,
              style: GoogleFonts.nunito(
                color: const Color(0xFF062E2E),
                fontSize: 16,
                fontWeight: FontWeight.w800,
                height: 1.4,
              ),
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

            Color bg = const Color(0xFF0F3D3D);
            Color border = const Color(0xFF11998E).withOpacity(0.5);
            if (given != null) {
              if (correct) {
                bg = const Color(0xFF1B5E20);
                border = const Color(0xFF4CAF50);
              } else if (wrong) {
                bg = const Color(0xFFB71C1C);
                border = const Color(0xFFEF5350);
              }
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
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: given == null
                              ? const Color(0xFF11998E)
                              : Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            letter,
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          text,
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          // Açıklama
          if (given != null && question.explanation != null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF11998E).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF11998E).withOpacity(0.5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.explanation!,
                      style: GoogleFonts.nunito(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Sıradaki / Sonuç butonu
          if (given != null)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: ElevatedButton(
                onPressed: () =>
                    ref.read(entertainmentQuizProvider.notifier).next(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF11998E),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  index + 1 < total ? 'Sıradaki Soru →' : 'Sonucu Gör 🏆',
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
