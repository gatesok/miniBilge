import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import '../models/level.dart';
import '../models/question.dart';
import '../models/submit_answer_response.dart';

class EducationService {
  final Dio _dio;

  EducationService(this._dio);

  // Tüm dersleri getir (Matematik, İngilizce)
  Future<List<Subject>> getSubjects() async {
    try {
      final response = await _dio.get('/education/subjects');
      final List<dynamic> data = response.data;
      return data.map((json) => Subject.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Dersler yüklenirken hata oluştu: $e');
    }
  }

  // Belirli bir derse ait konuları getir
  Future<List<Topic>> getTopics(String subjectId) async {
    try {
      final response = await _dio.get('/education/subjects/$subjectId/topics');
      final List<dynamic> data = response.data;
      return data.map((json) => Topic.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Konular yüklenirken hata oluştu: $e');
    }
  }

  // Belirli bir konuya ait seviyeleri getir
  Future<List<Level>> getLevels(String topicId) async {
    try {
      final response = await _dio.get('/education/topics/$topicId/levels');
      final List<dynamic> data = response.data;
      return data.map((json) => Level.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Seviyeler yüklenirken hata oluştu: $e');
    }
  }

  // Belirli bir seviyeden sorular getir
  Future<List<Question>> getQuestions(String levelId, {int count = 10}) async {
    try {
      final response = await _dio.get(
        '/education/levels/$levelId/questions',
        queryParameters: {'count': count},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Question.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Sorular yüklenirken hata oluştu: $e');
    }
  }

  // Cevap gönder ve kontrol et
  Future<SubmitAnswerResponse> submitAnswer({
    required String questionId,
    required String userAnswer,
  }) async {
    try {
      final response = await _dio.post(
        '/education/questions/submit-answer',
        data: {
          'questionId': questionId,
          'userAnswer': userAnswer,
        },
      );
      return SubmitAnswerResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Cevap gönderilirken hata oluştu: $e');
    }
  }
}

// Provider
final educationServiceProvider = Provider<EducationService>((ref) {
  final dio = ref.read(dioProvider);
  return EducationService(dio);
});
