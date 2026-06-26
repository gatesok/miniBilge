import 'package:dio/dio.dart';
import '../models/pronunciation_models.dart';

class PronunciationService {
  final Dio _dio;

  PronunciationService(this._dio);

  /// Verilen CEFR seviyesi için telaffuz pratiği cümlelerini getirir.
  Future<List<String>> getSentencesForLevel(int level, {int count = 10}) async {
    try {
      final response = await _dio.get(
        '/pronunciation/sentences',
        queryParameters: {'level': level, 'count': count},
      );
      final List<dynamic> data = response.data;
      return data.cast<String>();
    } catch (e) {
      throw Exception('Cümleler yüklenemedi: $e');
    }
  }

  Future<PronunciationResult> evaluate({
    required String targetSentence,
    required String spokenText,
    required String level,
    String? childProfileId,
  }) async {
    try {
      final response = await _dio.post('/pronunciation/evaluate', data: {
        'TargetSentence': targetSentence,
        'SpokenText': spokenText,
        'Level': level,
        if (childProfileId != null) 'ChildProfileId': childProfileId,
      });
      return PronunciationResult.fromJson(response.data);
    } catch (e) {
      throw Exception('Telaffuz değerlendirilemedi: $e');
    }
  }
}
