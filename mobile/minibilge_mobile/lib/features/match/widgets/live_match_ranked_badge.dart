import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/live_match_ranked_status_provider.dart';

/// Maç öncesi bu yarışın sıralamaya puan katıp katmayacağını gösterir.
/// Durum okunamazsa hiçbir şey göstermez.
class LiveMatchRankedBadge extends ConsumerWidget {
  const LiveMatchRankedBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(liveMatchRankedStatusProvider).maybeWhen(
          data: (value) => value,
          orElse: () => null,
        );
    if (status == null) return const SizedBox.shrink();

    final ranked = status.nextGameRanked;
    final label = ranked
        ? 'Bu yarış sıralamana puan katacak'
        : 'Günlük sıralama hakkın doldu — bu yarış sıralamaya saymaz';
    final icon = ranked
        ? Icons.emoji_events_rounded
        : Icons.leaderboard_outlined;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 15, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
