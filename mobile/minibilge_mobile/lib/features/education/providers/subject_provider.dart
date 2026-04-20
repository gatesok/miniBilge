import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subject.dart';
import '../services/education_service.dart';

// Subject List Provider
final subjectListProvider = FutureProvider<List<Subject>>((ref) async {
  final educationService = ref.read(educationServiceProvider);
  return await educationService.getSubjects();
});
