import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../providers/match_provider.dart';

/// Match result screen - shows winner, scores, and navigation options
class MatchResultScreen extends ConsumerStatefulWidget {
  final String matchId;

  const MatchResultScreen({
    super.key,
    required this.matchId,
  });

  @override
  ConsumerState<MatchResultScreen> createState() => _MatchResultScreenState();
}

class _MatchResultScreenState extends ConsumerState<MatchResultScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    // Fetch latest match data to get winnerId from backend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(matchProvider.notifier).refreshMatch(widget.matchId);
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(matchProvider);
    final match = matchState.currentMatch;
    final myParticipant = matchState.myParticipant;
    final opponent = matchState.opponent;

    if (match == null || myParticipant == null || opponent == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final winnerId = match.winnerId;
    final isDraw = winnerId == null;
    final isWinner = !isDraw &&
        (winnerId == myParticipant.childProfileId ||
            winnerId == myParticipant.id);

    // Show confetti for winner
    if (isWinner) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _confettiController.play();
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Confetti overlay
            if (isWinner)
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple
                  ],
                ),
              ),

            // Main content
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isWinner
                      ? [
                          Colors.green.withOpacity(0.2),
                          Theme.of(context).colorScheme.surface,
                        ]
                      : isDraw
                          ? [
                              Colors.orange.withOpacity(0.2),
                              Theme.of(context).colorScheme.surface,
                            ]
                          : [
                              Colors.red.withOpacity(0.2),
                              Theme.of(context).colorScheme.surface,
                            ],
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Result icon and text
                      if (isWinner) ...[
                        const Icon(
                          Icons.emoji_events,
                          size: 100,
                          color: Colors.amber,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Kazandın! 🎉',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                        ),
                      ] else if (isDraw) ...[
                        const Icon(
                          Icons.handshake,
                          size: 100,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Berabere! 🤝',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                        ),
                      ] else ...[
                        const Icon(
                          Icons.sentiment_dissatisfied,
                          size: 100,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Kaybettin 😢',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        isDraw
                            ? 'Her ikiniz de harika oynadınız!'
                            : isWinner
                                ? 'Harika bir performans!'
                                : 'Bir dahaki sefere!',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      // Score cards
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildPlayerCard(
                            context: context,
                            name: myParticipant.childName,
                            score: myParticipant.score,
                            isWinner: isWinner && !isDraw,
                            avatarId: myParticipant.avatarId,
                          ),
                          _buildPlayerCard(
                            context: context,
                            name: opponent.childName,
                            score: opponent.score,
                            isWinner: !isWinner && !isDraw,
                            avatarId: opponent.avatarId,
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),

                      // Stats
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Maç İstatistikleri',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            _buildStatRow(
                              context: context,
                              label: 'Toplam Soru',
                              value: '${match.questions.length}',
                            ),
                            _buildStatRow(
                              context: context,
                              label: 'Doğru Sayısı',
                              value: '${myParticipant.score ~/ 10}', // 10 points per question
                            ),
                            _buildStatRow(
                              context: context,
                              label: 'Toplam Puan',
                              value: '${myParticipant.score}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Action buttons
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              // Reset and request new match
                              ref.read(matchProvider.notifier).reset();
                              context.pushReplacement(
                                '/match/request',
                              );
                            },
                            icon: const Icon(Icons.replay),
                            label: const Text('Tekrar Oyna'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              padding: const EdgeInsets.all(16),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              ref.read(matchProvider.notifier).reset();
                              context.go('/dashboard');
                            },
                            icon: const Icon(Icons.home),
                            label: const Text('Ana Sayfaya Dön'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () {
                              final childId = myParticipant.childProfileId;
                              context.push('/match/history?childId=$childId');
                            },
                            icon: const Icon(Icons.history),
                            label: const Text('Geçmiş Maçlar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard({
    required BuildContext context,
    required String name,
    required int score,
    required bool isWinner,
    int? avatarId,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWinner
            ? Colors.amber.withOpacity(0.3)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWinner ? Colors.amber : Colors.transparent,
          width: 3,
        ),
      ),
      child: Column(
        children: [
          if (isWinner)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 32,
              ),
            ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name[0].toUpperCase(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            '$score',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          Text(
            'puan',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required BuildContext context,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}
