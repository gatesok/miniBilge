import 'package:dio/dio.dart';
import '../models/vocab_challenge_models.dart';

class VocabChallengeService {
  final Dio _dio;

  VocabChallengeService(this._dio);

  /// Çocuğun öğrendiği kelimelerden kişiselleştirilmiş görev üretir.
  Future<VocabChallengeTask> generateChallenge({
    required String childId,
    required String level,
  }) async {
    try {
      final response = await _dio.post('/vocabchallenge/generate', data: {
        'ChildId': childId,
        'Level': level,
      });
      return VocabChallengeTask.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Görev üretilemedi: $e');
    }
  }

  /// Yazılan metni hedef kelime kullanımı dahil değerlendirir.
  Future<VocabChallengeResult> evaluate({
    required String text,
    required String taskText,
    required List<String> targetWords,
    required String level,
    required String inputMethod,
    String? childProfileId,
  }) async {
    try {
      final response = await _dio.post('/vocabchallenge/evaluate', data: {
        'Text': text,
        'TaskText': taskText,
        'TargetWords': targetWords,
        'Level': level,
        'InputMethod': inputMethod,
        if (childProfileId != null) 'ChildProfileId': childProfileId,
      });
      return VocabChallengeResult.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Değerlendirme yapılamadı: $e');
    }
  }
}
