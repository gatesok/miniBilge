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
      // Önce sunucudan gelen mesaja bak
      final data = error.response?.data;
      if (data != null && data is Map && data['message'] != null) {
        return data['message'] as String;
      }
      // Ağ/bağlantı hatalarını Türkçe döndür
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Sunucu yanıt vermiyor, lütfen tekrar deneyin';
        case DioExceptionType.connectionError:
          return 'İnternet bağlantısı yok';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) return 'Oturum süreniz doldu, lütfen tekrar giriş yapın';
          if (statusCode == 403) return 'Bu işlem için yetkiniz yok';
          if (statusCode != null && statusCode >= 500) return 'Sunucu hatası, lütfen daha sonra tekrar deneyin';
          return 'Bir hata oluştu';
        default:
          return 'Bir hata oluştu';
      }
    }
    return 'Beklenmeyen bir hata oluştu';
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

  /// Sends password reset code to email. Returns error message or null on success.
  Future<String?> forgotPassword(String email) async {
    try {
      await _authApiService.forgotPassword(email);
      return null;
    } catch (e) {
      return _extractErrorMessage(e);
    }
  }

  /// Resets password using the code sent to email. Returns error message or null on success.
  Future<String?> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _authApiService.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      return null;
    } catch (e) {
      return _extractErrorMessage(e);
    }
  }

  /// Deletes the account permanently. Returns error message or null on success.
  Future<String?> deleteAccount() async {
    try {
      await _authApiService.deleteAccount();
      // Clear all local tokens and state
      await _secureStorage.delete(key: StorageKeys.accessToken);
      await _secureStorage.delete(key: StorageKeys.refreshToken);
      await _secureStorage.delete(key: StorageKeys.userId);
      state = const AuthState.unauthenticated();
      return null;
    } catch (e) {
      return _extractErrorMessage(e);
    }
  }
}

// Auth State Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authApiService = ref.read(authApiServiceProvider);
  final secureStorage = ref.read(secureStorageProvider);
  return AuthNotifier(authApiService, secureStorage);
});
