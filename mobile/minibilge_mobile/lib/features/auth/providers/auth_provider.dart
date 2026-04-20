import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../services/auth_api_service.dart';
import 'auth_state.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/dio_provider.dart';
import 'auth_service_provider.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApiService _authApiService;
  final FlutterSecureStorage _secureStorage;

  AuthNotifier(this._authApiService, this._secureStorage)
      : super(const AuthState.initial()) {
    _checkAuthStatus();
  }

  /// Extract error message from exception
  String _extractErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null && error.response?.data is Map) {
        return error.response?.data['message'] ?? 'Bir hata oluştu';
      }
      return error.message ?? 'Bir hata oluştu';
    }
    return error.toString();
  }

  /// Check if user is already authenticated
  Future<void> _checkAuthStatus() async {
    final accessToken = await _secureStorage.read(key: StorageKeys.accessToken);
    final userId = await _secureStorage.read(key: StorageKeys.userId);

    if (accessToken != null && userId != null) {
      // TODO: Fetch user data from API or load from storage
      // For now, just set to unauthenticated
      state = const AuthState.unauthenticated();
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    state = const AuthState.loading();

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _authApiService.login(request);

      // Save tokens
      await _secureStorage.write(
        key: StorageKeys.accessToken,
        value: response.accessToken,
      );
      await _secureStorage.write(
        key: StorageKeys.refreshToken,
        value: response.refreshToken,
      );
      await _secureStorage.write(
        key: StorageKeys.userId,
        value: response.user.id,
      );

      state = AuthState.authenticated(response.user);
    } catch (e) {
      state = AuthState.error(_extractErrorMessage(e));
    }
  }

  /// Register new user
  Future<void> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    state = const AuthState.loading();

    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      final response = await _authApiService.register(request);

      // Save tokens
      await _secureStorage.write(
        key: StorageKeys.accessToken,
        value: response.accessToken,
      );
      await _secureStorage.write(
        key: StorageKeys.refreshToken,
        value: response.refreshToken,
      );
      await _secureStorage.write(
        key: StorageKeys.userId,
        value: response.user.id,
      );

      state = AuthState.authenticated(response.user);
    } catch (e) {
      state = AuthState.error(_extractErrorMessage(e));
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _authApiService.logout();
    } catch (e) {
      // Ignore logout errors
    } finally {
      // Clear tokens
      await _secureStorage.delete(key: StorageKeys.accessToken);
      await _secureStorage.delete(key: StorageKeys.refreshToken);
      await _secureStorage.delete(key: StorageKeys.userId);

      state = const AuthState.unauthenticated();
    }
  }

  /// Clear error state
  void clearError() {
    state.whenOrNull(
      error: (_) => state = const AuthState.unauthenticated(),
    );
  }
}

// Auth State Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authApiService = ref.read(authApiServiceProvider);
  final secureStorage = ref.read(secureStorageProvider);
  return AuthNotifier(authApiService, secureStorage);
});
