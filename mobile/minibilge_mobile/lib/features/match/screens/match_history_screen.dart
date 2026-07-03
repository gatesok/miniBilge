import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/match_models.dart';
import '../providers/match_provider.dart';
import '../../challenge/services/challenge_service.dart';
import '../../challenge/models/challenge_models.dart';

// ── Unified history entry ─────────────────────────────────────────────────────

class _HistoryEntry {
  final MatchHistoryItem? liveMatch;
  final ChallengeDto? challenge;

  const _HistoryEntry.live(MatchHistoryItem m)
      : liveMatch = m,
        challenge = null;
  const _HistoryEntry.challenge(ChallengeDto c)
      : challenge = c,
        liveMatch = null;

  DateTime get date =>
      liveMatch?.playedAt ?? challenge!.createdAt;
}

/// Match history screen - shows past matches and statistics
class MatchHistoryScreen extends ConsumerStatefulWidget {
  final String childId;

  const MatchHistoryScreen({super.key, required this.childId});

  @override
  ConsumerState<MatchHistoryScreen> createState() =>
      _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends ConsumerState<MatchHistoryScreen> {
  List<ChallengeDto> _challengeHistory = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    ref.read(matchProvider.notifier).loadHistory(widget.childId);
    _loadChallengeHistory();
  }

