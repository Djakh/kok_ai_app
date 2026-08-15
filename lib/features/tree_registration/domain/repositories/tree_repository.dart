import 'package:kok_ai_app/features/tree_registration/domain/entities/tree_models.dart';

abstract interface class TreeRepository {
  Future<TreeAnalysis> analyzeTree(TreeAnalysisRequest request);
  Future<TreeAnalysis> getTreeAnalysis(String analysisId);

  Future<List<NearbyTreeCandidate>> findNearbyTrees({
    required GeoCoordinate coordinate,
    required double radiusMeters,
  });

  Future<TreeRecord> createTree(CreateTreeRequest request);
  Future<TreeRecord> getTree(String treeId);
  Future<PaginatedTrees> getTrees(TreeQuery query);
  Future<List<TreeRecord>> getMapTrees(TreeMapQuery query);
  Future<TreeScan> createTreeScan(CreateTreeScanRequest request);
  Future<List<TreeScan>> getTreeScans(String treeId);
}
