import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/level.dart';
import '../services/education_service.dart';

// Level List Provider (by topic ID)
final levelListProvider = FutureProvider.family<List<Level>, String>((ref, topicId) async {
  final educationService = ref.read(educationServiceProvider);
  return await educationService.getLevels(topicId);
});
