import 'package:dio/dio.dart';
import '../models/podcast_quiz_models.dart';

class PodcastQuizService {
  final Dio _dio;

  PodcastQuizService(this._dio);

  Future<List<PodcastQuizQuestion>> getQuestions(String episodeId) async {
    try {
      final response = await _dio.get('/podcast/$episodeId/questions');
      final List<dynamic> data = response.data;
      return data.map((json) => PodcastQuizQuestion.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Sorular yüklenirken hata oluştu: $e');
    }
  }

  Future<PodcastQuizResult> submitQuiz({
    required String episodeId,
    required String childProfileId,
    required List<Map<String, String>> answers,
  }) async {
    try {
      final response = await _dio.post(
        '/podcast/$episodeId/quiz/submit',
        data: {
          'ChildProfileId': childProfileId,
          'Answers': answers.map((a) => {
            'QuestionId': a['questionId'],
            'SelectedAnswer': a['selectedAnswer'],
          }).toList(),
        },
      );
      return PodcastQuizResult.fromJson(response.data);
    } catch (e) {
      throw Exception('Quiz gönderilemedi: $e');
    }
  }

  Future<PodcastQuizResult?> getLastResult(String episodeId, String childProfileId) async {
    try {
      final response = await _dio.get(
        '/podcast/$episodeId/quiz/result',
        queryParameters: {'childProfileId': childProfileId},
      );
      return PodcastQuizResult.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw Exception('Sonuç yüklenemedi: $e');
    }
  }
}
