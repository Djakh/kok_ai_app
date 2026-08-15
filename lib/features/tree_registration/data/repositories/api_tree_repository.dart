import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kok_ai_app/core/network/api_client.dart';
import 'package:kok_ai_app/features/tree_registration/data/dto/tree_dto_mapper.dart';
import 'package:kok_ai_app/features/tree_registration/domain/entities/tree_models.dart';
import 'package:kok_ai_app/features/tree_registration/domain/repositories/tree_repository.dart';

class ApiTreeRepository implements TreeRepository {
  const ApiTreeRepository({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<TreeAnalysis> analyzeTree(TreeAnalysisRequest request) async {
    await _validateAnalysisRequest(request);
    final form = FormData();
    form.fields.add(
      MapEntry('location_evidence', jsonEncode(request.location.toJson())),
    );
    for (final photo in request.photos) {
      form.fields.add(MapEntry('photo_types', photo.type.apiValue));
      form.files.add(
        MapEntry(
          'photos',
          await MultipartFile.fromFile(
            photo.localPath,
            filename: photo.localPath.split('/').last,
          ),
        ),
      );
    }
    final data = await apiClient.post(
      '/tree-analyses',
      body: form,
      headers: {'Idempotency-Key': request.idempotencyKey},
    );
    return TreeDtoMapper.analysis(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<TreeAnalysis> getTreeAnalysis(String analysisId) async {
    final data = await apiClient.get('/tree-analyses/$analysisId');
    return TreeDtoMapper.analysis(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<List<NearbyTreeCandidate>> findNearbyTrees({
    required GeoCoordinate coordinate,
    required double radiusMeters,
  }) async {
    if (!radiusMeters.isFinite || radiusMeters <= 0 || radiusMeters > 100) {
      throw RangeError.range(radiusMeters, 0, 100, 'radiusMeters');
    }
    _validateCoordinate(coordinate);
    final data = await apiClient.get(
      '/trees/nearby',
      queryParameters: {
        'latitude': coordinate.latitude,
        'longitude': coordinate.longitude,
        'radius_meters': radiusMeters,
      },
    );
    final raw = data is Map ? data['items'] as List? ?? const [] : data as List;
    return raw
        .whereType<Map>()
        .map((item) => TreeDtoMapper.nearby(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<TreeRecord> createTree(CreateTreeRequest request) async {
    if (request.selectedCandidateId != null &&
        request.manualScientificName != null) {
      throw ArgumentError(
        'selectedCandidateId and manualScientificName are mutually exclusive',
      );
    }
    if (!const {'public', 'private'}.contains(request.visibility)) {
      throw ArgumentError.value(request.visibility, 'visibility');
    }
    final data = await apiClient.post(
      '/trees',
      body: {
        'analysis_id': request.analysisId,
        'selected_candidate_id': request.selectedCandidateId,
        'manual_scientific_name': request.manualScientificName,
        'location_evidence': request.location.toJson(),
        'duplicate_check_status': request.duplicateCheckStatus.name,
        'nickname': request.nickname,
        'notes': request.notes,
        'visibility': request.visibility,
      },
      headers: {'Idempotency-Key': request.idempotencyKey},
    );
    return TreeDtoMapper.tree(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<TreeRecord> getTree(String treeId) async {
    final data = await apiClient.get('/trees/$treeId');
    return TreeDtoMapper.tree(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<PaginatedTrees> getTrees(TreeQuery query) async {
    if (query.limit < 1 || query.limit > 200) {
      throw RangeError.range(query.limit, 1, 200, 'limit');
    }
    if (query.sort == 'nearest' && query.coordinate == null) {
      throw ArgumentError('nearest sort requires a coordinate');
    }
    if (query.coordinate != null) _validateCoordinate(query.coordinate!);
    final data = await apiClient.get(
      '/trees',
      queryParameters: {
        'cursor': query.cursor,
        'limit': query.limit,
        'q': query.search,
        'sort': query.sort,
        'species': query.species,
        'latitude': query.coordinate?.latitude,
        'longitude': query.coordinate?.longitude,
      },
    );
    final map = data is Map ? Map<String, dynamic>.from(data) : null;
    final raw = map?['items'] as List? ?? data as List;
    final items = raw
        .whereType<Map>()
        .map((item) => TreeDtoMapper.tree(Map<String, dynamic>.from(item)))
        .toList();
    return PaginatedTrees(
      items: items,
      nextCursor: map?['next_cursor'] as String?,
      hasMore: map?['has_more'] == true,
    );
  }

  @override
  Future<List<TreeScan>> getTreeScans(String treeId) async {
    final data = await apiClient.get('/trees/$treeId/scans');
    final raw = data is Map ? data['items'] as List? ?? const [] : data as List;
    return raw
        .whereType<Map>()
        .map((item) => TreeDtoMapper.scan(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<List<TreeRecord>> getMapTrees(TreeMapQuery query) async {
    final hasBbox = query.bbox?.trim().isNotEmpty == true;
    final hasCenter = query.center?.trim().isNotEmpty == true;
    if (hasBbox == hasCenter) {
      throw ArgumentError('Provide exactly one of bbox or center');
    }
    if (hasCenter &&
        (query.radius == null ||
            !query.radius!.isFinite ||
            query.radius! <= 0)) {
      throw ArgumentError('A positive radius is required with center');
    }
    final data = await apiClient.get(
      '/trees/map',
      queryParameters: {
        'bbox': query.bbox,
        'center': query.center,
        'radius': query.radius,
        'status': query.status,
      },
    );
    final raw = data is Map ? data['items'] as List? ?? const [] : data as List;
    return raw
        .whereType<Map>()
        .map((item) => TreeDtoMapper.tree(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<TreeScan> createTreeScan(CreateTreeScanRequest request) async {
    if (request.treeId.trim().isEmpty) {
      throw ArgumentError.value(request.treeId, 'treeId');
    }
    if (request.photos.isEmpty || request.photos.length > 5) {
      throw RangeError.range(request.photos.length, 1, 5, 'photos.length');
    }
    if (request.notes != null && request.notes!.length > 2000) {
      throw RangeError.range(request.notes!.length, 0, 2000, 'notes.length');
    }
    if (request.location != null) {
      _validateCoordinate(request.location!.coordinate);
    }
    await _validatePhotoFiles(request.photos);

    final form = FormData();
    form.fields.add(const MapEntry('run_analysis', 'true'));
    if (request.location != null) {
      form.fields.add(
        MapEntry('location_evidence', jsonEncode(request.location!.toJson())),
      );
    }
    if (request.capturedAt != null) {
      form.fields.add(
        MapEntry('captured_at', request.capturedAt!.toUtc().toIso8601String()),
      );
    }
    if (request.notes?.trim().isNotEmpty == true) {
      form.fields.add(MapEntry('notes', request.notes!.trim()));
    }
    for (final photo in request.photos) {
      form.fields.add(MapEntry('photo_types', photo.type.apiValue));
      form.files.add(
        MapEntry(
          'photos',
          await MultipartFile.fromFile(
            photo.localPath,
            filename: photo.localPath.split('/').last,
          ),
        ),
      );
    }
    final data = await apiClient.post(
      '/trees/${request.treeId}/scans',
      body: form,
      headers: {'Idempotency-Key': request.idempotencyKey},
    );
    return TreeDtoMapper.scan(Map<String, dynamic>.from(data as Map));
  }

  static Future<void> _validateAnalysisRequest(
    TreeAnalysisRequest request,
  ) async {
    if (request.photos.length < 2 || request.photos.length > 5) {
      throw RangeError.range(request.photos.length, 2, 5, 'photos.length');
    }
    final types = request.photos.map((item) => item.type).toList();
    if (types.where((item) => item == TreePhotoType.wholeTree).length != 1 ||
        types.where((item) => item == TreePhotoType.leaf).length != 1 ||
        types.toSet().length != types.length) {
      throw ArgumentError(
        'Photos require one whole_tree, one leaf, and unique optional types',
      );
    }
    _validateCoordinate(request.location.coordinate);
    if (!request.location.horizontalAccuracyMeters.isFinite ||
        request.location.horizontalAccuracyMeters <= 0 ||
        !request.location.bestSampleAccuracyMeters.isFinite ||
        request.location.bestSampleAccuracyMeters <= 0 ||
        request.location.acceptedSampleCount < 1) {
      throw ArgumentError('Invalid location evidence');
    }
    await _validatePhotoFiles(request.photos);
  }

  static Future<void> _validatePhotoFiles(List<TreePhotoDraft> photos) async {
    const maxFileBytes = 10000000;
    const maxRequestBytes = 30000000;
    var totalBytes = 0;
    for (final photo in photos) {
      final file = File(photo.localPath);
      if (!await file.exists()) {
        throw ArgumentError('Photo file does not exist: ${photo.localId}');
      }
      final length = await file.length();
      if (length <= 0 || length > maxFileBytes) {
        throw RangeError.range(length, 1, maxFileBytes, 'photo file bytes');
      }
      totalBytes += length;
    }
    if (totalBytes > maxRequestBytes) {
      throw RangeError.range(
        totalBytes,
        1,
        maxRequestBytes,
        'combined photo bytes',
      );
    }
  }

  static void _validateCoordinate(GeoCoordinate coordinate) {
    if (!coordinate.latitude.isFinite ||
        !coordinate.longitude.isFinite ||
        coordinate.latitude < -90 ||
        coordinate.latitude > 90 ||
        coordinate.longitude < -180 ||
        coordinate.longitude > 180) {
      throw ArgumentError('Invalid geographic coordinate');
    }
  }
}
