import 'package:dio/dio.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/auth_response.dart';
import '../models/refresh_token_request.dart';
import '../../../core/constants/app_constants.dart';
import '../models/external_login_status.dart';

class AuthApiService {
  final Dio _dio;

  AuthApiService(this._dio);

  /// Login endpoint
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/auth/login',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> loginWithGoogle(String idToken) async {
    final response = await _dio.post(
      '${ApiConstants.baseUrl}/auth/external/google',
      data: {'idToken': idToken},
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> loginWithApple({
    required String identityToken,
    required String authorizationCode,
    required String nonce,
    String? firstName,
    String? lastName,
  }) async {
    final response = await _dio.post(
      '${ApiConstants.baseUrl}/auth/external/apple',
      data: {
        'identityToken': identityToken,
        'authorizationCode': authorizationCode,
        'nonce': nonce,
        'firstName': firstName,
        'lastName': lastName,
      },
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<ExternalLoginStatus> getExternalLoginStatus() async {
    final response = await _dio.get('${ApiConstants.baseUrl}/auth/external');
    return ExternalLoginStatus.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> linkGoogle(String idToken) async {
    await _dio.post(
      '${ApiConstants.baseUrl}/auth/external/google/link',
      data: {'idToken': idToken},
    );
  }

  Future<void> linkApple({
    required String identityToken,
    required String authorizationCode,
    required String nonce,
    String? firstName,
    String? lastName,
  }) async {
    await _dio.post(
      '${ApiConstants.baseUrl}/auth/external/apple/link',
      data: {
        'identityToken': identityToken,
        'authorizationCode': authorizationCode,
        'nonce': nonce,
        'firstName': firstName,
        'lastName': lastName,
      },
    );
  }

  Future<void> unlinkExternalLogin(String provider) async {
    await _dio.delete('${ApiConstants.baseUrl}/auth/external/$provider');
  }

  /// Register endpoint
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/auth/register',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Refresh token endpoint
  Future<AuthResponse> refreshToken(RefreshTokenRequest request) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/auth/refresh',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Logout endpoint
  Future<void> logout() async {
    try {
      await _dio.post('${ApiConstants.baseUrl}/auth/logout');
    } catch (e) {
      rethrow;
    }
  }

  /// Forgot password — sends reset code to email
  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post(
        '${ApiConstants.baseUrl}/auth/forgot-password',
        data: {'Email': email},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Reset password with code
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        '${ApiConstants.baseUrl}/auth/reset-password',
        data: {'Email': email, 'Code': code, 'NewPassword': newPassword},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Delete account — requires valid access token (handled by auth interceptor)
  Future<void> deleteAccount() async {
    try {
      await _dio.delete('${ApiConstants.baseUrl}/auth/account');
    } catch (e) {
      rethrow;
    }
  }
}
