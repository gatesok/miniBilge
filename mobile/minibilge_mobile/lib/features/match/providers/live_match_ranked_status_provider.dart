import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../child_profile/providers/selected_child_provider.dart';
import '../models/live_match_ranked_status.dart';
import '../services/match_service.dart';

/// Seçili çocuğun maç öncesi sıralama-uygunluk durumu (rastgele kuyruk; rakip yok).
/// Sunucuya ulaşılamazsa null döner (UI rozeti gizler, akışı engellemez).
final liveMatchRankedStatusProvider =
    FutureProvider.autoDispose<LiveMatchRankedStatus?>((ref) async {
  final childId = ref.watch(selectedChildProvider)?.id;
  if (childId == null) return null;
  try {
    return await ref.read(matchServiceProvider).getRankingStatus(childId);
  } on DioException {
    return null;
  }
});
