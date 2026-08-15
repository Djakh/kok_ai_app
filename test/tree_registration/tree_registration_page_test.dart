import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kok_ai_app/assets/themes/theme.dart';
import 'package:kok_ai_app/features/tree_registration/data/services/registration_draft_persistence.dart';
import 'package:kok_ai_app/features/tree_registration/domain/entities/tree_models.dart';
import 'package:kok_ai_app/features/tree_registration/domain/repositories/tree_repository.dart';
import 'package:kok_ai_app/features/tree_registration/presentation/controller/tree_registration_cubit.dart';
import 'package:kok_ai_app/features/tree_registration/presentation/pages/tree_registration_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('introduction opens guided photos and shows validation', (
    tester,
  ) async {
    final cubit = _cubit(_WidgetRepository());
    addTearDown(cubit.close);
    await tester.pumpWidget(_app(cubit));

    expect(find.text('One tree. Clear evidence.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('start-registration')));
    await tester.pumpAndSettle();
    expect(find.text('Guided photos'), findsOneWidget);
    expect(find.text('Whole tree'), findsOneWidget);
    expect(find.text('Leaf or needles'), findsOneWidget);

    await tester.tap(find.byKey(const Key('continue-from-photos')));
    await tester.pumpAndSettle();
    expect(
      find.text('Add a whole-tree and leaf photo to continue.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'renders analysis, identification, duplicate, confirmation and success states',
    (tester) async {
      final repository = _WidgetRepository();
      final cubit = _cubit(repository);
      addTearDown(cubit.close);
      await cubit.start();
      await cubit.setPhoto(TreePhotoType.wholeTree, '/missing/whole.jpg');
      await cubit.setPhoto(TreePhotoType.leaf, '/missing/leaf.jpg');
      await cubit.continueFromPhotos();
      await cubit.setLocation(_evidence());

      final analysisFuture = cubit.analyze();
      await tester.pumpWidget(_app(cubit));
      expect(find.text('Tree analysis'), findsOneWidget);
      expect(find.text('Uploading photographs'), findsOneWidget);
      expect(find.textContaining('No percentage is shown'), findsOneWidget);

      repository.analysis.complete(_analysis());
      await analysisFuture;
      await tester.pump();
      expect(find.text('Review identification'), findsOneWidget);
      expect(find.text('Oriental plane'), findsOneWidget);
      expect(find.textContaining('AI-generated suggestion'), findsOneWidget);

      await cubit.checkDuplicates();
      await tester.pump();
      expect(find.text('Nearby tree check'), findsOneWidget);
      expect(find.textContaining('possible match'), findsOneWidget);
      expect(find.text('Same tree'), findsOneWidget);

      await tester.tap(find.byKey(const Key('continue-as-new-tree')));
      await tester.pump();
      expect(find.text('Confirm registration'), findsOneWidget);
      expect(find.text('Review the evidence'), findsOneWidget);

      await tester.tap(find.byKey(const Key('confirm-create-tree')));
      await tester.pumpAndSettle();
      expect(find.text('Tree registered'), findsWidgets);
      expect(find.text('View tree'), findsOneWidget);
      expect(find.text('View on map'), findsOneWidget);
    },
  );
}

Widget _app(TreeRegistrationCubit cubit) => MaterialApp(
  theme: AppTheme.light(),
  home: TreeRegistrationPage(cubit: cubit),
);

TreeRegistrationCubit _cubit(TreeRepository repository) =>
    TreeRegistrationCubit(
      repository: repository,
      persistence: RegistrationDraftPersistence(),
      clock: () => DateTime(2026, 8, 15, 10),
    );

TreeLocationEvidence _evidence() => TreeLocationEvidence(
  latitude: 41.2995,
  longitude: 69.2401,
  horizontalAccuracyMeters: 5.5,
  acceptedSampleCount: 7,
  rejectedSampleCount: 1,
  captureDuration: const Duration(seconds: 12),
  bestSampleAccuracyMeters: 4.1,
  capturedAt: DateTime(2026, 8, 15, 10),
  quality: LocationQuality.acceptable,
);

TreeAnalysis _analysis() => TreeAnalysis(
  id: 'analysis-1',
  candidates: const [
    SpeciesCandidate(
      id: 'candidate-1',
      commonName: 'Oriental plane',
      scientificName: 'Platanus orientalis',
      confidence: .87,
    ),
  ],
  providerName: 'test provider',
  analyzedAt: DateTime(2026, 8, 15),
);

class _WidgetRepository implements TreeRepository {
  final Completer<TreeAnalysis> analysis = Completer<TreeAnalysis>();

  @override
  Future<TreeAnalysis> analyzeTree(TreeAnalysisRequest request) =>
      analysis.future;

  @override
  Future<TreeAnalysis> getTreeAnalysis(String analysisId) => analysis.future;

  @override
  Future<TreeRecord> createTree(CreateTreeRequest request) async => TreeRecord(
    id: 'tree-1',
    commonName: 'Oriental plane',
    scientificName: 'Platanus orientalis',
    registeredAt: DateTime(2026, 8, 15),
    location: request.location,
    identificationSource: 'user_confirmed_ai',
  );

  @override
  Future<List<NearbyTreeCandidate>> findNearbyTrees({
    required GeoCoordinate coordinate,
    required double radiusMeters,
  }) async => [
    NearbyTreeCandidate(
      treeId: 'existing-1',
      displayName: 'Nearby plane',
      distanceMeters: 4.2,
      registeredAt: DateTime(2026, 8, 1),
    ),
  ];

  @override
  Future<TreeRecord> getTree(String treeId) => throw UnimplementedError();

  @override
  Future<List<TreeRecord>> getMapTrees(TreeMapQuery query) async => const [];

  @override
  Future<TreeScan> createTreeScan(CreateTreeScanRequest request) async =>
      TreeScan(id: 'scan-1', scannedAt: DateTime(2026, 8, 15));

  @override
  Future<List<TreeScan>> getTreeScans(String treeId) async => const [];

  @override
  Future<PaginatedTrees> getTrees(TreeQuery query) async =>
      const PaginatedTrees(items: [], hasMore: false);
}
