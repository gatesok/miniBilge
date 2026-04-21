import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../models/child_progress.dart';
import '../models/level_result.dart';
import '../models/save_progress_request.dart';
import '../models/save_answer_attempt_request.dart';

class ProgressService {
  final Dio _dio;

  ProgressService(this._dio);

  // Çocuğun genel ilerlemesini getir
  Future<ChildProgress> getProgress(String childId) async {
    try {
      final response = await _dio.get('/progress/$childId');
      return ChildProgress.fromJson(response.data);
    } catch (e) {
      throw Exception('İlerleme bilgisi yüklenirken hata oluştu: $e');
    }
  }

  // Çocuğun tüm bölüm sonuçlarını getir
  Future<List<LevelResult>> getLevelResults(String childId) async {
    try {
      final response = await _dio.get('/progress/$childId/level-results');
      final List<dynamic> data = response.data;
      return data.map((json) => LevelResult.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Bölüm sonuçları yüklenirken hata oluştu: $e');
    }
  }

  // Progress kaydet (bölüm tamamlandığında)
  Future<Map<String, dynamic>> saveProgress(SaveProgressRequest request) async {
    try {
      final response = await _dio.post(
        '/progress',
        data: request.toJson(),
      );
      return response.data;
    } catch (e) {
      throw Exception('İlerleme kaydedilirken hata oluştu: $e');
    }
  }

  // Cevap denemesini kaydet
  Future<void> saveAnswerAttempt(SaveAnswerAttemptRequest request) async {
    try {
      await _dio.post(
        '/progress/attempt',
        data: request.toJson(),
      );
    } catch (e) {
      throw Exception('Cevap kaydedilirken hata oluştu: $e');
    }
  }

  // Level unlock kontrolü
  Future<bool> checkLevelUnlock(String childId, String levelId) async {
    try {
      final response = await _dio.get('/progress/$childId/check-unlock/$levelId');
      return response.data['isUnlocked'] as bool;
    } catch (e) {
      throw Exception('Level unlock kontrolü sırasında hata oluştu: $e');
    }
  }
}

// Provider
final progressServiceProvider = Provider<ProgressService>((ref) {
  final dio = ref.read(dioProvider);
  return ProgressService(dio);
});
