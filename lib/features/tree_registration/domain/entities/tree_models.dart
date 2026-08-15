enum TreePhotoType {
  wholeTree('whole_tree'),
  leaf('leaf'),
  bark('bark'),
  flowerOrFruit('flower_or_fruit'),
  additional('additional');

  const TreePhotoType(this.apiValue);
  final String apiValue;

  static TreePhotoType fromApi(String? value) => values.firstWhere(
    (item) => item.apiValue == value,
    orElse: () => TreePhotoType.additional,
  );
}

class TreePhotoDraft {
  const TreePhotoDraft({
    required this.localId,
    required this.localPath,
    required this.type,
    required this.capturedAt,
  });

  final String localId;
  final String localPath;
  final TreePhotoType type;
  final DateTime capturedAt;

  Map<String, dynamic> toJson() => {
    'local_id': localId,
    'local_path': localPath,
    'type': type.apiValue,
    'captured_at': capturedAt.toUtc().toIso8601String(),
  };

  factory TreePhotoDraft.fromJson(Map<String, dynamic> json) => TreePhotoDraft(
    localId: '${json['local_id'] ?? ''}',
    localPath: '${json['local_path'] ?? ''}',
    type: TreePhotoType.fromApi(json['type'] as String?),
    capturedAt:
        DateTime.tryParse('${json['captured_at']}')?.toLocal() ??
        DateTime.now(),
  );
}

class GeoCoordinate {
  const GeoCoordinate({required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;
}

class LocationSample {
  const LocationSample({
    required this.latitude,
    required this.longitude,
    required this.horizontalAccuracyMeters,
    required this.recordedAt,
    this.altitudeMeters,
    this.altitudeAccuracyMeters,
  });

  final double latitude;
  final double longitude;
  final double horizontalAccuracyMeters;
  final double? altitudeMeters;
  final double? altitudeAccuracyMeters;
  final DateTime recordedAt;
}

enum LocationQuality {
  excellent('excellent'),
  acceptable('acceptable'),
  poor('poor');

  const LocationQuality(this.apiValue);
  final String apiValue;

  static LocationQuality fromApi(String? value) => values.firstWhere(
    (item) => item.apiValue == value,
    orElse: () => LocationQuality.poor,
  );
}

class TreeLocationEvidence {
  const TreeLocationEvidence({
    required this.latitude,
    required this.longitude,
    required this.horizontalAccuracyMeters,
    required this.acceptedSampleCount,
    required this.rejectedSampleCount,
    required this.captureDuration,
    required this.bestSampleAccuracyMeters,
    required this.capturedAt,
    required this.quality,
  });

  final double latitude;
  final double longitude;
  final double horizontalAccuracyMeters;
  final int acceptedSampleCount;
  final int rejectedSampleCount;
  final Duration captureDuration;
  final double bestSampleAccuracyMeters;
  final DateTime capturedAt;
  final LocationQuality quality;

  GeoCoordinate get coordinate =>
      GeoCoordinate(latitude: latitude, longitude: longitude);

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'horizontal_accuracy_meters': horizontalAccuracyMeters,
    'accepted_sample_count': acceptedSampleCount,
    'rejected_sample_count': rejectedSampleCount,
    'capture_duration_ms': captureDuration.inMilliseconds,
    'best_sample_accuracy_meters': bestSampleAccuracyMeters,
    'captured_at': capturedAt.toUtc().toIso8601String(),
    'quality': quality.apiValue,
  };

  factory TreeLocationEvidence.fromJson(
    Map<String, dynamic> json,
  ) => TreeLocationEvidence(
    latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
    longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
    horizontalAccuracyMeters:
        (json['horizontal_accuracy_meters'] as num?)?.toDouble() ?? 0,
    acceptedSampleCount: (json['accepted_sample_count'] as num?)?.toInt() ?? 0,
    rejectedSampleCount: (json['rejected_sample_count'] as num?)?.toInt() ?? 0,
    captureDuration: Duration(
      milliseconds: (json['capture_duration_ms'] as num?)?.toInt() ?? 0,
    ),
    bestSampleAccuracyMeters:
        (json['best_sample_accuracy_meters'] as num?)?.toDouble() ?? 0,
    capturedAt:
        DateTime.tryParse('${json['captured_at']}')?.toLocal() ??
        DateTime.now(),
    quality: LocationQuality.fromApi(json['quality'] as String?),
  );
}

class SpeciesCandidate {
  const SpeciesCandidate({
    required this.id,
    required this.scientificName,
    required this.confidence,
    this.commonName,
    this.genus,
    this.family,
    this.description,
    this.representativeImageUrl,
    this.imageSourceUrl,
  });

  final String id;
  final String? commonName;
  final String scientificName;
  final double confidence;
  final String? genus;
  final String? family;
  final String? description;
  final String? representativeImageUrl;
  final String? imageSourceUrl;

