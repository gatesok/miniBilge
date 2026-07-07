import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_constants.dart';

/// Uygulama başlatılırken auth provider tarafından çağrılır.
/// Token yenileme başarısız olduğunda interceptor bu callback'i çağırır.
Future<void> Function()? _onSessionExpired;

void registerSessionExpiredCallback(Future<void> Function() callback) {
  _onSessionExpired = callback;
}

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  final Dio _dio;
  final Future<void> Function()? onSessionExpired;

  AuthInterceptor(this._secureStorage, this._dio, {this.onSessionExpired});

  // ── Race condition koruması ───────────────────────────────────────────────
  // Aynı anda birden fazla 401 gelirse tek bir refresh yapılır,
  // diğerleri sonucu bekler. Bu olmadan eski refresh token iki kez kullanılır
  // → ikinci deneme başarısız olur → forceLogout tetiklenir.
  Future<bool>? _pendingRefresh;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _secureStorage.read(key: StorageKeys.accessToken);
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Eş zamanlı 401'lerde tek refresh — diğerleri mevcut Future'ı bekler
      _pendingRefresh ??= _refreshToken().whenComplete(() {
        _pendingRefresh = null;
      });
      final refreshed = await _pendingRefresh!;

      if (refreshed) {
        try {
          final response = await _retry(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          return handler.reject(err);
        }
      } else {
        await _clearTokens();
        await (onSessionExpired ?? _onSessionExpired)?.call();
        return handler.reject(err);
      }
    }
    return handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken =
          await _secureStorage.read(key: StorageKeys.refreshToken);
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final response = await _dio.post(
        '${ApiConstants.baseUrl}/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _secureStorage.write(
            key: StorageKeys.accessToken, value: data['accessToken'] as String);
        await _secureStorage.write(
            key: StorageKeys.refreshToken,
            value: data['refreshToken'] as String);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final accessToken =
        await _secureStorage.read(key: StorageKeys.accessToken);
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: {
          ...requestOptions.headers,
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: StorageKeys.accessToken);
    await _secureStorage.delete(key: StorageKeys.refreshToken);
    await _secureStorage.delete(key: StorageKeys.userId);
  }
}
