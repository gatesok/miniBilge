import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../models/tournament_models.dart';

/// P7-M05: Yetişkin haftalık eğlence turnuvası API'si.
class TournamentService {
  final Dio _dio;

  TournamentService(this._dio);

  /// GET /api/tournament/categories
  Future<List<TournamentCategory>> getCategories() async {
    final response = await _dio.get('/tournament/categories');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => TournamentCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/tournament/weekly?category=...&topN=...&childProfileId=...
  Future<TournamentWeek> getWeekly({
    required String category,
    int topN = 10,
    String? childProfileId,
  }) async {
    final response = await _dio.get(
      '/tournament/weekly',
      queryParameters: {
        'category': category,
        'topN': topN,
        if (childProfileId != null) 'childProfileId': childProfileId,
      },
    );
    return TournamentWeek.fromJson(response.data as Map<String, dynamic>);
  }
}

final tournamentServiceProvider = Provider<TournamentService>(
  (ref) => TournamentService(ref.watch(dioProvider)),
);
