import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/english_vocab_service.dart';
import '../../adaptive_quiz/models/adaptive_quiz_models.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../../../core/widgets/card_drop_animation.dart';
import '../../../../core/widgets/badge_earned_overlay.dart';
import '../../collection/models/card_dto.dart';
import '../../collection/providers/collection_provider.dart';

/// Kelime Oyunu sonuç ekranı — ödül çağrısı, confetti, kart animasyonu ve
/// Kelime çalışmasının sonuç özetini gösterir.
/// Entertainment sonuç ekranının birebir eşi (kota/menü dönüşü hariç).
class EnglishVocabResultView extends ConsumerStatefulWidget {
  final int correctCount;
  final int totalCount;
  final String levelCode;
  final DateTime? startedAt;

  const EnglishVocabResultView({
    super.key,
    required this.correctCount,
    required this.totalCount,
    required this.levelCode,
    this.startedAt,
  });

  @override
  ConsumerState<EnglishVocabResultView> createState() =>
      _EnglishVocabResultViewState();
}

class _EnglishVocabResultViewState
    extends ConsumerState<EnglishVocabResultView> {
  late final ConfettiController _confetti;
  AdaptiveQuizRewardModel? _reward;
  bool _rewardLoading = false;

  // Ödül isteğinin sunucuda iki kez işlenmesini engellemek için tek sefer üretilir.
  late final String _rewardEventId =
      'envoc_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(1 << 32)}';

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
      final child = ref.read(selectedChildProvider);
      if (child == null) return;

      final service = ref.read(englishVocabServiceProvider);
      final durationSeconds = widget.startedAt == null
          ? null
          : DateTime.now()
                .difference(widget.startedAt!)
                .inSeconds
                .clamp(0, 3600);
      final reward = await service.awardQuiz(
        childId: child.id,
        correctCount: widget.correctCount,
        totalCount: widget.totalCount,
        levelCode: widget.levelCode,
        rewardEventId: _rewardEventId,
        durationSeconds: durationSeconds,
      );

      if (!mounted) return;
      setState(() {
        _reward = reward;
        _rewardLoading = false;
      });

      // Kart animasyonu
      if (reward.cardDropped && reward.cardName != null) {
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) {
          await CardDropAnimation.show(
            context,
            drop: CardDropResult(
              cardId: reward.cardId ?? '',
              cardName: reward.cardName!,
              rarity: reward.cardRarity ?? 'common',
              imageAsset: reward.cardImageAsset ?? '',
              isNew: reward.cardIsNew,
            ),
          );
        }
      }

      // Konfeti (%80+)
      final pct = widget.totalCount > 0
          ? widget.correctCount / widget.totalCount
          : 0.0;
      if (pct >= 0.8 && mounted) _confetti.play();

      // Rozet ilerlemesi dashboard'a anında yansısın.
      ref.invalidate(badgeCollectionProvider(child.id));

      // Kazanılan rozetler — ortak overlay
      if (reward.earnedBadges.isNotEmpty && mounted) {
        await BadgeEarnedOverlay.showQueue(context, reward.earnedBadges);
      }
    } catch (_) {
      if (mounted) setState(() => _rewardLoading = false);
    }
  }

  void _handleExit() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final correct = widget.correctCount;
    final total = widget.totalCount;
    final pct = total > 0 ? correct / total : 0.0;

    final (resultIcon, title) = switch (pct) {
      >= 1.0 => (Icons.emoji_events_rounded, 'Mükemmel!'),
      >= 0.8 => (Icons.auto_awesome_rounded, 'Harika!'),
      >= 0.6 => (Icons.star_rounded, 'İyi!'),
      _ => (Icons.trending_up_rounded, 'Devam Et!'),
    };

    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(resultIcon, size: 72, color: Colors.amberAccent),
                const SizedBox(height: 12),
                Text(
                  '$correct / $total Doğru',
                  style: GoogleFonts.luckiestGuy(
                    color: Colors.white,
                    fontSize: 28,
                    shadows: const [
                      Shadow(
                        blurRadius: 0,
                        color: Color(0xFF3D35CC),
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 20),

                // Ödüller
                if (_rewardLoading)
                  const CircularProgressIndicator(color: Colors.white54)
                else if (_reward != null && _reward!.starsEarned > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amberAccent,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+${_reward!.starsEarned} Yıldız',
                          style: GoogleFonts.luckiestGuy(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        if (_reward!.badgeCount > 0) ...[
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.workspace_premium_rounded,
                            color: Colors.amberAccent,
                            size: 22,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '+${_reward!.badgeCount} Rozet',
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleExit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF5E35B1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Menüye Dön',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Konfeti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 30,
            colors: const [
              Colors.lightBlueAccent,
              Colors.purpleAccent,
              Colors.cyan,
              Colors.yellow,
              Colors.white,
            ],
          ),
        ),
      ],
    );
  }
}
