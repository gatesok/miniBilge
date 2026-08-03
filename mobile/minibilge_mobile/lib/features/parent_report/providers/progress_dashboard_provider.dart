import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/progress_trend.dart';
import '../models/topic_performance.dart';
import '../models/entertainment_stats.dart';
import 'parent_report_service_provider.dart';

/// (childId, days) parametresi — FutureProvider.family tek argüman aldığı için record.
typedef ReportRangeArg = ({String childId, int days});

/// P6-M04: 30/90 günlük gelişim trendi (premium).
final progressTrendProvider =
    FutureProvider.family<ProgressTrend, ReportRangeArg>((ref, arg) {
  final api = ref.read(parentReportApiServiceProvider);
  return api.getProgressTrend(arg.childId, days: arg.days);
});

/// P6-M04: Konu bazlı performans (premium).
final topicPerformanceProvider =
    FutureProvider.family<List<TopicPerformance>, ReportRangeArg>((ref, arg) {
  final api = ref.read(parentReportApiServiceProvider);
  return api.getTopicPerformance(arg.childId, days: arg.days);
});

/// Eğlence quizi kümülatif istatistikleri (premium).
final entertainmentStatsProvider =
    FutureProvider.family<EntertainmentStats, String>((ref, childId) {
  final api = ref.read(parentReportApiServiceProvider);
  return api.getEntertainmentStats(childId);
});
