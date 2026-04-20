import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_api_service.dart';
import '../../../core/network/dio_provider.dart';

// Auth API Service Provider
final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final dio = ref.read(dioProvider);
  return AuthApiService(dio);
});
