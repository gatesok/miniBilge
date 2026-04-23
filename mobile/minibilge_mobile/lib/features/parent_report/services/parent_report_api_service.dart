import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../models/daily_summary.dart';
import '../models/weekly_summary.dart';
import '../models/weak_topic.dart';

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
}
