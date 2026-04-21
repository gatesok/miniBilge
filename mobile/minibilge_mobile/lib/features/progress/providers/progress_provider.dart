import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/child_progress.dart';
import '../models/level_result.dart';
import '../services/progress_service.dart';

// ChildProgress State Provider
final childProgressProvider = FutureProvider.family<ChildProgress, String>((ref, childId) async {
  final progressService = ref.read(progressServiceProvider);
  return await progressService.getProgress(childId);
});

// Level Results Provider
final levelResultsProvider = FutureProvider.family<List<LevelResult>, String>((ref, childId) async {
  final progressService = ref.read(progressServiceProvider);
  return await progressService.getLevelResults(childId);
});

// Level Unlock Check Provider
final levelUnlockProvider = FutureProvider.family<bool, LevelUnlockParams>((ref, params) async {
  final progressService = ref.read(progressServiceProvider);
  return await progressService.checkLevelUnlock(params.childId, params.levelId);
});

// Level Unlock Parameters
class LevelUnlockParams {
  final String childId;
  final String levelId;

  LevelUnlockParams({
    required this.childId,
    required this.levelId,
  });
}
