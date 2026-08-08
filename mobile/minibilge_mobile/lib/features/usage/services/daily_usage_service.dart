import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../models/daily_usage_status.dart';

const adaptiveQuizUsageKey = 'adaptive_quiz';
const standardQuizUsageKey = 'standard_quiz';
const entertainmentUsageKey = 'entertainment';
const adultChallengeUsageKey = 'adult_challenge';
const liveMatchUsageKey = 'live_match';

class DailyUsageService {
  const DailyUsageService(this._dio);

  final Dio _dio;

  Future<DailyUsageStatus> getStatus({
    required String childId,
    required String featureKey,
  }) async {
    final response = await _dio.get('/usage/$childId/$featureKey');
    return DailyUsageStatus.fromJson(response.data as Map<String, dynamic>);
  }

  Future<DailyUsageStatus> consume({
    required String childId,
    required String featureKey,
  }) async {
    final response = await _dio.post('/usage/$childId/$featureKey/consume');
    return DailyUsageStatus.fromJson(response.data as Map<String, dynamic>);
  }

  Future<DailyUsageStatus> grantRewardedBonus({
    required String childId,
    required String featureKey,
  }) async {
    final response = await _dio.post(
      '/usage/$childId/$featureKey/rewarded-bonus',
    );
    return DailyUsageStatus.fromJson(response.data as Map<String, dynamic>);
  }
}

final dailyUsageServiceProvider = Provider<DailyUsageService>((ref) {
  return DailyUsageService(ref.watch(dioProvider));
});

final dailyUsageStatusProvider = FutureProvider.autoDispose
    .family<DailyUsageStatus, ({String childId, String featureKey})>((
      ref,
      request,
    ) {
      return ref
          .watch(dailyUsageServiceProvider)
          .getStatus(childId: request.childId, featureKey: request.featureKey);
    });
