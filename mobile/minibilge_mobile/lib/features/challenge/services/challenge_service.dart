import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../models/challenge_models.dart';

class ChallengeService {
  final Dio _dio;
  ChallengeService(this._dio);

  Future<ChallengeDto> sendChallenge({
    required String challengerId,
    required String challengeeId,
    required String levelId,
  }) async {
    final r = await _dio.post('/challenges', data: {
      'ChallengerId': challengerId,
      'ChallengeeId': challengeeId,
      'LevelId': levelId,
    });
    return ChallengeDto.fromJson(r.data as Map<String, dynamic>);
  }

  Future<ChallengeDto> acceptChallenge(String challengeId, String challengeeId) async {
    final r = await _dio.post('/challenges/$challengeId/accept',
        data: {'ChallengeeId': challengeeId});
    return ChallengeDto.fromJson(r.data as Map<String, dynamic>);
  }

  Future<ChallengeDto> declineChallenge(String challengeId, String challengeeId) async {
    final r = await _dio.post('/challenges/$challengeId/decline',
        data: {'ChallengeeId': challengeeId});
    return ChallengeDto.fromJson(r.data as Map<String, dynamic>);
  }

  Future<ChallengeDto> submitScore(
      String challengeId, String childId, int score) async {
    final r = await _dio.post('/challenges/$challengeId/submit-score',
        data: {'ChildId': childId, 'Score': score});
    return ChallengeDto.fromJson(r.data as Map<String, dynamic>);
  }

  Future<List<ChallengeDto>> getIncoming(String childId) async {
    final r = await _dio.get('/challenges/incoming',
        queryParameters: {'childId': childId});
    return (r.data as List)
        .map((e) => ChallengeDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ChallengeDto>> getOutgoing(String childId) async {
    final r = await _dio.get('/challenges/outgoing',
        queryParameters: {'childId': childId});
    return (r.data as List)
        .map((e) => ChallengeDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ChallengeDto>> getHistory(String childId) async {
    final r = await _dio.get('/challenges/history',
        queryParameters: {'childId': childId});
    return (r.data as List)
        .map((e) => ChallengeDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final challengeServiceProvider = Provider<ChallengeService>(
  (ref) => ChallengeService(ref.watch(dioProvider)),
);
