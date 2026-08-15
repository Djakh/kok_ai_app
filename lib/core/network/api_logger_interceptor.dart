import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Privacy-safe Dio logger used by API, token refresh, and system clients.
class ApiLoggerInterceptor extends Interceptor {
  ApiLoggerInterceptor({
    this.label = 'API',
    this.includeBodies = false,
    Logger? logger,
  }) : logger =
           logger ??
           Logger(
             filter: ProductionFilter(),
             printer: _MessageOnlyPrinter(),
             output: _DebugPrintOutput(),
           );

  static const _startedAtKey = 'kokai_api_log_started_at';
  static final _sensitiveKey = RegExp(
    r'(authorization|password|passcode|token|secret|api[_-]?key|latitude|longitude|location[_-]?evidence|notes?|private[_-]?note)',
    caseSensitive: false,
  );

  final String label;
  final bool includeBodies;
  final Logger logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedAtKey] = Stopwatch()..start();
    final retry = options.extra['retried'] == true ? ' retry=true' : '';
    logger.d('[$label →] ${options.method} ${_safeUri(options)}$retry');
    if (includeBodies && options.data != null) {
      logger.d('[$label → body] ${_preview(options.data)}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final request = response.requestOptions;
    final requestId = response.headers.value('x-request-id');
    logger.i(
      '[$label ←] ${request.method} ${_safeUri(request)} '
      'status=${response.statusCode ?? '-'} duration=${_elapsed(request)}'
      '${requestId == null ? '' : ' requestId=$requestId'}',
    );
    if (includeBodies && response.data != null) {
      logger.d('[$label ← body] ${_preview(response.data)}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final request = err.requestOptions;
    final response = err.response;
    final requestId = response?.headers.value('x-request-id');
    final apiError = response?.data is Map ? response?.data['error'] : null;
    final code = apiError is Map ? apiError['code'] : null;
    final message = apiError is Map ? apiError['message'] : err.message;
    logger.e(
      '[$label ✕] ${request.method} ${_safeUri(request)} '
      'status=${response?.statusCode ?? '-'} type=${err.type.name} '
      'duration=${_elapsed(request)}'
      '${code == null ? '' : ' code=${_singleLine(code)}'}'
      '${requestId == null ? '' : ' requestId=$requestId'}'
      '${message == null ? '' : ' message=${_singleLine(message)}'}',
    );
    if (includeBodies && response?.data != null) {
      logger.d('[$label ✕ body] ${_preview(response?.data)}');
    }
    handler.next(err);
  }

  String _safeUri(RequestOptions options) {
    if (options.queryParameters.isEmpty) return _stripUrlQuery(options.uri);

    final safeQuery = <String, dynamic>{};
    for (final entry in options.queryParameters.entries) {
      safeQuery[entry.key] = _sensitiveKey.hasMatch(entry.key)
          ? '<redacted>'
          : _queryValue(entry.value);
    }
    return options.uri.replace(queryParameters: safeQuery).toString();
  }

  Object _queryValue(dynamic value) {
    if (value is Iterable) {
      return value.map((item) => item.toString()).toList(growable: false);
    }
    return value.toString();
  }

  String _elapsed(RequestOptions options) {
    final stopwatch = options.extra[_startedAtKey];
    if (stopwatch is! Stopwatch) return 'unknown';
    if (stopwatch.isRunning) stopwatch.stop();
    return '${stopwatch.elapsedMilliseconds}ms';
  }

  String _singleLine(Object value) {
    final text = value.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
    return text.length <= 240 ? text : '${text.substring(0, 240)}…';
  }

  String _preview(dynamic value) {
    final safeValue = _redact(value);
    final encoded = safeValue is String ? safeValue : jsonEncode(safeValue);
    return encoded.length <= 2000 ? encoded : '${encoded.substring(0, 2000)}…';
  }

  dynamic _redact(dynamic value, {String? key}) {
    if (key != null && _sensitiveKey.hasMatch(key)) return '<redacted>';
    if (value is FormData) {
      return {
        'fields': [
          for (final field in value.fields)
            {'name': field.key, 'value': _redact(field.value, key: field.key)},
        ],
        'files': [
          for (final file in value.files)
            {
              'field': file.key,
              'filename': file.value.filename,
              'length': file.value.length,
            },
        ],
      };
    }
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): _redact(entry.value, key: entry.key.toString()),
      };
    }
    if (value is Iterable) {
      return value.map((item) => _redact(item)).toList(growable: false);
    }
    if (value is num || value is bool || value == null) return value;
    if (value is String) {
      final uri = Uri.tryParse(value);
      if (uri != null && uri.hasScheme && uri.hasQuery) {
        return _stripUrlQuery(uri);
      }
    }
    return value.toString();
  }

  String _stripUrlQuery(Uri uri) => uri.hasQuery
      ? uri.replace(query: '', fragment: '').toString()
      : uri.toString();
}

class _MessageOnlyPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) => [event.message.toString()];
}

class _DebugPrintOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      debugPrint(line);
    }
  }
}
