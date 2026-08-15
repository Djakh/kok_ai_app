import 'dart:math' as math;

import 'package:kok_ai_app/features/tree_registration/domain/entities/tree_models.dart';

class LocationQualityConfig {
  const LocationQualityConfig({
    this.excellentMeters = 5,
    this.acceptableMeters = 10,
    this.maximumAcceptedAccuracyMeters = 80,
    this.minimumSamples = 3,
    this.outlierFloorMeters = 12,
  });

  final double excellentMeters;
  final double acceptableMeters;
  final double maximumAcceptedAccuracyMeters;
  final int minimumSamples;
  final double outlierFloorMeters;
}

class InsufficientLocationSamples implements Exception {
  const InsufficientLocationSamples(this.acceptedCount);
  final int acceptedCount;
}

class LocationQualityService {
  const LocationQualityService({this.config = const LocationQualityConfig()});
  final LocationQualityConfig config;

  bool isValid(LocationSample sample) {
    return sample.latitude.isFinite &&
        sample.longitude.isFinite &&
        sample.latitude >= -90 &&
        sample.latitude <= 90 &&
        sample.longitude >= -180 &&
        sample.longitude <= 180 &&
        sample.horizontalAccuracyMeters.isFinite &&
        sample.horizontalAccuracyMeters > 0 &&
        sample.horizontalAccuracyMeters <= config.maximumAcceptedAccuracyMeters;
  }

  LocationQuality classify(double accuracyMeters) {
    if (accuracyMeters <= config.excellentMeters) {
      return LocationQuality.excellent;
    }
    if (accuracyMeters <= config.acceptableMeters) {
      return LocationQuality.acceptable;
    }
    return LocationQuality.poor;
  }

  TreeLocationEvidence calculate(
    List<LocationSample> samples, {
    Duration? captureDuration,
  }) {
    final valid = samples.where(isValid).toList();
    if (valid.length < config.minimumSamples) {
      throw InsufficientLocationSamples(valid.length);
    }

    final medianLat = _median(valid.map((item) => item.latitude).toList());
    final medianLng = _median(valid.map((item) => item.longitude).toList());
    final medianAccuracy = _median(
      valid.map((item) => item.horizontalAccuracyMeters).toList(),
    );
    final outlierRadius = math.max(
      config.outlierFloorMeters,
      medianAccuracy * 2.5,
    );

    final accepted = valid.where((item) {
      return distanceMeters(
            item.latitude,
            item.longitude,
            medianLat,
            medianLng,
          ) <=
          outlierRadius;
    }).toList();

    if (accepted.length < config.minimumSamples) {
      throw InsufficientLocationSamples(accepted.length);
    }

    // Accuracy is capped at one metre for weighting so a single optimistic
    // receiver reading cannot dominate the final coordinate.
    var weightTotal = 0.0;
    var weightedLatitude = 0.0;
    var weightedLongitude = 0.0;
    for (final sample in accepted) {
      final safeAccuracy = math.max(1, sample.horizontalAccuracyMeters);
      final weight = 1 / (safeAccuracy * safeAccuracy);
      weightTotal += weight;
      weightedLatitude += sample.latitude * weight;
      weightedLongitude += sample.longitude * weight;
    }

    final finalLatitude = weightedLatitude / weightTotal;
    final finalLongitude = weightedLongitude / weightTotal;
    final bestAccuracy = accepted
        .map((item) => item.horizontalAccuracyMeters)
        .reduce(math.min);
    final spread = accepted
        .map(
          (item) => distanceMeters(
            item.latitude,
            item.longitude,
            finalLatitude,
            finalLongitude,
          ),
        )
        .fold<double>(0, math.max);
    final calculatedAccuracy = math.max(bestAccuracy, spread);
    final ordered = [...samples]
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    final measuredDuration =
        captureDuration ??
        ordered.last.recordedAt.difference(ordered.first.recordedAt);

    return TreeLocationEvidence(
      latitude: finalLatitude,
      longitude: finalLongitude,
      horizontalAccuracyMeters: calculatedAccuracy,
      acceptedSampleCount: accepted.length,
      rejectedSampleCount: samples.length - accepted.length,
      captureDuration: measuredDuration,
      bestSampleAccuracyMeters: bestAccuracy,
      capturedAt: accepted.last.recordedAt,
      quality: classify(calculatedAccuracy),
    );
  }

  double distanceMeters(double lat1, double lng1, double lat2, double lng2) {
    const earthRadius = 6371000.0;
    final dLat = _radians(lat2 - lat1);
    final dLng = _radians(lng2 - lng1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_radians(lat1)) *
            math.cos(_radians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return earthRadius * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _median(List<double> values) {
    values.sort();
    final middle = values.length ~/ 2;
    if (values.length.isOdd) return values[middle];
    return (values[middle - 1] + values[middle]) / 2;
  }

  double _radians(double degrees) => degrees * math.pi / 180;
}
