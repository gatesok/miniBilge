import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../models/entertainment_models.dart';
import 'entertainment_history_service.dart';
import '../../adaptive_quiz/models/adaptive_quiz_models.dart';

class EntertainmentService {
  final Dio _dio;
  EntertainmentService(this._dio);

  /// Tüm topic listesini getirir.
  Future<List<EntertainmentTopicModel>> getTopics() async {
    final r = await _dio.get('/entertainment/topics');
    return (r.data as List)
        .map((e) => EntertainmentTopicModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Belirtilen topic + zorlukta soru üretir.
  /// Geçmiş sorular otomatik olarak SharedPreferences'tan alınır.
  Future<List<EntertainmentQuestionModel>> generateQuestions({
    required String topicKey,
    required String difficulty,
    int count = 10,
  }) async {
    // Daha önce sorulan sorular (tekrar önleme)
    final asked = await EntertainmentHistoryService.getAsked(topicKey);

    final r = await _dio.post(
      '/entertainment/generate',
      data: {
        'TopicKey':       topicKey,
        'Difficulty':     difficulty,
        'Count':          count,
        'AskedQuestions': asked,
        'DateSeed':       _todaySeed(),
      },
    );

    final questions = (r.data as List)
        .map((e) =>
            EntertainmentQuestionModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Yeni soruları geçmişe kaydet
    await EntertainmentHistoryService.saveAsked(
      topicKey,
      questions.map((q) => q.questionText).toList(),
    );

    return questions;
  }

  /// Bugünün tarih string'i — GPT'ye context seed olarak gönderilir.
  String _todaySeed() {
    final now = DateTime.now();
    const months = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${now.day} ${months[now.month]} ${now.year}';
  }
}

final entertainmentServiceProvider = Provider<EntertainmentService>(
  (ref) => EntertainmentService(ref.watch(dioProvider)),
);

extension EntertainmentServiceAward on EntertainmentService {
  Future<AdaptiveQuizRewardModel> awardQuiz({
    required String childId,
    required int    correctCount,
    required int    totalCount,
  }) async {
    final r = await _dio.post(
      '/entertainment/$childId/award',
      data: {'CorrectCount': correctCount, 'TotalCount': totalCount, 'TopicName': ''},
    );
    return AdaptiveQuizRewardModel.fromJson(r.data as Map<String, dynamic>);
  }
}