  String get displayName =>
      commonName?.trim().isNotEmpty == true ? commonName! : scientificName;
}

class TreeHealthAssessment {
  const TreeHealthAssessment({
    required this.status,
    this.confidence,
    this.summary,
  });
  final String status;
  final double? confidence;
  final String? summary;
}

class TreeAnalysis {
  const TreeAnalysis({
    required this.id,
    required this.candidates,
    required this.providerName,
    this.analyzedAt,
    this.status = 'completed',
    this.health,
  });

  final String id;
  final List<SpeciesCandidate> candidates;
  final String providerName;
  final DateTime? analyzedAt;
  final String status;
  final TreeHealthAssessment? health;

  SpeciesCandidate? get topCandidate =>
      candidates.isEmpty ? null : candidates.first;
}

class TreeAnalysisRequest {
  const TreeAnalysisRequest({
    required this.photos,
    required this.location,
    required this.idempotencyKey,
  });
  final List<TreePhotoDraft> photos;
  final TreeLocationEvidence location;
  final String idempotencyKey;
}

class NearbyTreeCandidate {
  const NearbyTreeCandidate({
    required this.treeId,
    required this.distanceMeters,
    required this.registeredAt,
    this.displayName,
    this.scientificName,
    this.imageUrl,
    this.horizontalAccuracyMeters,
  });
  final String treeId;
  final String? displayName;
  final String? scientificName;
  final String? imageUrl;
  final double distanceMeters;
  final double? horizontalAccuracyMeters;
  final DateTime registeredAt;
}

enum DuplicateCheckStatus {
  noNearbyTrees,
  possibleMatches,
  skippedDueToNetworkFailure,
}

class CreateTreeRequest {
  const CreateTreeRequest({
    required this.analysisId,
    required this.photos,
    required this.location,
    required this.idempotencyKey,
    required this.duplicateCheckStatus,
    this.selectedCandidateId,
    this.manualScientificName,
    this.nickname,
    this.notes,
    this.visibility = 'private',
  });

  final String analysisId;
  final List<TreePhotoDraft> photos;
  final TreeLocationEvidence location;
  final String idempotencyKey;
  final DuplicateCheckStatus duplicateCheckStatus;
  final String? selectedCandidateId;
  final String? manualScientificName;
  final String? nickname;
  final String? notes;
  final String visibility;
}

class TreeRecord {
  const TreeRecord({
    required this.id,
    required this.registeredAt,
    required this.location,
    required this.identificationSource,
    this.commonName,
    this.scientificName,
    this.nickname,
    this.primaryImageUrl,
    this.photoUrls = const [],
    this.photos = const [],
    this.aiConfidence,
    this.aiProvider,
    this.lastScannedAt,
    this.description,
    this.health,
    this.ownerId,
    this.notes,
    this.visibility = 'unknown',
  });

  final String id;
  final String? commonName;
  final String? scientificName;
  final String? nickname;
  final String? primaryImageUrl;
  final List<String> photoUrls;
  final List<TreePhoto> photos;
  final DateTime registeredAt;
  final DateTime? lastScannedAt;
  final TreeLocationEvidence location;
  final double? aiConfidence;
  final String? aiProvider;
  final String identificationSource;
  final String? description;
  final TreeHealthAssessment? health;
  final String? ownerId;
  final String? notes;
  final String visibility;

  String get displayName => nickname?.trim().isNotEmpty == true
      ? nickname!
      : commonName?.trim().isNotEmpty == true
      ? commonName!
      : scientificName?.trim().isNotEmpty == true
      ? scientificName!
      : 'Unidentified tree';
}

class TreePhoto {
  const TreePhoto({required this.type, required this.url});

  final String type;
  final String url;
}

class TreeScan {
  const TreeScan({
    required this.id,
    required this.scannedAt,
    this.summary,
    this.imageUrl,
  });
  final String id;
  final DateTime scannedAt;
  final String? summary;
  final String? imageUrl;
}

class CreateTreeScanRequest {
  const CreateTreeScanRequest({
    required this.treeId,
    required this.photos,
    required this.idempotencyKey,
    this.location,
    this.capturedAt,
    this.notes,
  });

  final String treeId;
  final List<TreePhotoDraft> photos;
  final String idempotencyKey;
  final TreeLocationEvidence? location;
  final DateTime? capturedAt;
  final String? notes;
}

class TreeMapQuery {
  const TreeMapQuery({this.bbox, this.center, this.radius, this.status});

  final String? bbox;
  final String? center;
  final double? radius;
  final String? status;
}

class TreeQuery {
  const TreeQuery({
    this.cursor,
    this.limit = 20,
    this.search,
    this.sort = 'newest',
    this.species,
    this.coordinate,
  });
  final String? cursor;
  final int limit;
  final String? search;
  final String sort;
  final String? species;
  final GeoCoordinate? coordinate;
}

class PaginatedTrees {
  const PaginatedTrees({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });
  final List<TreeRecord> items;
  final String? nextCursor;
  final bool hasMore;
}
