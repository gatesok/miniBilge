import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../child_profile/providers/selected_child_provider.dart';
import '../../usage/models/daily_usage_status.dart';
import '../../usage/services/daily_usage_service.dart';

/// Seçili çocuk için canlı yarış (`live_match`) günlük kota durumu.
/// Kalan hak ve üyelik bilgisi kota mesajı/paywall için kullanılır.
/// Sunucuya ulaşılamazsa null döner (UI kotayı gizler, akışı engellemez).
final liveMatchUsageStatusProvider =
    FutureProvider.autoDispose<DailyUsageStatus?>((ref) async {
      final childId = ref.watch(selectedChildProvider)?.id;
      if (childId == null) return null;
      try {
        return await ref
            .read(dailyUsageServiceProvider)
            .getStatus(childId: childId, featureKey: liveMatchUsageKey);
      } on DioException {
        return null;
      }
    });

/// Kalan canlı yarış hakkı; durum okunamazsa null.
final liveMatchRemainingProvider = Provider.autoDispose<int?>((ref) {
  return ref
      .watch(liveMatchUsageStatusProvider)
      .maybeWhen(data: (status) => status?.remaining, orElse: () => null);
});
