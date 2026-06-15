import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/topic.dart';
import '../services/education_service.dart';

// Topic List Provider (by subject ID) — grade level'e göre sıralı
final topicListProvider = FutureProvider.family<List<Topic>, String>((ref, subjectId) async {
  final educationService = ref.read(educationServiceProvider);
  final topics = await educationService.getTopics(subjectId);
  return topics..sort((a, b) => a.gradeLevel.compareTo(b.gradeLevel));
});
