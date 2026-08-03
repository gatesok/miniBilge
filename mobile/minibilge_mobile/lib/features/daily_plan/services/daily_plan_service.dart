import 'package:dio/dio.dart';
import '../models/daily_plan_models.dart';

class DailyPlanService {
  final Dio _dio;

  DailyPlanService(this._dio);

  /// Bugünün planını getirir; sunucuda yoksa üretilip kaydedilir.
  Future<DailyPlanDto> getToday(String childProfileId) async {
    try {
      final response = await _dio.get('/daily-plan/$childProfileId/today');
      return DailyPlanDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Günlük plan yüklenirken hata oluştu: $e');
    }
  }

  /// Bir plan maddesini tamamlanmış olarak işaretler (idempotent).
  Future<DailyPlanDto> completeItem(
    String childProfileId,
    String itemId,
  ) async {
    try {
      final response = await _dio.post(
        '/daily-plan/$childProfileId/items/$itemId/complete',
      );
      return DailyPlanDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Plan maddesi tamamlanırken hata oluştu: $e');
    }
  }
}
