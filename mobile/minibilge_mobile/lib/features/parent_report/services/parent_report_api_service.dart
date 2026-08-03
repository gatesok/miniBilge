import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../models/activity_summary.dart';
import '../models/daily_summary.dart';
import '../models/weekly_summary.dart';
import '../models/weak_topic.dart';
import '../models/weekly_goal.dart';
import '../models/progress_trend.dart';
import '../models/topic_performance.dart';
import '../models/entertainment_stats.dart';

class ParentReportApiService {
  final Dio _dio;
  static final _dateFormat = DateFormat('yyyy-MM-dd');

  ParentReportApiService(this._dio);

  /// Günlük özet
  /// GET /api/parent-report/{childId}/daily?date=yyyy-MM-dd
  Future<DailySummary> getDailySummary(String childId, {DateTime? date}) async {
    final queryParams = date != null
        ? {'date': _dateFormat.format(date)}
        : <String, dynamic>{};

    final response = await _dio.get(
      '/parent-report/$childId/daily',
      queryParameters: queryParams,
    );
    return DailySummary.fromJson(response.data as Map<String, dynamic>);
  }

  /// Haftalık özet
  /// GET /api/parent-report/{childId}/weekly?weekStart=yyyy-MM-dd
  Future<WeeklySummary> getWeeklySummary(String childId, {DateTime? weekStart}) async {
    final queryParams = weekStart != null
        ? {'weekStart': _dateFormat.format(weekStart)}
        : <String, dynamic>{};

    final response = await _dio.get(
      '/parent-report/$childId/weekly',
      queryParameters: queryParams,
    );
    return WeeklySummary.fromJson(response.data as Map<String, dynamic>);
  }

  /// Zayıf konular
  /// GET /api/parent-report/{childId}/weak-topics?topN=5
  Future<List<WeakTopic>> getWeakTopics(String childId, {int topN = 5}) async {
    final response = await _dio.get(
      '/parent-report/$childId/weak-topics',
      queryParameters: {'topN': topN},
    );

    if (response.data is List) {
      return (response.data as List)
          .map((json) => WeakTopic.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Genel etkinlik özeti
  /// GET /api/parent-report/{childId}/activity
  Future<ActivitySummary> getActivitySummary(String childId) async {
    final response = await _dio.get('/parent-report/$childId/activity');
    return ActivitySummary.fromJson(response.data as Map<String, dynamic>);
  }

  /// Haftalık hedef (premium)
  /// GET /api/parent-report/{childId}/weekly-goal
  Future<WeeklyGoal> getWeeklyGoal(String childId) async {
    final response = await _dio.get('/parent-report/$childId/weekly-goal');
    return WeeklyGoal.fromJson(response.data as Map<String, dynamic>);
  }

  /// Haftalık hedef belirle/güncelle (premium)
  /// PUT /api/parent-report/{childId}/weekly-goal
  Future<WeeklyGoal> setWeeklyGoal(
    String childId, {
    int? weeklyStudyMinutesGoal,
    String? focusTopicId,
  }) async {
    final response = await _dio.put(
      '/parent-report/$childId/weekly-goal',
      data: {
        'WeeklyStudyMinutesGoal': weeklyStudyMinutesGoal,
        'FocusTopicId': focusTopicId,
      },
    );
    return WeeklyGoal.fromJson(response.data as Map<String, dynamic>);
  }

  /// 30/90 günlük gelişim trendi (premium)
  /// GET /api/parent-report/{childId}/trend?days=30|90
  Future<ProgressTrend> getProgressTrend(String childId, {int days = 30}) async {
    final response = await _dio.get(
      '/parent-report/$childId/trend',
      queryParameters: {'days': days},
    );
    return ProgressTrend.fromJson(response.data as Map<String, dynamic>);
  }

  /// Konu bazlı performans (premium)
  /// GET /api/parent-report/{childId}/topic-performance?days=30|90
  Future<List<TopicPerformance>> getTopicPerformance(
    String childId, {
    int days = 30,
  }) async {
    final response = await _dio.get(
      '/parent-report/$childId/topic-performance',
      queryParameters: {'days': days},
    );
    if (response.data is List) {
      return (response.data as List)
          .map((json) => TopicPerformance.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Eğlence quizi kümülatif istatistikleri (premium)
  /// GET /api/parent-report/{childId}/entertainment-stats
  Future<EntertainmentStats> getEntertainmentStats(String childId) async {
    final response = await _dio.get(
      '/parent-report/$childId/entertainment-stats',
    );
    return EntertainmentStats.fromJson(response.data as Map<String, dynamic>);
  }
}