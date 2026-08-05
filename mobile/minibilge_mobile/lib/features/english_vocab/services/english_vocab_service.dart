import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../../adaptive_quiz/models/adaptive_quiz_models.dart';
import '../models/english_vocab_models.dart';
import 'english_vocab_history_service.dart';

class EnglishVocabService {
  final Dio _dio;
  EnglishVocabService(this._dio);

  /// Seçili CEFR seviyesi için çoktan seçmeli kelime sorusu üretir.
  /// DB-first: önceden gösterilen ID'ler ExcludeIds olarak gönderilir.
  Future<List<VocabQuestionModel>> generateQuestions({
    required String levelCode,
    int count = 10,
    List<int> excludeIds = const [],
  }) async {
    final seenIds = await EnglishVocabHistoryService.getSeenIds(levelCode);
    final mergedExcludeIds = <int>{...excludeIds, ...seenIds}.toList();

    final r = await _dio.post(
      '/english-vocab/generate',
      data: {
        'EnglishLevel': levelCode,
        'Count':        count,
        'ExcludeIds':   mergedExcludeIds,
      },
    );

    final questions = (r.data as List)
        .map((e) => VocabQuestionModel.fromJson(e as Map<String, dynamic>))
        .toList();

    await EnglishVocabHistoryService.saveSeenIds(
      levelCode,
      questions.where((q) => q.id > 0).map((q) => q.id).toList(),
    );

    return questions;
  }

  /// Oyun tamamlama ödülü — quiz'lerle aynı tier/kart/rozet mantığı.
  Future<AdaptiveQuizRewardModel> awardQuiz({
    required String childId,
    required int    correctCount,
    required int    totalCount,
    required String levelCode,
    String? rewardEventId,
    int? durationSeconds,
  }) async {
    final r = await _dio.post(
      '/english-vocab/$childId/award',
      data: {
        'CorrectCount':    correctCount,
        'TotalCount':      totalCount,
        'EnglishLevel':    levelCode,
        'RewardEventId':   ?rewardEventId,
        'DurationSeconds': ?durationSeconds,
      },
    );
    return AdaptiveQuizRewardModel.fromJson(r.data as Map<String, dynamic>);
  }
}

final englishVocabServiceProvider = Provider<EnglishVocabService>(
  (ref) => EnglishVocabService(ref.watch(dioProvider)),
);
