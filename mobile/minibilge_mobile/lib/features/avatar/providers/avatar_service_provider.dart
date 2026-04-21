import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../services/avatar_api_service.dart';

final avatarApiServiceProvider = Provider<AvatarApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return AvatarApiService(dio);
});
