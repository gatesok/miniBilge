import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import 'leaderboard_api_service.dart';
import 'leaderboard_hub_service.dart';

final leaderboardApiServiceProvider = Provider<LeaderboardApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return LeaderboardApiService(dio);
});

final leaderboardHubServiceProvider = Provider<LeaderboardHubService>((ref) {
  final service = LeaderboardHubService();
  ref.onDispose(service.dispose);
  return service;
});
