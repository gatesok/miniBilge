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

  DateTime get date => liveMatch?.playedAt ?? challenge!.createdAt;
}

/// Match history screen - shows past matches and statistics
class MatchHistoryScreen extends ConsumerStatefulWidget {
  final String childId;

  const MatchHistoryScreen({super.key, required this.childId});

  @override
  ConsumerState<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
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
    final matchState = ref.watch(matchProvider);
    final stats = matchState.stats;

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
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
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
                            offset: Offset(2, 2),
                          ),
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
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.45),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.insights_rounded,
                                      color: Color(0xFFFFD54F),
                                      size: 25,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'İstatistiklerim',
                                      style: GoogleFonts.luckiestGuy(
                                        fontSize: 20,
                                        color: Colors.white,
                                        shadows: const [
                                          Shadow(
                                            blurRadius: 0,
                                            color: Color(0xFF3D35CC),
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _StatBubble(
                                      icon: Icons.sports_esports_rounded,
                                      label: 'Toplam\nMaç',
                                      value: '${stats.gamesPlayed}',
                                      color: const Color(0xFF4FC3F7),
                                    ),
                                    _StatBubble(
                                      icon: Icons.emoji_events_rounded,
                                      label: 'Kazanılan',
                                      value: '${stats.gamesWon}',
                                      color: const Color(0xFF66BB6A),
                                    ),
                                    _StatBubble(
                                      icon:
                                          Icons.sentiment_dissatisfied_rounded,
                                      label: 'Kaybedilen',
                                      value: '${stats.gamesLost}',
                                      color: const Color(0xFFEF5350),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _StatBubble(
                                      icon: Icons.trending_up_rounded,
                                      label: 'Kazanma\nOranı',
                                      value:
                                          '${(stats.winRate * 100).toStringAsFixed(1)}%',
                                      color: const Color(0xFFFFB300),
                                    ),
                                    _StatBubble(
                                      icon: Icons.star_rounded,
                                      label: 'Ort.\nPuan',
                                      value: stats.averageScore.toStringAsFixed(
                                        0,
                                      ),
                                      color: const Color(0xFFAB47BC),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        // History label
                        Row(
                          children: [
                            const Icon(
                              Icons.history_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Geçmiş Karşılaşmalar',
                              style: GoogleFonts.luckiestGuy(
                                fontSize: 20,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(
                                    blurRadius: 0,
                                    color: Color(0xFF3D35CC),
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (recent.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(36),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.45),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/icon/dashboard_challenge.png',
                                  width: 76,
                                  height: 76,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Henüz karşılaşma yok',
                                  style: GoogleFonts.luckiestGuy(
                                    fontSize: 20,
                                    color: Colors.white,
                                    shadows: const [
                                      Shadow(
                                        blurRadius: 0,
                                        color: Color(0xFF3D35CC),
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Canlı yarış oyna veya arkadaşına meydan oku!',
                                  style: GoogleFonts.nunito(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          ...recent.map(
                            (e) => e.liveMatch != null
                                ? _buildLiveMatchCard(e.liveMatch!)
                                : _buildChallengeCard(
                                    context,
                                    e.challenge!,
                                    widget.childId,
                                  ),
                          ),
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
    final isDraw = item.isDraw;

    final resultText = isDraw
        ? 'Berabere'
        : isWinner
        ? 'Kazandın'
        : 'Bu kez rakibin kazandı';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A0E52).withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
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
                  _HistoryAvatar(
                    avatarValue: item.opponentAvatarUrl,
                    name: item.opponentName,
                    size: 44,
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
                            fontSize: 14,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.bolt_rounded,
                              color: Color(0xFFFFC857),
                              size: 15,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Canlı Yarış · $formattedDate',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.nunito(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF43A047),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Tamamlandı',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _HistoryResultPanel(
                resultText: resultText,
                isWinner: isWinner,
                isDraw: isDraw,
                myScore: item.myScore,
                opponentScore: item.opponentScore,
                opponentName: item.opponentName,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeCard(
    BuildContext context,
    ChallengeDto c,
    String myChildId,
  ) {
    final isChallenger = c.challengerId == myChildId;
    final myScore = isChallenger
        ? (c.challengerScore ?? 0)
        : (c.challengeeScore ?? 0);
    final oppScore = isChallenger
        ? (c.challengeeScore ?? 0)
        : (c.challengerScore ?? 0);
    final opponentName = isChallenger ? c.challengeeName : c.challengerName;
    final opponentAvatar = isChallenger
        ? c.challengeeAvatarUrl
        : c.challengerAvatarUrl;

    final isWinner = myScore > oppScore;
    final isDraw = myScore == oppScore;

    final resultText = isDraw
        ? 'Berabere'
        : isWinner
        ? 'Kazandın'
        : 'Bu kez rakibin kazandı';

    final date = c.createdAt.toLocal();
    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A0E52).withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
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
                  _HistoryAvatar(
                    avatarValue: opponentAvatar,
                    name: opponentName,
                    size: 44,
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
                            fontSize: 14,
                          ),
                        ),
                        Row(
                          children: [
                            Image.asset(
                              'assets/icon/dashboard_challenge.png',
                              width: 16,
                              height: 16,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Meydan Okuma · ${c.contentLabel}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.nunito(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            if (c.hasDifficultyBadge) ...[
                              const SizedBox(width: 6),
                              _DifficultyBadge(label: c.difficultyLabel),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF43A047),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Tamamlandı',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (c.challengerScore != null && c.challengeeScore != null)
                _HistoryResultPanel(
                  resultText: resultText,
                  isWinner: isWinner,
                  isDraw: isDraw,
                  myScore: myScore,
                  opponentScore: oppScore,
                  opponentName: opponentName,
                  totalQuestions: c.totalQuestions,
                ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  formattedDate,
                  style: GoogleFonts.nunito(
                    color: Colors.white54,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Zorluk rozeti ────────────────────────────────────────────────────────────

class _DifficultyBadge extends StatelessWidget {
  final String label;
  const _DifficultyBadge({required this.label});

  Color get _color {
    switch (label.toLowerCase()) {
      case 'kolay':
        return const Color(0xFF4CAF50);
      case 'orta':
        return const Color(0xFFFF9800);
      case 'zor':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF7B61FF); // İngilizce seviyeleri (A1..C2) vb.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, color: Colors.white, size: 12),
          const SizedBox(width: 2),
          Text(
            label,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryAvatar extends StatelessWidget {
  final String? avatarValue;
  final String name;
  final double size;

  const _HistoryAvatar({
    required this.avatarValue,
    required this.name,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    Widget fallback() => Container(
      color: const Color(0xFF7867D9),
      alignment: Alignment.center,
      child: Text(
        name.isEmpty ? '?' : name[0].toUpperCase(),
        style: GoogleFonts.luckiestGuy(
          color: Colors.white,
          fontSize: size * 0.38,
        ),
      ),
    );

    final value = avatarValue?.trim();
    Widget content = fallback();
    if (value != null && value.isNotEmpty) {
      final uri = Uri.tryParse(value);
      if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
        content = Image.network(
          value,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => fallback(),
        );
      } else {
        final assetPath = value.startsWith('assets/')
            ? value
            : 'assets/avatar/characters/$value.png';
        content = Container(
          color: const Color(0xFFE8E5FF),
          padding: EdgeInsets.all(size * 0.07),
          alignment: Alignment.bottomCenter,
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
            errorBuilder: (_, _, _) => fallback(),
          ),
        );
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.72), width: 2),
      ),
      child: ClipOval(child: content),
    );
  }
}

class _HistoryResultPanel extends StatelessWidget {
  final String resultText;
  final bool isWinner;
  final bool isDraw;
  final int myScore;
  final int opponentScore;
  final String opponentName;
  final int? totalQuestions;

  const _HistoryResultPanel({
    required this.resultText,
    required this.isWinner,
    required this.isDraw,
    required this.myScore,
    required this.opponentScore,
    required this.opponentName,
    this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isDraw
        ? const Color(0xFF75B9FF)
        : isWinner
        ? const Color(0xFF58D68D)
        : const Color(0xFFFF7D8A);
    final icon = isDraw
        ? Icons.handshake_rounded
        : isWinner
        ? Icons.emoji_events_rounded
        : Icons.replay_rounded;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.18),
            const Color(0xFF342A78).withValues(alpha: 0.24),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.72)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 19),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  resultText,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Sonuç',
                  style: GoogleFonts.nunito(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _HistoryScore(
                  label: 'Sen',
                  score: myScore,
                  totalQuestions: totalQuestions,
                  isWinner: myScore > opponentScore,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: Container(
                  width: 27,
                  height: 27,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    'VS',
                    style: GoogleFonts.nunito(
                      color: Colors.white70,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _HistoryScore(
                  label: opponentName,
                  score: opponentScore,
                  totalQuestions: totalQuestions,
                  isWinner: opponentScore > myScore,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryScore extends StatelessWidget {
  final String label;
  final int score;
  final int? totalQuestions;
  final bool isWinner;

  const _HistoryScore({
    required this.label,
    required this.score,
    required this.totalQuestions,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isWinner
            ? const Color(0xFF45C77B).withValues(alpha: 0.22)
            : Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: isWinner
              ? const Color(0xFF75E5A2).withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
          Text(
            totalQuestions != null ? '$score/$totalQuestions' : '$score',
            style: GoogleFonts.nunito(
              color: isWinner ? const Color(0xFF9AF2BC) : Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBubble extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatBubble({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.25),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
          ),
          child: Center(child: Icon(icon, color: color, size: 28)),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.nunito(
            color: Colors.white.withValues(alpha: 0.85),
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
