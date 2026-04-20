import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../services/child_profile_api_service.dart';

final childProfileApiServiceProvider = Provider<ChildProfileApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ChildProfileApiService(dio);
});