  Future<void> _loadChallengeHistory() async {
    try {
      final service = ref.read(challengeServiceProvider);
      final history = await service.getHistory(widget.childId);
      if (mounted) setState(() => _challengeHistory = history);
    } catch (_) {}
  }

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
  );

  @override
  Widget build(BuildContext context) {
    final matchState      = ref.watch(matchProvider);
    final stats           = matchState.stats;

    // Combine & sort by date descending — son 20 karşılaşma
    final entries = <_HistoryEntry>[
      ...matchState.history.map(_HistoryEntry.live),
      ..._challengeHistory
          .where((c) => c.status.isFinished)
          .map(_HistoryEntry.challenge),
    ]..sort((a, b) => b.date.compareTo(a.date));
    final recent = entries.take(20).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.28),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1.5),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Geçmiş',
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 24,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                              blurRadius: 0,
                              color: Color(0xFF3D35CC),
                              offset: Offset(2, 2))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Body
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _loadData(),
                  color: const Color(0xFF7B61FF),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Statistics card
                        if (stats != null) ...[
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.45),
                                  width: 1.5),
                            ),
                            child: Column(
                              children: [
                                Text('🏆 İstatistiklerim',
                                    style: GoogleFonts.luckiestGuy(
                                        fontSize: 20,
                                        color: Colors.white,
                                        shadows: const [
                                          Shadow(
                                              blurRadius: 0,
                                              color: Color(0xFF3D35CC),
                                              offset: Offset(2, 2))
                                        ])),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _StatBubble(
                                        icon: '🎮',
                                        label: 'Toplam\nMaç',
                                        value: '${stats.gamesPlayed}',
                                        color: const Color(0xFF4FC3F7)),
                                    _StatBubble(
                                        icon: '🏆',
                                        label: 'Kazanılan',
                                        value: '${stats.gamesWon}',
                                        color: const Color(0xFF66BB6A)),
                                    _StatBubble(
                                        icon: '💀',
                                        label: 'Kaybedilen',
                                        value: '${stats.gamesLost}',
                                        color: const Color(0xFFEF5350)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _StatBubble(
                                        icon: '📊',
                                        label: 'Kazanma\nOranı',
                                        value:
                                            '${(stats.winRate * 100).toStringAsFixed(1)}%',
                                        color: const Color(0xFFFFB300)),
                                    _StatBubble(
                                        icon: '⭐',
                                        label: 'Ort.\nPuan',
                                        value:
                                            stats.averageScore.toStringAsFixed(0),
                                        color: const Color(0xFFAB47BC)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        // History label
                        Text('📋 Geçmiş Karşılaşmalar',
                            style: GoogleFonts.luckiestGuy(
                                fontSize: 20,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(
                                      blurRadius: 0,
                                      color: Color(0xFF3D35CC),
                                      offset: Offset(2, 2))
                                ])),
                        const SizedBox(height: 12),
                        if (recent.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(36),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.45),
                                  width: 1.5),
                            ),
                            child: Column(
                              children: [
                                const Text('⚔️',
                                    style: TextStyle(fontSize: 64)),
                                const SizedBox(height: 16),
                                Text('Henüz karşılaşma yok',
                                    style: GoogleFonts.luckiestGuy(
                                        fontSize: 20,
                                        color: Colors.white,
                                        shadows: const [
                                          Shadow(
                                              blurRadius: 0,
                                              color: Color(0xFF3D35CC),
                                              offset: Offset(2, 2))
                                        ])),
                                const SizedBox(height: 8),
                                Text(
                                  'Canlı yarış oyna veya arkadaşına meydan oku!',
                                  style: GoogleFonts.nunito(
                                      color: Colors.white.withOpacity(0.85),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          ...recent.map((e) => e.liveMatch != null
                              ? _buildLiveMatchCard(e.liveMatch!)
                              : _buildChallengeCard(
                                  context, e.challenge!, widget.childId)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveMatchCard(MatchHistoryItem item) {
    final date = item.playedAt;
    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final isWinner = item.isWinner;
    final isDraw   = item.isDraw;

    final resultEmoji = isDraw ? '🤝' : isWinner ? '🏆' : '💀';
    final resultText  = isDraw ? 'Berabere' : isWinner ? 'Kazandın!' : 'Kaybettin';
    final resultColor = isDraw
        ? const Color(0xFFFFB300)
        : isWinner
            ? const Color(0xFF66BB6A)
            : const Color(0xFFEF5350);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.22),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: resultColor.withOpacity(0.5), width: 1.5),
        ),
        child: Row(
          children: [
            // Result badge
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: resultColor.withOpacity(0.25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: resultColor.withOpacity(0.6), width: 1.5),
              ),
              child: Center(
                child:
                    Text(resultEmoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(resultText,
                          style: GoogleFonts.nunito(
                              color: resultColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 16)),
                      const Spacer(),
                      Text(
                        '${item.myScore} – ${item.opponentScore}',
                        style: GoogleFonts.luckiestGuy(
                            color: Colors.white,
                            fontSize: 18,
                            shadows: const [
                              Shadow(
                                  blurRadius: 0,
                                  color: Color(0xFF3D35CC),
                                  offset: Offset(1, 1))
                            ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Type + opponent row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE64A19),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('⚡ Canlı Yarış',
                            style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 11)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('vs ${item.opponentName}',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(formattedDate,
                      style: GoogleFonts.nunito(
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(
      BuildContext context, ChallengeDto c, String myChildId) {
    final isChallenger = c.challengerId == myChildId;
    final myScore  = isChallenger ? (c.challengerScore ?? 0) : (c.challengeeScore ?? 0);
    final oppScore = isChallenger ? (c.challengeeScore ?? 0) : (c.challengerScore ?? 0);
    final opponentName = isChallenger ? c.challengeeName : c.challengerName;

    final isWinner = myScore > oppScore;
    final isDraw   = myScore == oppScore;

    final resultEmoji = isDraw ? '🤝' : isWinner ? '🏆' : '💀';
    final resultText  = isDraw ? 'Berabere' : isWinner ? 'Kazandın!' : 'Kaybettin';
    final resultColor = isDraw
        ? const Color(0xFFFFB300)
        : isWinner
            ? const Color(0xFF66BB6A)
            : const Color(0xFFEF5350);

    final date = c.createdAt.toLocal();
    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.22),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: resultColor.withOpacity(0.5), width: 1.5),
        ),
        child: Row(
          children: [
            // Result badge
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: resultColor.withOpacity(0.25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: resultColor.withOpacity(0.6), width: 1.5),
              ),
              child: Center(
                child:
                    Text(resultEmoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(resultText,
                          style: GoogleFonts.nunito(
                              color: resultColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 16)),
                      const Spacer(),
                      Text(
                        '$myScore – $oppScore',
                        style: GoogleFonts.luckiestGuy(
                            color: Colors.white,
                            fontSize: 18,
                            shadows: const [
                              Shadow(
                                  blurRadius: 0,
                                  color: Color(0xFF3D35CC),
                                  offset: Offset(1, 1))
                            ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Type + subject row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5C4FC7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('⚔️ Meydan Okuma',
                            style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 11)),
                      ),
                      if (c.subjectName.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(c.subjectName,
                              style: GoogleFonts.nunito(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text('vs $opponentName',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ),
                    ],
                  ),
                  if (c.levelName.isNotEmpty)
                    Text(c.levelName,
                        style: GoogleFonts.nunito(
                            color: Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                            fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(formattedDate,
                      style: GoogleFonts.nunito(
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBubble extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatBubble(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.25),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.6), width: 1.5),
          ),
          child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 26))),
        ),
        const SizedBox(height: 8),
        Text(value,
            style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        Text(label,
            style: GoogleFonts.nunito(
                color: Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w600,
                fontSize: 11),
            textAlign: TextAlign.center),
      ],
    );
  }
}

