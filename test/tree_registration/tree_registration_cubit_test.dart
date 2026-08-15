import 'package:flutter_test/flutter_test.dart';
import 'package:kok_ai_app/features/tree_registration/data/services/registration_draft_persistence.dart';
import 'package:kok_ai_app/features/tree_registration/domain/entities/tree_models.dart';
import 'package:kok_ai_app/features/tree_registration/domain/repositories/tree_repository.dart';
import 'package:kok_ai_app/features/tree_registration/presentation/controller/tree_registration_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late _TestRepository repository;
  late TreeRegistrationCubit cubit;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = _TestRepository();
    cubit = TreeRegistrationCubit(
      repository: repository,
      persistence: RegistrationDraftPersistence(),
      clock: () => DateTime(2026, 8, 15, 10),
    );
  });

  tearDown(() => cubit.close());

  test('validates photos and moves through analysis and selection', () async {
    await cubit.start();
    expect(cubit.state.stage, RegistrationStage.photos);
    expect(await cubit.continueFromPhotos(), isFalse);
    expect(cubit.state.errorMessage, isNotNull);

    await cubit.setPhoto(TreePhotoType.wholeTree, '/tmp/whole.jpg');
    await cubit.setPhoto(TreePhotoType.leaf, '/tmp/leaf.jpg');
    expect(await cubit.continueFromPhotos(), isTrue);
    expect(cubit.state.stage, RegistrationStage.location);

    await cubit.setLocation(_evidence());
    await cubit.analyze();
    expect(cubit.state.stage, RegistrationStage.identification);
    expect(cubit.state.selectedCandidateId, 'candidate-1');

    cubit.setManualIdentification('Ulmus pumila');
    expect(cubit.state.selectedCandidateId, isNull);
    expect(cubit.state.manualScientificName, 'Ulmus pumila');
    expect(cubit.state.analysis?.candidates.single.id, 'candidate-1');
  });

  test('retains idempotency key across a failed creation retry', () async {
    await cubit.start();
    await cubit.setPhoto(TreePhotoType.wholeTree, '/tmp/whole.jpg');
    await cubit.setPhoto(TreePhotoType.leaf, '/tmp/leaf.jpg');
    await cubit.continueFromPhotos();
    await cubit.setLocation(_evidence());
    await cubit.analyze();
    await cubit.checkDuplicates();
    cubit.continueAsNewTree();

    repository.failFirstCreate = true;
    await cubit.createTree();
    expect(cubit.state.stage, RegistrationStage.confirmation);
    expect(cubit.state.errorMessage, isNotNull);
    await cubit.createTree();

    expect(repository.creationKeys, hasLength(2));
    expect(repository.creationKeys[0], repository.creationKeys[1]);
    expect(cubit.state.stage, RegistrationStage.success);
  });

  test('restores analysis, user choice, and duplicate review', () async {
    await cubit.start();
    await cubit.setPhoto(TreePhotoType.wholeTree, '/tmp/whole.jpg');
    await cubit.setPhoto(TreePhotoType.leaf, '/tmp/leaf.jpg');
    await cubit.continueFromPhotos();
    await cubit.setLocation(_evidence());
    await cubit.analyze();
    cubit.setManualIdentification('Ulmus pumila');
    await cubit.checkDuplicates();
    cubit.continueAsNewTree();
    await cubit.updateDetails(nickname: 'Library elm', notes: 'North gate');

    final resumed = TreeRegistrationCubit(
      repository: repository,
      persistence: RegistrationDraftPersistence(),
      clock: () => DateTime(2026, 8, 16),
    );
    addTearDown(resumed.close);
    await resumed.restore();

    expect(resumed.state.stage, RegistrationStage.confirmation);
    expect(resumed.state.analysis?.id, 'analysis-1');
    expect(resumed.state.manualScientificName, 'Ulmus pumila');
    expect(resumed.state.selectedCandidateId, isNull);
    expect(
      resumed.state.duplicateCheckStatus,
      DuplicateCheckStatus.noNearbyTrees,
    );
    expect(resumed.state.nickname, 'Library elm');
    expect(resumed.state.idempotencyKey, cubit.state.idempotencyKey);
  });

  test(
    'same-tree choice creates a follow-up scan and clears the draft',
    () async {
      await cubit.start();
      await cubit.setPhoto(TreePhotoType.wholeTree, '/tmp/whole.jpg');
      await cubit.setPhoto(TreePhotoType.leaf, '/tmp/leaf.jpg');
      await cubit.continueFromPhotos();
      await cubit.setLocation(_evidence());
      await cubit.analyze();
      await cubit.checkDuplicates();

      await cubit.addScanToExistingTree('existing-tree');

      expect(cubit.state.stage, RegistrationStage.success);
      expect(cubit.state.createdScan?.id, 'scan-1');
      expect(cubit.state.createdScanTreeId, 'existing-tree');
      expect(repository.scanRequests.single.treeId, 'existing-tree');
      expect(
        repository.scanRequests.single.idempotencyKey,
        contains('-scan-existing-tree'),
      );
      expect(await RegistrationDraftPersistence().load(), isNull);
    },
  );
}

TreeLocationEvidence _evidence() => TreeLocationEvidence(
  latitude: 41.2995,
  longitude: 69.2401,
  horizontalAccuracyMeters: 5.5,
  acceptedSampleCount: 6,
  rejectedSampleCount: 1,
  captureDuration: const Duration(seconds: 12),
  bestSampleAccuracyMeters: 4.2,
  capturedAt: DateTime(2026, 8, 15, 10),
  quality: LocationQuality.acceptable,
);

class _TestRepository implements TreeRepository {
  bool failFirstCreate = false;
  final List<String> creationKeys = [];
  final List<CreateTreeScanRequest> scanRequests = [];

  @override
  Future<TreeAnalysis> analyzeTree(TreeAnalysisRequest request) async =>
      TreeAnalysis(
        id: 'analysis-1',
        candidates: const [
          SpeciesCandidate(
            id: 'candidate-1',
            scientificName: 'Platanus orientalis',
            confidence: .82,
          ),
        ],
        providerName: 'test',
        analyzedAt: DateTime(2026, 8, 15),
      );

  @override
  Future<TreeAnalysis> getTreeAnalysis(String analysisId) => analyzeTree(
    TreeAnalysisRequest(
      photos: const [],
      location: _evidence(),
      idempotencyKey: analysisId,
    ),
  );

  @override
  Future<TreeRecord> createTree(CreateTreeRequest request) async {
    creationKeys.add(request.idempotencyKey);
    if (failFirstCreate && creationKeys.length == 1) throw Exception('timeout');
    return TreeRecord(
      id: 'tree-1',
      registeredAt: DateTime(2026, 8, 15),
      location: request.location,
      identificationSource: 'user_confirmed_ai',
    );
  }

  @override
  Future<List<NearbyTreeCandidate>> findNearbyTrees({
    required GeoCoordinate coordinate,
    required double radiusMeters,
  }) async => const [];

  @override
  Future<TreeRecord> getTree(String treeId) => throw UnimplementedError();

  @override
  Future<List<TreeRecord>> getMapTrees(TreeMapQuery query) async => const [];

  @override
  Future<TreeScan> createTreeScan(CreateTreeScanRequest request) async {
    scanRequests.add(request);
    return TreeScan(id: 'scan-1', scannedAt: DateTime(2026, 8, 15));
  }

  @override
  Future<List<TreeScan>> getTreeScans(String treeId) async => const [];

  @override
  Future<PaginatedTrees> getTrees(TreeQuery query) async =>
      const PaginatedTrees(items: [], hasMore: false);
}
