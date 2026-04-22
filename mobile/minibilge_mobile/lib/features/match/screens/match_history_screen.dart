import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/match_provider.dart';

/// Match history screen - shows past matches and statistics
class MatchHistoryScreen extends ConsumerStatefulWidget {
  final String childId;

  const MatchHistoryScreen({super.key, required this.childId});

  @override
  ConsumerState<MatchHistoryScreen> createState() =>
      _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends ConsumerState<MatchHistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    ref.read(matchProvider.notifier).loadHistory(widget.childId);
  }

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(matchProvider);
    final history = matchState.history;
    final stats = matchState.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maç Geçmişi'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Statistics section
              if (stats != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'İstatistiklerim',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            context: context,
                            icon: Icons.sports_esports,
                            label: 'Toplam Maç',
                            value: '${stats.gamesPlayed}',
                            color: Colors.blue,
                          ),
                          _buildStatItem(
                            context: context,
                            icon: Icons.emoji_events,
                            label: 'Kazanılan',
                            value: '${stats.gamesWon}',
                            color: Colors.green,
                          ),
                          _buildStatItem(
                            context: context,
                            icon: Icons.close,
                            label: 'Kaybedilen',
                            value: '${stats.gamesLost}',
                            color: Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            context: context,
                            icon: Icons.percent,
                            label: 'Kazanma Oranı',
                            value: '${(stats.winRate * 100).toStringAsFixed(1)}%',
                            color: Colors.amber,
                          ),
                          _buildStatItem(
                            context: context,
                            icon: Icons.star,
                            label: 'Ort. Puan',
                            value: stats.averageScore.toStringAsFixed(0),
                            color: Colors.purple,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // History section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Geçmiş Maçlar',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),

              if (history.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          size: 80,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz maç oynamadın',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.5),
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'İlk maçını oynamak için "Canlı Yarış"a başla!',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.5),
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final match = history[index];
                    return _buildMatchCard(context, match);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMatchCard(BuildContext context, matchHistoryItem) {
    final date = matchHistoryItem.playedAt;
    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final isWinner = matchHistoryItem.isWinner;
    final isDraw = matchHistoryItem.isDraw;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Could navigate to detailed match view
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Win/Loss/Draw indicator
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isDraw
                      ? Colors.orange.withOpacity(0.2)
                      : isWinner
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDraw ? Icons.handshake : isWinner ? Icons.emoji_events : Icons.close,
                  color: isDraw ? Colors.orange : isWinner ? Colors.green : Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),

              // Match details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isDraw ? 'Berabere' : isWinner ? 'Kazandın' : 'Kaybettin',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDraw ? Colors.orange : isWinner ? Colors.green : Colors.red,
                              ),
                        ),
                        const Spacer(),
                        Text(
                          '${matchHistoryItem.myScore} - ${matchHistoryItem.opponentScore}',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'vs ${matchHistoryItem.opponentName}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.chevron_right,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
