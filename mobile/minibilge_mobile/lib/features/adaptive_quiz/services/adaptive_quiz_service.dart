import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../models/adaptive_quiz_models.dart';

class AdaptiveQuizService {
  final Dio _dio;
  AdaptiveQuizService(this._dio);

  /// Çocuğun zayıf konularını getirir.
  Future<List<WeakTopicModel>> getWeakTopics(String childId) async {
    final r = await _dio.get('/adaptive-quiz/$childId/weak-topics');
    return (r.data as List)
        .map((e) => WeakTopicModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Belirtilen konu için AI sorular üretir.
  Future<List<AdaptiveQuestionModel>> generateQuestions({
    required String childId,
    required String topicName,
    required String subjectName,
    required int    gradeLevel,
    int difficulty = 2,
    int count      = 5,
  }) async {
    final r = await _dio.post(
      '/adaptive-quiz/$childId/generate',
      data: {
        'TopicName':   topicName,
        'SubjectName': subjectName,
        'GradeLevel':  gradeLevel,
        'Difficulty':  difficulty,
        'Count':       count,
      },
    );
    return (r.data as List)
        .map((e) => AdaptiveQuestionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Çocuğun cevabını kaydeder.
  Future<void> submitAnswer({
    required String childId,
    required String questionId,
    required String givenAnswer, // "A"|"B"|"C"|"D"
  }) async {
    await _dio.post(
      '/adaptive-quiz/$childId/submit',
      data: {'QuestionId': questionId, 'GivenAnswer': givenAnswer},
    );
  }
}

final adaptiveQuizServiceProvider = Provider<AdaptiveQuizService>(
  (ref) => AdaptiveQuizService(ref.watch(dioProvider)),
);
