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

class MatchResultScreen extends ConsumerStatefulWidget {
  final String matchId;
  const MatchResultScreen({super.key, required this.matchId});

  @override
  ConsumerState<MatchResultScreen> createState() => _MatchResultScreenState();
}

class _MatchResultScreenState extends ConsumerState<MatchResultScreen> {
  late ConfettiController _confettiController;
  bool _rewardsShown = false;

  // Local map: badge key → {emoji, name, description, rarity}
  static const _badgeInfo = <String, Map<String, String>>{
    'first_win': {
      'emoji': '🥇',
      'name': 'İlk Zafer!',
      'description': 'İlk maçını kazandın!',
      'rarity': 'Nadir',
    },
    'win_streak_5': {
      'emoji': '🔥',
      'name': 'Durdurulamaz!',
      'description': '5 maçı üst üste kazandın!',
      'rarity': 'Efsane',
    },
    'champion_50': {
      'emoji': '👑',
      'name': 'Şampiyon',
      'description': '50 maç galibiyeti!',
      'rarity': 'Efsane',
    },
  };

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
  );

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
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
          if (mounted) CardDropAnimation.show(context, drop: drop);
        });
      } catch (_) {}
    }

    // Rozetler — kart animasyonundan sonra sırayla
    final hasCard = rewards.cardDropData != null;
    final baseDelay = hasCard ? 3200 : 600;
    for (var i = 0; i < rewards.earnedBadges.length; i++) {
      final key = rewards.earnedBadges[i];
      final info = _badgeInfo[key];
      if (info == null) continue;
      final delay = Duration(milliseconds: baseDelay + i * 1200);
      Future.delayed(delay, () {
        if (mounted) {
          BadgeEarnedOverlay.show(
            context,
            emoji: info['emoji']!,
            name: info['name']!,
            description: info['description']!,
            rarity: info['rarity']!,
          );
        }
      });
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
                  child: CircularProgressIndicator(color: Colors.white))),
        ),
      );
    }

    final winnerId = match.winnerId;
    final isDraw = winnerId == null;
    final isWinner = !isDraw &&
        (winnerId == myParticipant.childProfileId ||
            winnerId == myParticipant.id);

    if (isWinner) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _confettiController.play();
        SoundService.playWin();
      });
    } else if (!isDraw) {
      Future.delayed(const Duration(milliseconds: 300), () {
        SoundService.playLose();
      });
    }

    final resultEmoji = isWinner ? '🏆' : isDraw ? '🤝' : '😢';
    final resultText =
        isWinner ? 'Kazandın!' : isDraw ? 'Berabere!' : 'Kaybettin';
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
                      Colors.purple
                    ],
                  ),
                ),

              // Main content
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Result header
                    const SizedBox(height: 24),
                    Text(resultEmoji,
                        style: const TextStyle(fontSize: 80),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    Text(resultText,
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 40,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                                blurRadius: 0,
                                color: Color(0xFF3D35CC),
                                offset: Offset(2, 2))
                          ],
                        ),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(resultSub,
                        style: GoogleFonts.nunito(
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 36),

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
                        const SizedBox(width: 14),
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
                    const SizedBox(height: 24),

                    // Stats card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.45),
                            width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Text('📊 Maç İstatistikleri',
                              style: GoogleFonts.luckiestGuy(
                                  fontSize: 20,
                                  color: Colors.white,
                                  shadows: const [
                                    Shadow(
                                        blurRadius: 0,
                                        color: Color(0xFF3D35CC),
                                        offset: Offset(1, 1))
                                  ])),
                          const SizedBox(height: 16),
                          _StatRow(
                              label: '🧩 Toplam Soru',
                              value: '${match.questions.length}'),
                          _StatRow(
                              label: '✅ Doğru Sayısı',
                              value:
                                  '${myParticipant.score ~/ 10}'),
                          _StatRow(
                              label: '⭐ Toplam Puan',
                              value: '${myParticipant.score}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Buttons
                    // Tekrar Oyna
                    GestureDetector(
                      onTap: () {
                        ref.read(matchProvider.notifier).reset();
                        context.pushReplacement('/match/request');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF3D35CC),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [
                              Color(0xFF9B59B6),
                              Color(0xFF7B61FF)
                            ]),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Center(
                            child: Text('🔄 Tekrar Oyna',
                                style: GoogleFonts.luckiestGuy(
                                    fontSize: 20,
                                    color: Colors.white,
                                    shadows: const [
                                      Shadow(
                                          blurRadius: 0,
                                          color: Color(0xFF3D35CC),
                                          offset: Offset(1, 1))
                                    ])),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Ana Sayfaya Dön
                    GestureDetector(
                      onTap: () {
                        ref.read(matchProvider.notifier).reset();
                        context.go('/dashboard');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A6E5A),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [
                              Color(0xFF27AE60),
                              Color(0xFF2ECC71)
                            ]),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Center(
                            child: Text('🏠 Ana Sayfaya Dön',
                                style: GoogleFonts.luckiestGuy(
                                    fontSize: 20,
                                    color: Colors.white,
                                    shadows: const [
                                      Shadow(
                                          blurRadius: 0,
                                          color: Color(0xFF1A6E5A),
                                          offset: Offset(1, 1))
                                    ])),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Geçmiş Maçlar
                    GestureDetector(
                      onTap: () {
                        final childId = myParticipant.childProfileId;
                        context.push('/match/history?childId=$childId');
                      },
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.45)),
                        ),
                        child: Center(
                          child: Text('📋 Geçmiş Maçlar',
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWinner
            ? Colors.amber.withOpacity(0.2)
            : Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isWinner
              ? Colors.amber.withOpacity(0.8)
              : Colors.white.withOpacity(0.4),
          width: isWinner ? 2.5 : 1.5,
        ),
      ),
      child: Column(
        children: [
          if (isWinner)
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text('🏆', style: TextStyle(fontSize: 24)),
            ),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.6)]),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name[0].toUpperCase(),
                style: GoogleFonts.luckiestGuy(
                    fontSize: 22,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                          blurRadius: 0,
                          color: Color(0xFF3D35CC),
                          offset: Offset(1, 1))
                    ]),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: GoogleFonts.nunito(
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  fontSize: 11)),
          Text(name,
              style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text('$score',
              style: GoogleFonts.luckiestGuy(
                  fontSize: 32,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                        blurRadius: 0,
                        color: Color(0xFF3D35CC),
                        offset: Offset(1, 1))
                  ])),
          Text('puan',
              style: GoogleFonts.nunito(
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.nunito(
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
          Text(value,
              style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14)),
        ],
      ),
    );
  }
}
