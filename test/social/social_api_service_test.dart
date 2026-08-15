import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kok_ai_app/core/network/api_client.dart';
import 'package:kok_ai_app/core/network/api_exception.dart';
import 'package:kok_ai_app/core/network/auth_token_store.dart';
import 'package:kok_ai_app/features/social/data/models/social_post_payload.dart';
import 'package:kok_ai_app/features/social/data/services/social_api_service.dart';
import 'package:kok_ai_app/features/upload/data/services/upload_api_service.dart';

void main() {
  test('post retry reuses uploaded asset and idempotency key', () async {
    final file = File('${Directory.systemTemp.path}/kokai-social-test.jpg');
    await file.writeAsBytes([1, 2, 3]);
    addTearDown(() async {
      if (await file.exists()) await file.delete();
    });

    final client = ApiClient(
      tokenStore: AuthTokenStore(storage: InMemoryAuthTokenStorage()),
    );
    var uploadCalls = 0;
    var postCalls = 0;
    final keys = <dynamic>[];
    final uploadIds = <dynamic>[];
    client.dio.httpClientAdapter = _StubAdapter((options) {
      if (options.path == '/uploads/images') {
        uploadCalls += 1;
        return _json(201, {
          'success': true,
          'data': {
            'id': 'upload-1',
            'url': 'https://media.example/upload-1.jpg',
            'content_type': 'image/jpeg',
            'file_name': 'social.jpg',
            'file_size': 3,
            'created_at': '2026-08-15T05:00:00Z',
          },
        });
      }
      postCalls += 1;
      keys.add(options.headers['Idempotency-Key']);
      uploadIds.add((options.data as Map)['upload_id']);
      if (postCalls == 1) {
        return _json(502, {
          'success': false,
          'data': null,
          'error': {
            'code': 'backend_unavailable',
            'message': 'retry',
            'details': null,
          },
          'meta': null,
        });
      }
      return _json(201, {
        'success': true,
        'data': {'id': 'post-1'},
      });
    });
    final service = SocialApiService(
      apiClient: client,
      uploadApiService: UploadApiService(apiClient: client),
    );
    final payload = SocialPostPayload(
      content: 'A tree',
      imagePath: file.path,
      latitude: null,
      longitude: null,
      createdAt: DateTime.utc(2026, 8, 15),
      idempotencyKey: 'stable-post-key',
    );

    await expectLater(
      service.createPost(payload),
      throwsA(isA<ApiException>()),
    );
    final result = await service.createPost(payload);

    expect(result.postId, 'post-1');
    expect(uploadCalls, 1);
    expect(postCalls, 2);
    expect(keys, ['stable-post-key', 'stable-post-key']);
    expect(uploadIds, ['upload-1', 'upload-1']);
  });
}

ResponseBody _json(int status, Object body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => handler(options);

  @override
  void close({bool force = false}) {}
}
