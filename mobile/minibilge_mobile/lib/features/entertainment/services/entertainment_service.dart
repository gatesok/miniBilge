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
  /// DB-first: önceden gösterilen ID'ler ExcludeIds olarak gönderilir.
  Future<List<EntertainmentQuestionModel>> generateQuestions({
    required String childId,
    required String topicKey,
    required String difficulty,
    int count = 10,
    List<int> excludeIds = const [],
  }) async {
    // Metin bazlı geçmiş (GPT fallback için)
    final asked = await EntertainmentHistoryService.getAskedQuiz(topicKey);

    final r = await _dio.post(
      '/entertainment/generate',
      queryParameters: {'childId': childId},
      data: {
        'TopicKey': topicKey,
        'Difficulty': difficulty,
        'Count': count,
        'ExcludeIds': excludeIds,
        'AskedQuestions': asked,
        'DateSeed': _todaySeed(),
      },
    );

    final questions = (r.data as List)
        .map(
          (e) => EntertainmentQuestionModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();

    // Metin bazlı geçmişi güncelle (GPT fallback için)
    await EntertainmentHistoryService.saveAskedQuiz(
      topicKey,
      questions.map((q) => q.questionText).toList(),
    );

    return questions;
  }

  /// Bugünün tarih string'i — GPT'ye context seed olarak gönderilir.
  String _todaySeed() {
    final now = DateTime.now();
    const months = [
      '',
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
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
    required int correctCount,
    required int totalCount,
  }) async {
    final r = await _dio.post(
      '/entertainment/$childId/award',
      data: {
        'CorrectCount': correctCount,
        'TotalCount': totalCount,
        'TopicName': '',
      },
    );
    return AdaptiveQuizRewardModel.fromJson(r.data as Map<String, dynamic>);
  }
}

// ── Gerçek mi Uydurma mı? ────────────────────────────────────────────────────

extension EntertainmentServiceFactFiction on EntertainmentService {
  /// Zorluk seviyesine göre 10 ifade üretir.
  /// Geçmiş ifadeler otomatik yüklenir → GPT'ye forbidden olarak gönderilir.
  Future<List<FactOrFictionQuestionModel>> generateFactFiction({
    required String childId,
    required String difficulty,
  }) async {
    final forbidden = await EntertainmentHistoryService.getAskedFf(difficulty);

    final r = await _dio.post(
      '/entertainment/fact-or-fiction/generate',
      queryParameters: {'childId': childId},
      data: {
        'Difficulty': difficulty,
        'ForbiddenStatements': forbidden,
        'DateSeed': _todaySeed(),
      },
    );

    final items = (r.data as List)
        .map(
          (e) => FactOrFictionQuestionModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();

    // Geçmişe kaydet
    await EntertainmentHistoryService.saveAskedFf(
      difficulty,
      items.map((q) => q.statement).toList(),
    );

    return items;
  }

  /// Oyun tamamlama ödülü — quiz ile aynı endpoint, aynı tier mantığı.
  Future<AdaptiveQuizRewardModel> awardFactFiction({
    required String childId,
    required int correctCount,
    required int totalCount,
  }) async {
    final r = await _dio.post(
      '/entertainment/$childId/award',
      data: {
        'CorrectCount': correctCount,
        'TotalCount': totalCount,
        'TopicName': '',
      },
    );
    return AdaptiveQuizRewardModel.fromJson(r.data as Map<String, dynamic>);
  }
}

// ── Kim Bu? ──────────────────────────────────────────────────────────────────────────

extension EntertainmentServiceKimBu on EntertainmentService {
  /// 5 konuluk bir Kim Bu? turu üretir.
  /// Geçmiş konular otomatik yüklenir → GPT'ye forbidden olarak gönderilir.
  Future<KimBuRoundModel> generateKimBu({
    required String childId,
    required String difficulty,
  }) async {
    final forbidden = await EntertainmentHistoryService.getAskedKimBu(
      difficulty,
    );

    final r = await _dio.post(
      '/entertainment/kim-bu/generate',
      queryParameters: {'childId': childId},
      data: {
        'Difficulty': difficulty,
        'ForbiddenSubjects': forbidden,
        'DateSeed': _todaySeed(),
      },
    );

    final round = KimBuRoundModel.fromJson(r.data as Map<String, dynamic>);

    // Konu adlarını geçmişe kaydet
    await EntertainmentHistoryService.saveAskedKimBu(
      difficulty,
      round.subjects.map((s) => s.subject).toList(),
    );

    return round;
  }

  /// Kim Bu? ödülü — aynı award endpoint.
  Future<AdaptiveQuizRewardModel> awardKimBu({
    required String childId,
    required int correctCount,
    required int totalCount,
  }) async {
    final r = await _dio.post(
      '/entertainment/$childId/award',
      data: {
        'CorrectCount': correctCount,
        'TotalCount': totalCount,
        'TopicName': '',
      },
    );
    return AdaptiveQuizRewardModel.fromJson(r.data as Map<String, dynamic>);
  }
}

// ── Ne Ortak? ─────────────────────────────────────────────────────────────────

extension EntertainmentServiceNeOrtak on EntertainmentService {
  /// 10 adet Ne Ortak? sorusu üretir.
  Future<List<NeOrtakQuestionModel>> generateNeOrtak({
    required String childId,
    required String difficulty,
  }) async {
    final forbidden = await EntertainmentHistoryService.getAskedNeOrtak(
      difficulty,
    );

    final r = await _dio.post(
      '/entertainment/ne-ortak/generate',
      queryParameters: {'childId': childId},
      data: {
        'Difficulty': difficulty,
        'ForbiddenConnections': forbidden,
        'DateSeed': _todaySeed(),
      },
    );

    final questions = (r.data as List)
        .map((e) => NeOrtakQuestionModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Bağlantıları geçmişe kaydet
    await EntertainmentHistoryService.saveAskedNeOrtak(
      difficulty,
      questions.map((q) => q.connection).toList(),
    );

    return questions;
  }

  /// Ne Ortak? ödülü — aynı award endpoint.
  Future<AdaptiveQuizRewardModel> awardNeOrtak({
    required String childId,
    required int correctCount,
    required int totalCount,
  }) async {
    final r = await _dio.post(
      '/entertainment/$childId/award',
      data: {
        'CorrectCount': correctCount,
        'TotalCount': totalCount,
        'TopicName': '',
      },
    );
    return AdaptiveQuizRewardModel.fromJson(r.data as Map<String, dynamic>);
  }
}
