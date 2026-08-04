import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../usage/models/daily_usage_status.dart';
import '../providers/live_match_usage_provider.dart';

/// Konu/seviye seçim ekranında seçili çocuğun kalan canlı yarış hakkını gösterir.
/// Kota okunamazsa (sunucuya ulaşılamıyorsa) hiçbir şey göstermez.
class LiveMatchQuotaBanner extends ConsumerWidget {
  const LiveMatchQuotaBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(liveMatchUsageStatusProvider).maybeWhen(
          data: (value) => value,
          orElse: () => null,
        );
    if (status == null) return const SizedBox.shrink();

    final depleted = status.remaining <= 0;
    final lastOne = status.remaining == 1;
    final Color tint = depleted
        ? const Color(0xFFFFE0B2)
        : Colors.white.withValues(alpha: 0.22);
    final Color textColor = depleted ? const Color(0xFF8A5300) : Colors.white;
    final IconData icon = depleted
        ? Icons.hourglass_bottom_rounded
        : (lastOne ? Icons.bolt_rounded : Icons.sports_esports_rounded);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _message(status),
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _message(DailyUsageStatus status) {
    if (status.remaining <= 0) {
      return status.canEarnRewardedBonus
          ? 'Canlı yarış hakkın doldu. Reklam izleyerek +1 hak kazanabilirsin.'
          : 'Bugünkü canlı yarış hakkın doldu. Yarın yenilenecek.';
    }
    if (status.remaining == 1) {
      return 'Bugün son canlı yarış hakkın kaldı.';
    }
    return 'Bugün ${status.remaining} canlı yarış hakkın var.';
  }
}
