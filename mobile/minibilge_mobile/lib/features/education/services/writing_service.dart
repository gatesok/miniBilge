import 'package:dio/dio.dart';
import '../models/writing_models.dart';

class WritingService {
  final Dio _dio;

  WritingService(this._dio);

  Future<List<WritingPrompt>> getPrompts({
    required String level,
    String? episodeId,
  }) async {
    try {
      final response = await _dio.post('/writing/prompts', data: {
        'Level': level,
        if (episodeId != null) 'EpisodeId': episodeId,
      });
      final List<dynamic> data = response.data;
      return data.map((json) => WritingPrompt.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Promptlar yüklenemedi: $e');
    }
  }

  Future<WritingEvaluationResult> evaluate({
    required String text,
    required String promptText,
    required String level,
    required String inputMethod,
    String? childProfileId,
  }) async {
    try {
      final response = await _dio.post('/writing/evaluate', data: {
        'Text': text,
        'PromptText': promptText,
        'Level': level,
        'InputMethod': inputMethod,
        if (childProfileId != null) 'ChildProfileId': childProfileId,
      });
      return WritingEvaluationResult.fromJson(response.data);
    } catch (e) {
      throw Exception('Değerlendirme yapılamadı: $e');
    }
  }
}
