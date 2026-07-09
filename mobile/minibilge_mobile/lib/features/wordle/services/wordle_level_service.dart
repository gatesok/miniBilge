import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../models/wordle_level_models.dart';
import '../models/wordle_models.dart';

class WordleLevelService {
  final Dio _dio;
  WordleLevelService(this._dio);

  Future<WordleLevelStateModel> getCurrentLevel({required String childId}) async {
    final r = await _dio.get('/wordle-levels/$childId/current');
    return WordleLevelStateModel.fromJson(r.data as Map<String, dynamic>);
  }

  Future<WordleLevelStateModel> generateWord({required String childId}) async {
    final r = await _dio.post('/wordle-levels/$childId/generate');
    return WordleLevelStateModel.fromJson(r.data as Map<String, dynamic>);
  }

  Future<WordleLevelSubmitResponse> submitGuess({
    required String childId,
    required String guess,
  }) async {
    final r = await _dio.post(
      '/wordle-levels/$childId/guess',
      data: {'Guess': guess},
    );
    return WordleLevelSubmitResponse.fromJson(r.data as Map<String, dynamic>);
  }

  Future<WordleLevelStateModel> skipLevel({required String childId}) async {
    final r = await _dio.post('/wordle-levels/$childId/skip');
    return WordleLevelStateModel.fromJson(r.data as Map<String, dynamic>);
  }

  Future<WordleLevelStateModel> retryLevel({required String childId}) async {
    final r = await _dio.post('/wordle-levels/$childId/retry');
    return WordleLevelStateModel.fromJson(r.data as Map<String, dynamic>);
  }

  Future<WordleLevelStatsModel> getStats({required String childId}) async {
    final r = await _dio.get('/wordle-levels/$childId/stats');
    return WordleLevelStatsModel.fromJson(r.data as Map<String, dynamic>);
  }

  Future<JokerResponseModel> useJoker({required String childId}) async {
    final r = await _dio.post('/wordle-levels/$childId/joker');
    return JokerResponseModel.fromJson(r.data as Map<String, dynamic>);
  }

  Future<JokerResponseModel> useJokerFromAd({required String childId}) async {
    final r = await _dio.post('/wordle-levels/$childId/joker-ad');
    return JokerResponseModel.fromJson(r.data as Map<String, dynamic>);
  }
}

final wordleLevelServiceProvider = Provider<WordleLevelService>(
  (ref) => WordleLevelService(ref.watch(dioProvider)),
);
