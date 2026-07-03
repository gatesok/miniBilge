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
    colors: [Color(0xFF4FACFE), Color(0xFF7B6FCD), Color(0xFF9B8FE8)],
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

    final resultText  = isDraw ? 'Berabere 🤝' : isWinner ? 'Kazandın 🏆' : 'Kaybettin 😔';
    final resultColor = isDraw
        ? const Color(0xFF1976D2)
        : isWinner ? const Color(0xFF43A047) : const Color(0xFFE53935);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A0E52).withOpacity(0.22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.30)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE64A19).withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFE64A19).withOpacity(0.5)),
                    ),
                    child: item.opponentAvatarUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              item.opponentAvatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                  child: Text('⚡',
                                      style: TextStyle(fontSize: 20))),
                            ),
                          )
                        : const Center(
                            child: Text('⚡', style: TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'vs ${item.opponentName}',
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14),
                        ),
                        Text(
                          '⚡ Canlı Yarış  ·  ${formattedDate}',
                          style: GoogleFonts.nunito(
                              color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF43A047),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Tamamlandı',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Result banner
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: resultColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  resultText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14),
                ),
              ),
              // Score boxes
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Expanded(child: _ScoreBox('Sen', item.myScore, null,
                        isHigher: item.myScore > item.opponentScore)),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('vs',
                          style: GoogleFonts.nunito(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                    Expanded(
                        child: _ScoreBox(item.opponentName, item.opponentScore,
                            null,
                            isHigher: item.opponentScore > item.myScore)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeCard(
      BuildContext context, ChallengeDto c, String myChildId) {
    final isChallenger = c.challengerId == myChildId;
    final myScore =
        isChallenger ? (c.challengerScore ?? 0) : (c.challengeeScore ?? 0);
    final oppScore =
        isChallenger ? (c.challengeeScore ?? 0) : (c.challengerScore ?? 0);
    final opponentName =
        isChallenger ? c.challengeeName : c.challengerName;
    final opponentAvatar =
        isChallenger ? c.challengeeAvatarUrl : c.challengerAvatarUrl;

    final isWinner = myScore > oppScore;
    final isDraw   = myScore == oppScore;

    final resultText  = isDraw ? 'Berabere 🤝' : isWinner ? 'Kazandın 🏆' : 'Kaybettin 😔';
    final resultColor = isDraw
        ? const Color(0xFF1976D2)
        : isWinner ? const Color(0xFF43A047) : const Color(0xFFE53935);

    final date = c.createdAt.toLocal();
    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A0E52).withOpacity(0.22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.30)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    backgroundImage: opponentAvatar != null
                        ? NetworkImage(opponentAvatar)
                        : null,
                    child: opponentAvatar == null
                        ? Text(
                            opponentName.isNotEmpty
                                ? opponentName[0]
                                : '?',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white))
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isChallenger
                              ? 'Sen → $opponentName'
                              : '$opponentName → Sen',
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14),
                        ),
                        Text(
                          '⚔️ Meydan Okuma · ${c.subjectName} · ${c.levelName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                              color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF43A047),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Tamamlandı',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Result banner
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: resultColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  resultText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14),
                ),
              ),
              // Score boxes
              if (c.challengerScore != null && c.challengeeScore != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                          child: _ScoreBox('Sen', myScore, c.totalQuestions,
                              isHigher: myScore > oppScore)),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('vs',
                            style: GoogleFonts.nunito(
                                color: Colors.white54,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ),
                      Expanded(
                          child: _ScoreBox(
                              opponentName, oppScore, c.totalQuestions,
                              isHigher: oppScore > myScore)),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(formattedDate,
                    style: GoogleFonts.nunito(
                        color: Colors.white54,
                        fontWeight: FontWeight.w500,
                        fontSize: 11)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final String label;
  final int score;
  final int? total;
  final bool isHigher;

  const _ScoreBox(this.label, this.score, this.total,
      {required this.isHigher});

  @override
  Widget build(BuildContext context) {
    final scoreColor = isHigher
        ? const Color(0xFF66BB6A)
        : const Color(0xFFEF9A9A);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                  color: Colors.white70, fontSize: 11)),
          Text(
            total != null ? '$score/$total' : '$score',
            style: GoogleFonts.nunito(
                color: scoreColor,
                fontWeight: FontWeight.w800,
                fontSize: 15),
          ),
        ],
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

