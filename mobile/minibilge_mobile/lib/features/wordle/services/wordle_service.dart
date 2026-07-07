import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../models/wordle_models.dart';

class WordleService {
  final Dio _dio;
  WordleService(this._dio);

  /// Bugünün oyun durumunu getirir.
  Future<WordleTodayModel> getToday({
    required String childId,
    String language = 'tr',
  }) async {
    final r = await _dio.get(
      '/wordle/$childId/today',
      queryParameters: {'language': language},
    );
    return WordleTodayModel.fromJson(r.data as Map<String, dynamic>);
  }

  /// Tahmin gönderir ve sonucu döner.
  Future<SubmitGuessResponse> submitGuess({
    required String childId,
    required String guess,
    String language = 'tr',
  }) async {
    final r = await _dio.post(
      '/wordle/$childId/guess',
      queryParameters: {'language': language},
      data: {'Guess': guess},
    );
    return SubmitGuessResponse.fromJson(r.data as Map<String, dynamic>);
  }

  /// Kullanıcı istatistiklerini getirir.
  Future<WordleStatsModel> getStats({
    required String childId,
    String language = 'tr',
  }) async {
    final r = await _dio.get(
      '/wordle/$childId/stats',
      queryParameters: {'language': language},
    );
    return WordleStatsModel.fromJson(r.data as Map<String, dynamic>);
  }
}

final wordleServiceProvider = Provider<WordleService>(
  (ref) => WordleService(ref.watch(dioProvider)),
);
