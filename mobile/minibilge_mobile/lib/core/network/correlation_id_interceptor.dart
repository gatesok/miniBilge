import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../services/analytics_service.dart';

class CorrelationIdInterceptor extends Interceptor {
  static const headerName = 'X-Correlation-ID';
  static final Random _random = Random.secure();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent(headerName, _newCorrelationId);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _attachResponseCorrelationId(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final correlationId =
        _responseCorrelationId(err.response) ??
        err.requestOptions.headers[headerName]?.toString();
    if (correlationId != null) {
      err.requestOptions.extra['correlation_id'] = correlationId;
    }

    final statusCode = err.response?.statusCode;
    final shouldReport = statusCode == null || statusCode >= 500;
    if (shouldReport) {
      final endpoint = _normalizedPath(err.requestOptions.uri.path);
      unawaited(
        AnalyticsService.logEvent(
          AnalyticsEvents.apiError,
          parameters: {
            'endpoint': endpoint,
            'method': err.requestOptions.method.toLowerCase(),
            'status_code': statusCode ?? 0,
            'error_type': err.type.name,
          },
        ),
      );
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          err,
          err.stackTrace,
          reason: 'API request failed',
          information: [
            'correlation_id=$correlationId',
            'method=${err.requestOptions.method}',
            'endpoint=$endpoint',
            'status_code=${statusCode ?? 0}',
          ],
          fatal: false,
        ),
      );
    }

    handler.next(err);
  }

  static void _attachResponseCorrelationId(Response response) {
    final correlationId = _responseCorrelationId(response);
    if (correlationId != null) {
      response.requestOptions.extra['correlation_id'] = correlationId;
    }
  }

  static String? _responseCorrelationId(Response? response) =>
      response?.headers.value(headerName);

  static String _newCorrelationId() {
    const hex = '0123456789abcdef';
    return List.generate(32, (_) => hex[_random.nextInt(hex.length)]).join();
  }

  static String _normalizedPath(String path) {
    final segments = path.split('/').map((segment) {
      final isUuid = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(segment);
      final isNumeric = int.tryParse(segment) != null;
      return isUuid || isNumeric ? ':id' : segment;
    });
    return segments.join('/');
  }
}
