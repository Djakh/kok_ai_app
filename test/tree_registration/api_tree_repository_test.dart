import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kok_ai_app/core/network/api_client.dart';
import 'package:kok_ai_app/core/network/api_exception.dart';
import 'package:kok_ai_app/core/network/auth_token_store.dart';
import 'package:kok_ai_app/features/tree_registration/data/repositories/api_tree_repository.dart';
import 'package:kok_ai_app/features/tree_registration/domain/entities/tree_models.dart';

void main() {
  test(
    'successful multipart analysis sends typed photos and evidence',
    () async {
      final file = File('${Directory.systemTemp.path}/kokai-analysis-test.jpg');
      await file.writeAsBytes([1, 2, 3, 4]);
      addTearDown(() async {
        if (await file.exists()) await file.delete();
      });
      late RequestOptions captured;
      final repository = _repository((options) {
        captured = options;
        return _json(200, {
          'id': 'analysis-1',
          'provider': 'kindwise_plant_id',
          'analyzed_at': '2026-08-15T10:00:00Z',
          'candidates': [
            {
              'id': 'candidate-1',
              'scientific_name': 'Platanus orientalis',
              'confidence': .87,
            },
          ],
        });
      });

      final result = await repository.analyzeTree(
        TreeAnalysisRequest(
          photos: [
            TreePhotoDraft(
              localId: 'photo-1',
              localPath: file.path,
              type: TreePhotoType.wholeTree,
              capturedAt: DateTime(2026, 8, 15),
            ),
            TreePhotoDraft(
              localId: 'photo-2',
              localPath: file.path,
              type: TreePhotoType.leaf,
              capturedAt: DateTime(2026, 8, 15),
            ),
          ],
          location: _evidence(),
          idempotencyKey: 'analysis-key',
        ),
      );

      expect(result.id, 'analysis-1');
      expect(captured.path, '/tree-analyses');
      expect(captured.headers['Idempotency-Key'], 'analysis-key');
      final form = captured.data as FormData;
      expect(form.files, hasLength(2));
      expect(form.files.every((item) => item.key == 'photos'), isTrue);
      expect(
        form.fields
            .where((item) => item.key == 'photo_types')
            .map((item) => item.value),
        ['whole_tree', 'leaf'],
      );
      expect(
        form.fields
            .where((item) => item.key == 'location_evidence')
            .single
            .value,
        contains('accepted_sample_count'),
      );
    },
  );

  test('five-photo multipart preserves category order', () async {
    final file = File('${Directory.systemTemp.path}/kokai-five-photo-test.jpg');
    await file.writeAsBytes([1, 2, 3, 4]);
    addTearDown(() async {
      if (await file.exists()) await file.delete();
    });
    late FormData captured;
    final repository = _repository((options) {
      captured = options.data as FormData;
      return _json(201, {
        'id': 'analysis-5',
        'provider': 'kindwise_plant_id',
        'analyzed_at': '2026-08-15T10:00:00Z',
        'candidates': [],
      });
    });
    const types = TreePhotoType.values;
    await repository.analyzeTree(
      TreeAnalysisRequest(
        photos: [
          for (var index = 0; index < types.length; index++)
            TreePhotoDraft(
              localId: 'photo-$index',
              localPath: file.path,
              type: types[index],
              capturedAt: DateTime(2026, 8, 15),
            ),
        ],
        location: _evidence(),
        idempotencyKey: 'five-photo-key',
      ),
    );
    expect(captured.files, hasLength(5));
    expect(
      captured.fields
          .where((item) => item.key == 'photo_types')
          .map((item) => item.value),
      types.map((item) => item.apiValue),
    );
  });

  test('rejects invalid analysis cardinality before network I/O', () async {
    final repository = _repository(
      (_) => throw StateError('network should not be reached'),
    );
    expect(
      () => repository.analyzeTree(
        TreeAnalysisRequest(
          photos: const [],
          location: _evidence(),
          idempotencyKey: 'invalid',
        ),
      ),
      throwsRangeError,
    );
  });

  test('nearest list sends required coordinates', () async {
    late RequestOptions captured;
    final repository = _repository((options) {
      captured = options;
      return _json(200, {'items': [], 'next_cursor': null, 'has_more': false});
    });
    await repository.getTrees(
      const TreeQuery(
        sort: 'nearest',
        coordinate: GeoCoordinate(latitude: 41.3, longitude: 69.2),
      ),
    );
    expect(captured.queryParameters['latitude'], 41.3);
    expect(captured.queryParameters['longitude'], 69.2);
  });

  test('map queries use the dedicated map endpoint', () async {
    late RequestOptions captured;
    final repository = _repository((options) {
      captured = options;
      return _json(200, {
        'items': [_treeJson()],
      });
    });

    final trees = await repository.getMapTrees(
      const TreeMapQuery(center: '41.3,69.2', radius: 5000),
    );

    expect(captured.path, '/trees/map');
    expect(captured.queryParameters['center'], '41.3,69.2');
    expect(captured.queryParameters['radius'], 5000);
    expect(trees.single.id, 'tree-1');
  });

  test('follow-up scan sends multipart evidence and stable key', () async {
    final file = File('${Directory.systemTemp.path}/kokai-scan-test.jpg');
    await file.writeAsBytes([1, 2, 3, 4]);
    addTearDown(() async {
      if (await file.exists()) await file.delete();
    });
    late RequestOptions captured;
    final repository = _repository((options) {
      captured = options;
      return _json(201, {
        'id': 'scan-1',
        'scanned_at': '2026-08-15T10:00:00Z',
        'summary': 'Healthy leaves visible',
      });
    });

    final scan = await repository.createTreeScan(
      CreateTreeScanRequest(
        treeId: 'tree-1',
        photos: [
          TreePhotoDraft(
            localId: 'photo-1',
            localPath: file.path,
            type: TreePhotoType.leaf,
            capturedAt: DateTime.utc(2026, 8, 15, 10),
          ),
        ],
        location: _evidence(),
        capturedAt: DateTime.utc(2026, 8, 15, 10),
        notes: 'Follow-up',
        idempotencyKey: 'stable-scan-key',
      ),
    );

    expect(scan.id, 'scan-1');
    expect(captured.path, '/trees/tree-1/scans');
    expect(captured.headers['Idempotency-Key'], 'stable-scan-key');
    final form = captured.data as FormData;
    expect(form.files.single.key, 'photos');
    expect(
      form.fields.where((item) => item.key == 'run_analysis').single.value,
      'true',
    );
    expect(
      form.fields.where((item) => item.key == 'photo_types').single.value,
      'leaf',
    );
  });

  test('maps nearby empty and candidate responses', () async {
    var call = 0;
    final repository = _repository((_) {
      call += 1;
      return _json(200, {
        'items': call == 1
            ? []
            : [
                {
                  'tree_id': 'tree-1',
                  'display_name': 'Nearby plane',
                  'distance_meters': 3.4,
                  'registered_at': '2026-08-01T10:00:00Z',
                },
              ],
      });
    });

    final empty = await repository.findNearbyTrees(
      coordinate: const GeoCoordinate(latitude: 41.3, longitude: 69.2),
      radiusMeters: 20,
    );
    final found = await repository.findNearbyTrees(
      coordinate: const GeoCoordinate(latitude: 41.3, longitude: 69.2),
      radiusMeters: 20,
    );
    expect(empty, isEmpty);
    expect(found.single.treeId, 'tree-1');
    expect(found.single.distanceMeters, 3.4);
  });

  test(
    'preserves tree creation idempotency key across duplicate retry',
    () async {
      final seenKeys = <dynamic>[];
      final repository = _repository((options) {
        seenKeys.add(options.headers['Idempotency-Key']);
        return _json(201, _treeJson());
      });
      final request = CreateTreeRequest(
        analysisId: 'analysis-1',
        photos: const [],
        location: _evidence(),
        idempotencyKey: 'stable-create-key',
        duplicateCheckStatus: DuplicateCheckStatus.noNearbyTrees,
        selectedCandidateId: 'candidate-1',
      );

      await repository.createTree(request);
      await repository.createTree(request);
      expect(seenKeys, ['stable-create-key', 'stable-create-key']);
    },
  );

  for (final scenario in const [
    (415, 'invalid_image'),
    (422, 'no_plant_detected'),
    (422, 'ai_provider_rejected_input'),
    (429, 'ai_quota_exceeded'),
    (502, 'ai_provider_unavailable'),
    (504, 'request_timeout'),
  ]) {
    test('maps backend error ${scenario.$2}', () async {
      final repository = _repository(
        (_) => _json(scenario.$1, {
          'success': false,
          'error': {'code': scenario.$2, 'message': 'Mapped error'},
        }),
      );
      expect(
        () => repository.findNearbyTrees(
          coordinate: const GeoCoordinate(latitude: 41.3, longitude: 69.2),
          radiusMeters: 20,
        ),
        throwsA(
          isA<ApiException>().having(
            (error) => error.code,
            'code',
            scenario.$2,
          ),
        ),
      );
    });
  }
}

ApiTreeRepository _repository(
  ResponseBody Function(RequestOptions options) handler,
) {
  final client = ApiClient(
    tokenStore: AuthTokenStore(storage: InMemoryAuthTokenStorage()),
  );
  client.dio.httpClientAdapter = _StubAdapter(handler);
  return ApiTreeRepository(apiClient: client);
}

ResponseBody _json(int status, Object body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

TreeLocationEvidence _evidence() => TreeLocationEvidence(
  latitude: 41.3,
  longitude: 69.2,
  horizontalAccuracyMeters: 6,
  acceptedSampleCount: 6,
  rejectedSampleCount: 1,
  captureDuration: const Duration(seconds: 12),
  bestSampleAccuracyMeters: 4,
  capturedAt: DateTime(2026, 8, 15),
  quality: LocationQuality.acceptable,
);

Map<String, dynamic> _treeJson() => {
  'id': 'tree-1',
  'registered_at': '2026-08-15T10:00:00Z',
  'location': {
    'latitude': 41.3,
    'longitude': 69.2,
    'horizontal_accuracy_meters': 6,
    'quality': 'acceptable',
  },
  'identification': {
    'scientific_name': 'Platanus orientalis',
    'source': 'user_confirmed_ai',
  },
};

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
