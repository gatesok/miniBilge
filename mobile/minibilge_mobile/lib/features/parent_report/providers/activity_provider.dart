import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_summary.dart';
import 'parent_report_service_provider.dart';

/// Çocuğun genel etkinlik istatistiklerini yükleyen provider.
/// FutureProvider.family → childId değişince otomatik yeniden yüklenir.
final activitySummaryProvider =
    FutureProvider.family<ActivitySummary, String>((ref, childId) {
  final api = ref.read(parentReportApiServiceProvider);
  return api.getActivitySummary(childId);
});
