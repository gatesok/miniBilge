import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weak_topic.dart';
import '../models/weekly_goal.dart';
import 'parent_report_service_provider.dart';

/// P6-M02: Çocuğun haftalık hedefini yükleyen provider (premium).
/// FutureProvider.family → childId değişince otomatik yeniden yüklenir.
final weeklyGoalProvider =
    FutureProvider.family<WeeklyGoal, String>((ref, childId) {
  final api = ref.read(parentReportApiServiceProvider);
  return api.getWeeklyGoal(childId);
});

/// P6-M02: Odak konu seçimi için çocuğun zayıf konu listesi.
final focusTopicOptionsProvider =
    FutureProvider.family<List<WeakTopic>, String>((ref, childId) {
  final api = ref.read(parentReportApiServiceProvider);
  return api.getWeakTopics(childId, topN: 10);
});

