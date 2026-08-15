import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kok_ai_app/core/network/api_config.dart';
import 'package:kok_ai_app/core/network/api_exception.dart';
import 'package:kok_ai_app/core/network/api_logger_interceptor.dart';
import 'package:kok_ai_app/core/network/auth_token_store.dart';

class ApiClient {
  static const _loggingEnabled = bool.fromEnvironment(
    'API_LOGGING',
    defaultValue: kDebugMode,
  );
  static const _bodyLoggingEnabled = bool.fromEnvironment(
    'API_LOG_BODIES',
    defaultValue: kDebugMode,
  );

  ApiClient({required this.tokenStore})
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: {'Accept': 'application/json'},
        ),
      ),
      refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: {'Accept': 'application/json'},
        ),
      ),
      systemDio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.apiRootUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Accept': 'application/json'},
        ),
      ) {
    if (_loggingEnabled) {
      debugPrint(
        '[API] mode=${ApiConfig.dataModeLabel} baseUrl=${ApiConfig.baseUrl}',
      );
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final queryParameters = sanitizeQueryParameters(
            options.queryParameters,
          );
          options.queryParameters
            ..clear()
            ..addAll(queryParameters ?? <String, dynamic>{});
          final token = await tokenStore.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final retried = error.requestOptions.extra['retried'] == true;
          final statusCode = error.response?.statusCode;
          final path = error.requestOptions.path;

          final isDebugSession = statusCode == 401
              ? await tokenStore.isDebugSession()
              : false;
          if (statusCode == 401 &&
              !retried &&
              !isDebugSession &&
              canRefreshForPath(path)) {
            final retriedResponse = await retryAfterRefresh(
              error.requestOptions,
            );
            if (retriedResponse != null) {
              handler.resolve(retriedResponse);
              return;
            }
          }

          handler.next(error);
        },
      ),
    );

    if (_loggingEnabled) {
      final logger = ApiLoggerInterceptor(includeBodies: _bodyLoggingEnabled);
      dio.interceptors.add(logger);
      refreshDio.interceptors.add(
        ApiLoggerInterceptor(
          label: 'AUTH REFRESH',
          includeBodies: _bodyLoggingEnabled,
        ),
      );
      systemDio.interceptors.add(
        ApiLoggerInterceptor(
          label: 'SYSTEM',
          includeBodies: _bodyLoggingEnabled,
        ),
      );
    }
  }

  final Dio dio;
  final Dio refreshDio;
  final Dio systemDio;
  final AuthTokenStore tokenStore;
  Future<bool>? _refreshInFlight;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _getWithRetry(
        dio,
        path,
        queryParameters: sanitizeQueryParameters(queryParameters),
      );
      return responseData(response);
    } on DioException catch (error) {
      throw mapDioError(error);
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: body,
        options: Options(headers: headers),
        queryParameters: sanitizeQueryParameters(queryParameters),
      );
      return responseData(response);
    } on DioException catch (error) {
      throw mapDioError(error);
    }
  }

  Future<dynamic> patch(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.patch(
        path,
        data: body,
        options: Options(headers: headers),
        queryParameters: sanitizeQueryParameters(queryParameters),
      );
      return responseData(response);
    } on DioException catch (error) {
      throw mapDioError(error);
    }
  }

  Future<dynamic> delete(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: body,
        options: Options(headers: headers),
        queryParameters: sanitizeQueryParameters(queryParameters),
      );
      return responseData(response);
    } on DioException catch (error) {
      throw mapDioError(error);
    }
  }

  Future<dynamic> getSystem(String path) async {
    try {
      final response = await _getWithRetry(systemDio, path);
      return responseData(response);
    } on DioException catch (error) {
      throw mapDioError(error);
    }
  }

  Future<Response<dynamic>> _getWithRetry(
    Dio client,
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    const maxRetries = 2;
    for (var attempt = 0; ; attempt++) {
      try {
        return await client.get(path, queryParameters: queryParameters);
      } on DioException catch (error) {
        if (attempt >= maxRetries || !_isRetryableGet(error)) rethrow;
        final retryAfter = _retryAfterFromHeaders(error.response?.headers);
        final milliseconds = retryAfter == null
            ? (300 * pow(2, attempt)).round() + Random().nextInt(180)
            : min(retryAfter, 30) * 1000;
        await Future<void>.delayed(Duration(milliseconds: milliseconds));
      }
    }
  }

  bool _isRetryableGet(DioException error) {
    final status = error.response?.statusCode;
    // Rate limits are surfaced with retryAfterSeconds so the UI can wait
    // without keeping a request/test isolate blocked for an arbitrary delay.
    if (status != null && status >= 500) return true;
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => true,
      _ => false,
    };
  }

  dynamic responseData(Response<dynamic> response) => envelopeData(
    response.data,
    statusCode: response.statusCode,
    headers: response.headers,
  );

  dynamic envelopeData(dynamic raw, {int? statusCode, Headers? headers}) {
    if (raw is Map && raw.containsKey('success')) {
      final success = raw['success'] == true;
      if (success) return raw['data'];
      final error = raw['error'] is Map
          ? Map<String, dynamic>.from(raw['error'] as Map)
          : null;
      final details = error?['details'];
      throw ApiException(
        code: '${error?['code'] ?? 'unknown_error'}',
        message: '${error?['message'] ?? 'Unexpected API error'}',
        details: details,
        statusCode: statusCode,
        requestId:
            _nonEmptyString(error?['request_id']) ??
            _nonEmptyString(headers?.value('x-request-id')),
        retryAfterSeconds:
            _retryAfterFromDetails(details) ?? _retryAfterFromHeaders(headers),
      );
    }
    return raw;
  }

  ApiException mapDioError(DioException error) {
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      try {
        envelopeData(
          responseData,
          statusCode: error.response?.statusCode,
          headers: error.response?.headers,
        );
      } catch (exception) {
        if (exception is ApiException) return exception;
      }
    }

    final releaseBuildHint = ApiConfig.releaseBuildHint;
    final cleartextHint = cleartextHintFor(error);

    final isTimeout = switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => true,
      _ => false,
    };

    return ApiException(
      code: isTimeout ? 'request_timeout' : 'network_error',
      message:
          releaseBuildHint ??
          cleartextHint ??
          (isTimeout
              ? 'The request timed out. Please retry safely.'
              : error.message ?? 'Network error'),
      details: responseData,
      statusCode: error.response?.statusCode,
      requestId: _nonEmptyString(error.response?.headers.value('x-request-id')),
      retryAfterSeconds: _retryAfterFromHeaders(error.response?.headers),
    );
  }

  String? cleartextHintFor(DioException error) {
    final rawMessage = '${error.message ?? ''} ${error.error ?? ''}'
        .toUpperCase();
    if (!rawMessage.contains('CLEARTEXT')) return null;

    return 'Android blocked cleartext HTTP for ${ApiConfig.baseUrl}. '
        'Use https:// or keep cleartext traffic enabled in the Android '
        'manifest.';
  }

  bool canRefreshForPath(String path) {
    return !path.contains('/auth/login') &&
        !path.contains('/auth/register') &&
        !path.contains('/auth/refresh') &&
        !path.contains('/auth/logout');
  }

  Map<String, dynamic>? sanitizeQueryParameters(
    Map<String, dynamic>? queryParameters,
  ) {
    if (queryParameters == null || queryParameters.isEmpty) return null;

    final sanitized = <String, dynamic>{};

    for (final entry in queryParameters.entries) {
      final value = entry.value;
      if (value == null) continue;
      if (value is String && value.trim().isEmpty) continue;
      if (value is Iterable && value.isEmpty) continue;
      sanitized[entry.key] = value;
    }

    if (sanitized.isEmpty) return null;
    return sanitized;
  }

  Future<Response<dynamic>?> retryAfterRefresh(
    RequestOptions requestOptions,
  ) async {
    final accessBeforeRefresh = await tokenStore.readAccessToken();
    final failedAuthorization = requestOptions.headers['Authorization'];
    final tokenAlreadyRotated =
        accessBeforeRefresh != null &&
        accessBeforeRefresh.isNotEmpty &&
        failedAuthorization != 'Bearer $accessBeforeRefresh';
    if (!tokenAlreadyRotated && !await refreshSession()) return null;

    final accessToken = await tokenStore.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) return null;

    final headers = Map<String, dynamic>.from(requestOptions.headers);
    headers['Authorization'] = 'Bearer $accessToken';

    final options = Options(
      method: requestOptions.method,
      headers: headers,
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      sendTimeout: requestOptions.sendTimeout,
      receiveTimeout: requestOptions.receiveTimeout,
      extra: {...requestOptions.extra, 'retried': true},
    );

    try {
      return await dio.request<dynamic>(
        requestOptions.path,
        data: requestOptions.data is FormData
            ? (requestOptions.data as FormData).clone()
            : requestOptions.data,
        queryParameters: sanitizeQueryParameters(
          requestOptions.queryParameters,
        ),
        options: options,
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        await tokenStore.clearTokens();
      }
      return null;
    }
  }

  Future<bool> refreshSession() async {
    final activeRefresh = _refreshInFlight;
    if (activeRefresh != null) return activeRefresh;

    final operation = _performRefresh();
    _refreshInFlight = operation;
    try {
      return await operation;
    } finally {
      if (identical(_refreshInFlight, operation)) {
        _refreshInFlight = null;
      }
    }
  }

  Future<bool> _performRefresh() async {
    final refreshToken = await tokenStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final refreshResponse = await refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final refreshData = responseData(refreshResponse);
      if (refreshData is! Map) {
        await tokenStore.clearTokens();
        return false;
      }
      final accessToken = '${refreshData['access_token'] ?? ''}';
      final nextRefreshToken = '${refreshData['refresh_token'] ?? ''}';
      if (accessToken.isEmpty || nextRefreshToken.isEmpty) {
        await tokenStore.clearTokens();
        return false;
      }

      await tokenStore.saveTokens(
        accessToken: accessToken,
        refreshToken: nextRefreshToken,
      );

      return true;
    } catch (_) {
      await tokenStore.clearTokens();
      return false;
    }
  }

  static String? _nonEmptyString(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static int? _retryAfterFromDetails(dynamic details) {
    if (details is! Map) return null;
    return (details['retry_after_seconds'] as num?)?.toInt();
  }

  static int? _retryAfterFromHeaders(Headers? headers) {
    final value = headers?.value('retry-after')?.trim();
    if (value == null || value.isEmpty) return null;
    final seconds = int.tryParse(value);
    if (seconds != null) return seconds < 0 ? 0 : seconds;
    final date = DateTime.tryParse(value)?.toUtc();
    if (date == null) return null;
    final difference = date.difference(DateTime.now().toUtc()).inSeconds;
    return difference < 0 ? 0 : difference;
  }
}
