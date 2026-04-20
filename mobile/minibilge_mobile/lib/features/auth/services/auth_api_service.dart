import 'package:dio/dio.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/auth_response.dart';
import '../models/refresh_token_request.dart';
import '../../../core/constants/app_constants.dart';

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
}
