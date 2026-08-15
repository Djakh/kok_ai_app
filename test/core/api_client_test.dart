import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kok_ai_app/core/network/api_client.dart';
import 'package:kok_ai_app/core/network/api_exception.dart';
import 'package:kok_ai_app/core/network/auth_token_store.dart';

void main() {
  test('concurrent 401 responses share one rotating refresh request', () async {
    final tokenStore = AuthTokenStore(storage: InMemoryAuthTokenStorage());
    await tokenStore.saveTokens(
      accessToken: 'expired-access',
      refreshToken: 'single-use-refresh',
    );
    final client = ApiClient(tokenStore: tokenStore);
    var refreshCalls = 0;
    client.refreshDio.httpClientAdapter = _StubAdapter((options) async {
      refreshCalls += 1;
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(options.path, '/auth/refresh');
      expect(options.data, {'refresh_token': 'single-use-refresh'});
      return _json(200, {
        'success': true,
        'data': {
          'access_token': 'fresh-access',
          'refresh_token': 'rotated-refresh',
          'token_type': 'bearer',
          'expires_in': 900,
        },
      });
    });
    client.dio.httpClientAdapter = _StubAdapter((options) async {
      if (options.headers['Authorization'] != 'Bearer fresh-access') {
        if (options.path == '/notifications') {
          await Future<void>.delayed(const Duration(milliseconds: 60));
        }
        return _error(401, 'unauthorized');
      }
      return _json(200, {
        'success': true,
        'data': {'path': options.path},
      });
    });

    final values = await Future.wait([
      client.get('/users/me'),
      client.get('/notifications'),
    ]);

    expect(refreshCalls, 1);
    expect(values, [
      {'path': '/users/me'},
      {'path': '/notifications'},
    ]);
    expect(await tokenStore.readAccessToken(), 'fresh-access');
    expect(await tokenStore.readRefreshToken(), 'rotated-refresh');
  });

  test('403 is surfaced without attempting token refresh', () async {
    final client = _client();
    var refreshCalls = 0;
    client.refreshDio.httpClientAdapter = _StubAdapter((_) {
      refreshCalls += 1;
      return _error(500, 'unexpected');
    });
    client.dio.httpClientAdapter = _StubAdapter(
      (_) => _error(403, 'forbidden'),
    );

    await expectLater(
      client.get('/trees/private'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.code, 'code', 'forbidden')
            .having((error) => error.statusCode, 'statusCode', 403),
      ),
    );
    expect(refreshCalls, 0);
  });

  test('structured errors retain request id and retry timing', () async {
    final client = _client();
    client.dio.httpClientAdapter = _StubAdapter(
      (_) => _json(
        429,
        {
          'success': false,
          'data': null,
          'error': {
            'code': 'ai_rate_limited',
            'message': 'Try later',
            'details': {'retry_after_seconds': 30},
            'request_id': 'request-123',
          },
          'meta': null,
        },
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
          'retry-after': ['45'],
        },
      ),
    );

    await expectLater(
      client.get('/tree-analyses/a'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.code, 'code', 'ai_rate_limited')
            .having((error) => error.requestId, 'requestId', 'request-123')
            .having((error) => error.retryAfterSeconds, 'retryAfterSeconds', 30)
            .having((error) => error.canRetry, 'canRetry', true),
      ),
    );
  });

  test('a 401 after refresh clears the rotated session', () async {
    final tokenStore = AuthTokenStore(storage: InMemoryAuthTokenStorage());
    await tokenStore.saveTokens(accessToken: 'old', refreshToken: 'refresh');
    final client = ApiClient(tokenStore: tokenStore);
    client.refreshDio.httpClientAdapter = _StubAdapter(
      (_) => _json(200, {
        'success': true,
        'data': {'access_token': 'new', 'refresh_token': 'new-refresh'},
      }),
    );
    client.dio.httpClientAdapter = _StubAdapter(
      (_) => _error(401, 'unauthorized'),
    );

    await expectLater(client.get('/users/me'), throwsA(isA<ApiException>()));
    expect(await tokenStore.readAccessToken(), isNull);
    expect(await tokenStore.readRefreshToken(), isNull);
  });

  test('a backend 401 never clears the static debug session', () async {
    final tokenStore = AuthTokenStore(storage: InMemoryAuthTokenStorage());
    await tokenStore.saveTokens(
      accessToken: AuthTokenStore.debugAccessToken,
      refreshToken: AuthTokenStore.debugRefreshToken,
    );
    final client = ApiClient(tokenStore: tokenStore);
    var refreshCalls = 0;
    client.refreshDio.httpClientAdapter = _StubAdapter((_) {
      refreshCalls += 1;
      return _error(401, 'unauthorized');
    });
    client.dio.httpClientAdapter = _StubAdapter(
      (_) => _error(401, 'unauthorized'),
    );

    await expectLater(client.get('/trees'), throwsA(isA<ApiException>()));

    expect(refreshCalls, 0);
    expect(await tokenStore.isDebugSession(), isTrue);
    expect(await tokenStore.readAccessToken(), AuthTokenStore.debugAccessToken);
  });

  test('API logs redact coordinates, notes, and signed URL queries', () async {
    final originalDebugPrint = debugPrint;
    final messages = <String>[];
    debugPrint = (message, {wrapWidth}) {
      if (message != null) messages.add(message);
    };
    addTearDown(() => debugPrint = originalDebugPrint);
    final client = _client();
    client.dio.httpClientAdapter = _StubAdapter(
      (_) => _json(200, {
        'success': true,
        'data': {
          'image_url':
              'https://media.example/tree.jpg?signature=secret-signature',
        },
      }),
    );

    await client.post(
      '/trees',
      queryParameters: {'latitude': 41.299503, 'longitude': 69.240098},
      body: {
        'notes': 'Near the private north entrance',
        'location_evidence': {'latitude': 41.299503},
      },
    );

    final output = messages.join('\n');
    expect(output, isNot(contains('41.299503')));
    expect(output, isNot(contains('69.240098')));
    expect(output, isNot(contains('private north entrance')));
    expect(output, isNot(contains('secret-signature')));
    expect(output, contains('<redacted>'));
    expect(output, contains('https://media.example/tree.jpg'));
  });
}

ApiClient _client() =>
    ApiClient(tokenStore: AuthTokenStore(storage: InMemoryAuthTokenStorage()));

ResponseBody _error(int status, String code) => _json(status, {
  'success': false,
  'data': null,
  'error': {'code': code, 'message': code, 'details': null},
  'meta': null,
});

ResponseBody _json(
  int status,
  Object body, {
  Map<String, List<String>>? headers,
}) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers:
      headers ??
      {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
);

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.handler);

  final FutureOr<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => handler(options);

  @override
  void close({bool force = false}) {}
}
