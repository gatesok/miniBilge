import 'package:dio/dio.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardApiService {
  final Dio _dio;

  LeaderboardApiService(this._dio);

  /// Global sıralama listesi
  /// GET /api/leaderboard?topN={n}
  Future<List<LeaderboardEntry>> getLeaderboard({
    int topN = 50,
    required bool isAdult,
  }) async {
    try {
      final response = await _dio.get(
        '/leaderboard',
        queryParameters: {
          'topN': topN,
          'audience': isAdult ? 'Adult' : 'Child',
        },
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => LeaderboardEntry.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Belirli bir çocuğun sırası
  /// GET /api/leaderboard/child/{childProfileId}/rank
  Future<LeaderboardEntry?> getChildRank(String childProfileId) async {
    try {
      final response = await _dio.get('/leaderboard/child/$childProfileId/rank');
      return LeaderboardEntry.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}
