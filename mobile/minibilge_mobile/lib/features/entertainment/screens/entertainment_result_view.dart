import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/entertainment_models.dart';
import '../providers/entertainment_provider.dart';
import '../services/entertainment_service.dart';
import '../../adaptive_quiz/models/adaptive_quiz_models.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/widgets/card_drop_animation.dart';
import '../../collection/models/card_dto.dart';

/// Tüm eğlence modları için ortak sonuç ekranı.
/// correctCount / totalCount dışında hiçbir bağımlılık yok —
/// ödül çağrısı, confetti ve kart animasyonu bu widget içinde yönetilir.
class EntertainmentResultView extends ConsumerStatefulWidget {
  final int correctCount;
  final int totalCount;

  const EntertainmentResultView({
    super.key,
    required this.correctCount,
    required this.totalCount,
  });

  @override
  ConsumerState<EntertainmentResultView> createState() =>
      _EntertainmentResultViewState();
}

class _EntertainmentResultViewState
    extends ConsumerState<EntertainmentResultView> {
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
      final child = ref.read(selectedChildProvider);
      if (child == null) return;

      final service = ref.read(entertainmentServiceProvider);
      final reward  = await service.awardQuiz(
        childId:      child.id,
        correctCount: widget.correctCount,
        totalCount:   widget.totalCount,
      );

      if (!mounted) return;
      setState(() {
        _reward        = reward;
        _rewardLoading = false;
      });

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
      final pct = widget.totalCount > 0
          ? widget.correctCount / widget.totalCount
          : 0.0;
      if (pct >= 0.8 && mounted) _confetti.play();
    } catch (_) {
      if (mounted) setState(() => _rewardLoading = false);
    }
  }

  void _handleExit() {
    ref.invalidate(entertainmentRemainingProvider);
    AdService.showInterstitialAd(onComplete: () {
      if (context.mounted) context.go('/entertainment');
    });
  }

  @override
  Widget build(BuildContext context) {
    final correct = widget.correctCount;
    final total   = widget.totalCount;
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
                              offset: Offset(2, 2)),
                        ])),
                const SizedBox(height: 6),
                Text(title,
                    style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),

                const SizedBox(height: 20),

                // Ödüller
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
                    onPressed: _handleExit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF11998E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Eğlence Menüsüne Dön',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800,
                            fontSize: 15)),
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
              Colors.green, Colors.teal, Colors.cyan,
              Colors.yellow, Colors.white,
            ],
          ),
        ),
      ],
    );
  }
}
