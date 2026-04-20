import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/topic.dart';
import '../services/education_service.dart';

// Topic List Provider (by subject ID)
final topicListProvider = FutureProvider.family<List<Topic>, String>((ref, subjectId) async {
  final educationService = ref.read(educationServiceProvider);
  return await educationService.getTopics(subjectId);
});
