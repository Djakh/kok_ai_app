import 'package:flutter_test/flutter_test.dart';
import 'package:kok_ai_app/features/tree_registration/domain/entities/tree_models.dart';
import 'package:kok_ai_app/features/tree_registration/domain/services/location_quality_service.dart';

void main() {
  const service = LocationQualityService();
  final now = DateTime(2026, 8, 15, 10);

  LocationSample sample(
    double latitude,
    double longitude,
    double accuracy, [
    int seconds = 0,
  ]) => LocationSample(
    latitude: latitude,
    longitude: longitude,
    horizontalAccuracyMeters: accuracy,
    recordedAt: now.add(Duration(seconds: seconds)),
  );

  test('rejects invalid coordinates and nonsensical accuracy', () {
    expect(service.isValid(sample(91, 69, 4)), isFalse);
    expect(service.isValid(sample(41, 181, 4)), isFalse);
    expect(service.isValid(sample(41, 69, 0)), isFalse);
    expect(service.isValid(sample(41, 69, 500)), isFalse);
    expect(service.isValid(sample(41, 69, 4)), isTrue);
  });

  test('removes a geographic outlier and calculates a robust coordinate', () {
    final evidence = service.calculate([
      sample(41.299500, 69.240100, 5, 0),
      sample(41.299510, 69.240105, 4, 2),
      sample(41.299495, 69.240090, 6, 4),
      sample(41.310000, 69.250000, 3, 6),
    ]);

    expect(evidence.acceptedSampleCount, 3);
    expect(evidence.rejectedSampleCount, 1);
    expect(evidence.latitude, closeTo(41.299503, 0.00002));
    expect(evidence.longitude, closeTo(69.240100, 0.00002));
    expect(evidence.captureDuration, const Duration(seconds: 6));
  });

  test('accuracy weighting prefers good readings without one dominating', () {
    final evidence = service.calculate([
      sample(41.000000, 69.000000, .1),
      sample(41.000010, 69.000010, 5),
      sample(41.000020, 69.000020, 5),
    ]);

    expect(evidence.latitude, greaterThan(41.000000));
    expect(evidence.latitude, lessThan(41.000010));
    expect(evidence.bestSampleAccuracyMeters, .1);
  });

  test('classifies configurable UX accuracy bands', () {
    expect(service.classify(5), LocationQuality.excellent);
    expect(service.classify(5.1), LocationQuality.acceptable);
    expect(service.classify(10), LocationQuality.acceptable);
    expect(service.classify(10.1), LocationQuality.poor);
  });

  test('throws for empty and insufficient accepted samples', () {
    expect(
      () => service.calculate([]),
      throwsA(isA<InsufficientLocationSamples>()),
    );
    expect(
      () => service.calculate([sample(41, 69, 4), sample(41, 69, 5)]),
      throwsA(isA<InsufficientLocationSamples>()),
    );
  });
}
