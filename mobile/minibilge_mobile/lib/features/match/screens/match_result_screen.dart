import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import '../providers/match_provider.dart';
import '../services/match_hub_service.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/widgets/card_drop_animation.dart';
import '../../../core/widgets/badge_earned_overlay.dart';
import '../../collection/models/card_dto.dart';
import '../../collection/providers/collection_provider.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../education/providers/subject_provider.dart';
import '../../friends/providers/friend_provider.dart';

class MatchResultScreen extends ConsumerStatefulWidget {
  final String matchId;
  const MatchResultScreen({super.key, required this.matchId});

  @override
  ConsumerState<MatchResultScreen> createState() => _MatchResultScreenState();
}

class _MatchResultScreenState extends ConsumerState<MatchResultScreen> {
  late ConfettiController _confettiController;
  bool _rewardsShown = false;
  bool _resultHandled = false;

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
  );

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(matchProvider.notifier).refreshMatch(widget.matchId);
      // Rewards, ekran açılmadan önce geldiyse ref.listen tetiklenmez —
      // burada mevcut state'i kontrol ederek animasyonu başlat.
      final existing = ref.read(matchProvider).matchRewards;
      if (existing != null) {
        _showRewards(context, existing);
      }
    });
  }

  Future<void> _sendRematchInvite(String opponentId) async {
    final subjects = ref.read(subjectListProvider).valueOrNull ?? [];
    String? selectedSubjectId;

    if (subjects.isNotEmpty && mounted) {
      selectedSubjectId = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1B4B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Hangi derste yarışacaksınız?',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 16),
                ...subjects.map((s) {
                  final colors = _subjectColors(s.name);
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(s.id),
                      borderRadius: BorderRadius.circular(16),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: colors),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _subjectIcon(s.name),
                                color: Colors.white,
                                size: 28,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                s.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
      if (selectedSubjectId == null) return; // iptal
    }

    if (!mounted) return;
    final result = await ref
        .read(friendProvider.notifier)
        .sendMatchInvite(opponentId, subjectId: selectedSubjectId);
    if (!mounted) return;
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Davet gönderildi! Rakibin yanıtı bekleniyor...'),
          backgroundColor: const Color(0xFF7B61FF),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 30),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Davet gönderilemedi.')));
    }
  }

  static List<Color> _subjectColors(String name) {
    switch (name.toLowerCase()) {
      case 'matematik':
        return const [Color(0xFF29B6F6), Color(0xFF0277BD)];
      case 'i\u0307ngilizce':
      case 'ingilizce':
        return const [Color(0xFF26A69A), Color(0xFF00695C)];
      default:
        return const [Color(0xFF7E57C2), Color(0xFF4527A0)];
    }
  }

  static IconData _subjectIcon(String name) {
    switch (name.toLowerCase()) {
      case 'matematik':
        return Icons.calculate_rounded;
      case 'i\u0307ngilizce':
      case 'ingilizce':
        return Icons.language_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  void _showRewards(BuildContext context, MatchRewardsEvent rewards) {
    if (_rewardsShown) return;
    _rewardsShown = true;

    // Kart animasyonu — hemen göster (overlay flip animasyonu)
    if (rewards.cardDropData != null) {
      try {
        final drop = CardDropResult.fromJson(rewards.cardDropData!);
        // Koleksiyon cache'ini temizle
        final childId = ref.read(selectedChildProvider)?.id;
        if (childId != null) {
          ref.invalidate(cardCollectionProvider(childId));
        }
        Future.delayed(const Duration(milliseconds: 800), () {
          if (context.mounted) CardDropAnimation.show(context, drop: drop);
        });
      } catch (_) {}
    }

    // Rozetler — kart animasyonundan sonra sırayla (ortak overlay + katalog)
    if (rewards.earnedBadges.isNotEmpty) {
      final childId = ref.read(selectedChildProvider)?.id;
      if (childId != null) {
        ref.invalidate(badgeCollectionProvider(childId));
      }
      final hasCard = rewards.cardDropData != null;
      BadgeEarnedOverlay.showQueue(
        context,
        rewards.earnedBadges,
        initialDelay: Duration(milliseconds: hasCard ? 3200 : 600),
      );
    }
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
    final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    final scale = isTablet ? 1.2 : 1.0;

    // Ödül geldiğinde animasyon göster
    ref.listen<MatchState>(matchProvider, (prev, next) {
      if (next.matchRewards != null &&
          next.matchRewards != prev?.matchRewards) {
        _showRewards(context, next.matchRewards!);
      }
    });

    if (match == null || myParticipant == null || opponent == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: _gradient),
          child: const SafeArea(
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
        ),
      );
    }

    final winnerId = match.winnerId;
    final isDraw = winnerId == null;
    final isWinner =
        !isDraw &&
        (winnerId == myParticipant.childProfileId ||
            winnerId == myParticipant.id);

    if (!_resultHandled) {
      _resultHandled = true;
      if (isWinner) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _confettiController.play();
            SoundService.playWin();
          }
        });
      } else if (!isDraw) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) SoundService.playLose();
        });
      }
    }

    final resultIcon = isWinner
        ? Icons.emoji_events_rounded
        : isDraw
        ? Icons.handshake_rounded
        : Icons.sentiment_dissatisfied_rounded;
    final resultText = isWinner
        ? 'Kazandın!'
        : isDraw
        ? 'Berabere!'
        : 'Kaybettin';
    final resultSub = isWinner
        ? 'Harika bir performans!'
        : isDraw
        ? 'Her ikiniz de harika oynadınız!'
        : 'Bir dahaki sefere!';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Stack(
            children: [
              // Confetti
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
                      Colors.purple,
                    ],
                  ),
                ),

              // Main content
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isTablet ? 40 : 24,
                  16,
                  isTablet ? 40 : 24,
                  32,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 760 : double.infinity,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Result header
                        SizedBox(height: 24 * scale),
                        Icon(
                          resultIcon,
                          size: 80 * scale,
                          color: isWinner
                              ? Colors.amberAccent
                              : isDraw
                              ? Colors.lightBlueAccent
                              : Colors.redAccent,
                        ),
                        SizedBox(height: 16 * scale),
                        Text(
                          resultText,
                          style: GoogleFonts.luckiestGuy(
                            fontSize: 40 * scale,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                blurRadius: 0,
                                color: Color(0xFF3D35CC),
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8 * scale),
                        Text(
                          resultSub,
                          style: GoogleFonts.nunito(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w700,
                            fontSize: 16 * scale,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 36 * scale),

                        // Score cards row
                        Row(
                          children: [
                            Expanded(
                              child: _ResultPlayerCard(
                                name: myParticipant.childName,
                                score: myParticipant.score,
                                isWinner: isWinner && !isDraw,
                                label: 'Sen',
                                color: const Color(0xFF7B61FF),
                              ),
                            ),
                            SizedBox(width: 14 * scale),
                            Expanded(
                              child: _ResultPlayerCard(
                                name: opponent.childName,
                                score: opponent.score,
                                isWinner: !isWinner && !isDraw,
                                label: 'Rakip',
                                color: const Color(0xFFE67E22),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24 * scale),

                        // Stats card
                        Container(
                          padding: EdgeInsets.all(20 * scale),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(24 * scale),
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
                                  Icon(
                                    Icons.insights_rounded,
                                    color: Colors.white,
                                    size: 22 * scale,
                                  ),
                                  SizedBox(width: 8 * scale),
                                  Text(
                                    'Maç İstatistikleri',
                                    style: GoogleFonts.luckiestGuy(
                                      fontSize: 20 * scale,
                                      color: Colors.white,
                                      shadows: const [
                                        Shadow(
                                          blurRadius: 0,
                                          color: Color(0xFF3D35CC),
                                          offset: Offset(1, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16 * scale),
                              _StatRow(
                                icon: Icons.extension_rounded,
                                label: 'Toplam Soru',
                                value: '${match.questions.length}',
                              ),
                              _StatRow(
                                icon: Icons.task_alt_rounded,
                                label: 'Doğru Sayısı',
                                value: '${myParticipant.score ~/ 10}',
                              ),
                              _StatRow(
                                icon: Icons.star_rounded,
                                label: 'Toplam Puan',
                                value: '${myParticipant.score}',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 28 * scale),

                        // Buttons
                        // Tekrar Oyna
                        GestureDetector(
                          onTap: () async {
                            final opponentId = ref
                                .read(matchProvider)
                                .inviteOpponentId;
                            if (opponentId != null) {
                              // Davet maçı: aynı kişiye tekrar davet gönder
                              await _sendRematchInvite(opponentId);
                            } else {
                              // Normal eşleşme
                              ref.read(matchProvider.notifier).reset();
                              context.pushReplacement('/match/request');
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF3D35CC),
                              borderRadius: BorderRadius.circular(28 * scale),
                            ),
                            child: Container(
                              margin: EdgeInsets.only(bottom: 5 * scale),
                              padding: EdgeInsets.symmetric(
                                vertical: 16 * scale,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF9B59B6),
                                    Color(0xFF7B61FF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(28 * scale),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.refresh_rounded,
                                      color: Colors.white,
                                      size: 22 * scale,
                                    ),
                                    SizedBox(width: 8 * scale),
                                    Text(
                                      'Tekrar Oyna',
                                      style: GoogleFonts.luckiestGuy(
                                        fontSize: 20 * scale,
                                        color: Colors.white,
                                        shadows: const [
                                          Shadow(
                                            blurRadius: 0,
                                            color: Color(0xFF3D35CC),
                                            offset: Offset(1, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 14 * scale),

                        // Ana Sayfaya Dön
                        GestureDetector(
                          onTap: () {
                            ref.read(matchProvider.notifier).reset();
                            context.go('/dashboard');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A6E5A),
                              borderRadius: BorderRadius.circular(28 * scale),
                            ),
                            child: Container(
                              margin: EdgeInsets.only(bottom: 5 * scale),
                              padding: EdgeInsets.symmetric(
                                vertical: 16 * scale,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF27AE60),
                                    Color(0xFF2ECC71),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(28 * scale),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.home_rounded,
                                      color: Colors.white,
                                      size: 22 * scale,
                                    ),
                                    SizedBox(width: 8 * scale),
                                    Text(
                                      'Ana Sayfaya Dön',
                                      style: GoogleFonts.luckiestGuy(
                                        fontSize: 20 * scale,
                                        color: Colors.white,
                                        shadows: const [
                                          Shadow(
                                            blurRadius: 0,
                                            color: Color(0xFF1A6E5A),
                                            offset: Offset(1, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 14 * scale),

                        // Geçmiş Maçlar
                        GestureDetector(
                          onTap: () {
                            final childId = myParticipant.childProfileId;
                            context.push('/match/history?childId=$childId');
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 14 * scale),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(24 * scale),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.45),
                              ),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.history_rounded,
                                    color: Colors.white,
                                    size: 20 * scale,
                                  ),
                                  SizedBox(width: 8 * scale),
                                  Text(
                                    'Geçmiş Maçlar',
                                    style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16 * scale,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultPlayerCard extends StatelessWidget {
  final String name;
  final int score;
  final bool isWinner;
  final String label;
  final Color color;

  const _ResultPlayerCard({
    required this.name,
    required this.score,
    required this.isWinner,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).shortestSide >= 600 ? 1.2 : 1.0;
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: isWinner
            ? Colors.amber.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(
          color: isWinner
              ? Colors.amber.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.4),
          width: isWinner ? 2.5 : 1.5,
        ),
      ),
      child: Column(
        children: [
          if (isWinner)
            Padding(
              padding: EdgeInsets.only(bottom: 6 * scale),
              child: Icon(
                Icons.emoji_events_rounded,
                color: Colors.amberAccent,
                size: 24 * scale,
              ),
            ),
          Container(
            width: 54 * scale,
            height: 54 * scale,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.6)]),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name[0].toUpperCase(),
                style: GoogleFonts.luckiestGuy(
                  fontSize: 22 * scale,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      blurRadius: 0,
                      color: Color(0xFF3D35CC),
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            label,
            style: GoogleFonts.nunito(
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
              fontSize: 11 * scale,
            ),
          ),
          Text(
            name,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14 * scale,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 6 * scale),
          Text(
            '$score',
            style: GoogleFonts.luckiestGuy(
              fontSize: 32 * scale,
              color: Colors.white,
              shadows: const [
                Shadow(
                  blurRadius: 0,
                  color: Color(0xFF3D35CC),
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
          Text(
            'puan',
            style: GoogleFonts.nunito(
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
              fontSize: 12 * scale,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).shortestSide >= 600 ? 1.2 : 1.0;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.white.withValues(alpha: 0.85),
                size: 18 * scale,
              ),
              SizedBox(width: 8 * scale),
              Text(
                label,
                style: GoogleFonts.nunito(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w700,
                  fontSize: 14 * scale,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14 * scale,
            ),
          ),
        ],
      ),
    );
  }
}
