import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/analytics_service.dart';
import '../../premium/providers/premium_provider.dart';
import '../../usage/services/daily_usage_service.dart';

/// Canlı yarış günlük kotası dolduğunda (backend 429) gösterilen bağlamsal
/// limit ekranı. Ücretsiz kullanıcıya Premium yolu,
/// Premium kullanıcıya "yarın yenilenir" mesajı sunar.
///
Future<void> showLiveMatchLimitSheet(
  BuildContext context,
  WidgetRef ref, {
  required Future<void> Function() onRetry,
}) async {
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
                    : 'Bugünlük canlı yarış hakların bitti. Premium ile günde 30 canlı yarışa geçebilirsin.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 24),
              if (!isPremium) ...[
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
