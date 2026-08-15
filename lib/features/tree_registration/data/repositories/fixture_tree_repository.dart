import 'package:kok_ai_app/features/tree_registration/domain/entities/tree_models.dart';
import 'package:kok_ai_app/features/tree_registration/domain/repositories/tree_repository.dart';
import 'package:kok_ai_app/features/tree_registration/domain/services/location_quality_service.dart';

/// Explicit development fixture. It is never selected automatically in release.
class FixtureTreeRepository implements TreeRepository {
  final List<TreeRecord> _trees = [];
  final Map<String, TreeRecord> _createdByKey = {};
  final LocationQualityService _location = const LocationQualityService();
  final Map<String, List<TreeScan>> _scans = {};

  @override
  Future<TreeAnalysis> analyzeTree(TreeAnalysisRequest request) async {
    return TreeAnalysis(
      id: 'demo-analysis-${request.idempotencyKey}',
      providerName: 'KOK.AI demo fixture',
      analyzedAt: DateTime.now(),
      candidates: const [
        SpeciesCandidate(
          id: 'platanus-orientalis',
          commonName: 'Oriental plane',
          scientificName: 'Platanus orientalis',
          confidence: 0.87,
          genus: 'Platanus',
          family: 'Platanaceae',
          description:
              'A large deciduous tree recognised by its broad crown and patterned bark.',
        ),
        SpeciesCandidate(
          id: 'platanus-occidentalis',
          commonName: 'American sycamore',
          scientificName: 'Platanus occidentalis',
          confidence: 0.61,
          genus: 'Platanus',
          family: 'Platanaceae',
        ),
      ],
    );
  }

  @override
  Future<TreeAnalysis> getTreeAnalysis(String analysisId) => analyzeTree(
    TreeAnalysisRequest(
      photos: const [],
      location: _trees.first.location,
      idempotencyKey: analysisId,
    ),
  );

  @override
  Future<List<NearbyTreeCandidate>> findNearbyTrees({
    required GeoCoordinate coordinate,
    required double radiusMeters,
  }) async {
    return _trees
        .map(
          (tree) => (
            tree: tree,
            distance: _location.distanceMeters(
              coordinate.latitude,
              coordinate.longitude,
              tree.location.latitude,
              tree.location.longitude,
            ),
          ),
        )
        .where((item) => item.distance <= radiusMeters)
        .map(
          (item) => NearbyTreeCandidate(
            treeId: item.tree.id,
            displayName: item.tree.displayName,
            scientificName: item.tree.scientificName,
            imageUrl: item.tree.primaryImageUrl,
            distanceMeters: item.distance,
            horizontalAccuracyMeters:
                item.tree.location.horizontalAccuracyMeters,
            registeredAt: item.tree.registeredAt,
          ),
        )
        .toList();
  }

  @override
  Future<TreeRecord> createTree(CreateTreeRequest request) async {
    final existing = _createdByKey[request.idempotencyKey];
    if (existing != null) return existing;
    final isManual = request.manualScientificName?.trim().isNotEmpty == true;
    final tree = TreeRecord(
      id: 'demo-tree-${_trees.length + 1}',
      nickname: request.nickname,
      commonName: isManual ? null : 'Oriental plane',
      scientificName: isManual
          ? request.manualScientificName
          : 'Platanus orientalis',
      primaryImageUrl: request.photos.isEmpty
          ? null
          : request.photos.first.localPath,
      photoUrls: request.photos.map((item) => item.localPath).toList(),
      registeredAt: DateTime.now(),
      location: request.location,
      aiConfidence: isManual ? null : 0.87,
      aiProvider: 'KOK.AI demo fixture',
      identificationSource: isManual ? 'user_corrected' : 'user_confirmed_ai',
      description:
          'A large deciduous tree recognised by its broad crown and patterned bark.',
    );
    _trees.insert(0, tree);
    _createdByKey[request.idempotencyKey] = tree;
    return tree;
  }

  @override
  Future<TreeRecord> getTree(String treeId) async =>
      _trees.firstWhere((item) => item.id == treeId);

  @override
  Future<PaginatedTrees> getTrees(TreeQuery query) async {
    final normalized = query.search?.trim().toLowerCase() ?? '';
    final filtered = _trees.where((tree) {
      if (normalized.isEmpty) return true;
      return tree.displayName.toLowerCase().contains(normalized) ||
          (tree.scientificName?.toLowerCase().contains(normalized) ?? false);
    }).toList();
    return PaginatedTrees(items: filtered, hasMore: false);
  }

  @override
  Future<List<TreeRecord>> getMapTrees(TreeMapQuery query) async =>
      List.unmodifiable(_trees);

  @override
  Future<TreeScan> createTreeScan(CreateTreeScanRequest request) async {
    final scan = TreeScan(
      id: 'demo-scan-${request.idempotencyKey}',
      scannedAt: request.capturedAt ?? DateTime.now(),
      summary: 'Follow-up scan saved in demo mode.',
      imageUrl: request.photos.isEmpty ? null : request.photos.first.localPath,
    );
    _scans.putIfAbsent(request.treeId, () => []).insert(0, scan);
    return scan;
  }

  @override
  Future<List<TreeScan>> getTreeScans(String treeId) async =>
      List.unmodifiable(_scans[treeId] ?? const []);
}
