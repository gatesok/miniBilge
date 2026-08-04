import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/ad_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../premium/providers/premium_provider.dart';
import '../../usage/services/daily_usage_service.dart';
import '../providers/live_match_usage_provider.dart';

/// Canlı yarış günlük kotası dolduğunda (backend 429) gösterilen bağlamsal
/// limit ekranı. Ücretsiz kullanıcıya ödüllü reklamla +1 hak ve Premium yolu,
/// Premium kullanıcıya "yarın yenilenir" mesajı sunar.
///
/// [onRetry] ödüllü reklam ile ek hak kazanıldıktan sonra çağrılır (yeniden
/// rakip arama).
Future<void> showLiveMatchLimitSheet(
  BuildContext context,
  WidgetRef ref, {
  required Future<void> Function() onRetry,
}) async {
  final childId = ref.read(selectedChildProvider)?.id;
  unawaited(
    AnalyticsService.logEvent(
      AnalyticsEvents.attemptLimitReached,
      parameters: {'feature': liveMatchUsageKey},
    ),
  );
  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFFF4F0FF),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => Consumer(
      builder: (ctx, sheetRef, _) {
        final isPremium = sheetRef.watch(premiumProvider).isPremium;
        final canBonus = sheetRef.watch(liveMatchUsageStatusProvider).maybeWhen(
              data: (status) => status?.canEarnRewardedBonus ?? false,
              orElse: () => false,
            );
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⏳', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 12),
              Text(
                'Günlük canlı yarış hakkın doldu',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2D2060),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isPremium
                    ? 'Bugünkü canlı yarış hakkını kullandın. Hakların yarın yenilenir.'
                    : canBonus
                        ? 'Her gün 5 canlı yarış başlatabilirsin. Reklam izleyerek +1 hak kazanabilir ya da Premium ile günde 30 canlı yarışa geçebilirsin.'
                        : 'Bugünlük canlı yarış hakların bitti. Premium ile günde 30 canlı yarışa geçebilirsin.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 24),
              if (!isPremium) ...[
                if (canBonus) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A5ACD),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        RewardedAdService.showRewardedAd(
                          placement: AdPlacements.liveMatchExtraAttempt,
                          onRewarded: () async {
                            if (childId != null) {
                              try {
                                await sheetRef
                                    .read(dailyUsageServiceProvider)
                                    .grantRewardedBonus(
                                      childId: childId,
                                      featureKey: liveMatchUsageKey,
                                    );
                                unawaited(
                                  AnalyticsService.logEvent(
                                    AnalyticsEvents.rewardedBonusGranted,
                                    parameters: {
                                      'feature_key': liveMatchUsageKey,
                                    },
                                  ),
                                );
                              } catch (_) {
                                // Bonus verilemezse sessizce yut.
                              }
                            }
                            sheetRef.invalidate(liveMatchUsageStatusProvider);
                            if (sheetContext.mounted) {
                              Navigator.of(sheetContext).pop();
                            }
                            await onRetry();
                          },
                        );
                      },
                      child: Text(
                        '📺 Reklam İzle (+1 Hak)',
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      unawaited(
                        AnalyticsService.logEvent(
                          AnalyticsEvents.premiumIntent,
                          parameters: {
                            'trigger': 'live_match_limit',
                            'feature_key': liveMatchUsageKey,
                          },
                        ),
                      );
                      Navigator.of(sheetContext).pop();
                      context.push('/premium');
                    },
                    child: Text(
                      '✨ Premium\'a Geç',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ] else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A5ACD),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: Text(
                      'Tamam',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    ),
  );
}
