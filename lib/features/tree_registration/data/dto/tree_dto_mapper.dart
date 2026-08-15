import 'package:kok_ai_app/core/network/api_config.dart';
import 'package:kok_ai_app/features/tree_registration/domain/entities/tree_models.dart';

abstract final class TreeDtoMapper {
  static TreeAnalysis analysis(Map<String, dynamic> json) {
    final rawCandidates = json['candidates'] as List? ?? const [];
    final healthJson = json['health'] as Map<String, dynamic>?;
    return TreeAnalysis(
      id: '${json['id'] ?? json['analysis_id'] ?? ''}',
      candidates: rawCandidates
          .whereType<Map>()
          .map((item) => candidate(Map<String, dynamic>.from(item)))
          .toList(),
      providerName: '${json['provider'] ?? json['provider_name'] ?? 'KOK.AI'}',
      analyzedAt: DateTime.tryParse('${json['analyzed_at']}')?.toLocal(),
      status: '${json['status'] ?? 'completed'}',
      health: healthJson == null
          ? null
          : TreeHealthAssessment(
              status: '${healthJson['status'] ?? 'unknown'}',
              confidence: (healthJson['confidence'] as num?)?.toDouble(),
              summary: healthJson['summary'] as String?,
            ),
    );
  }

  static SpeciesCandidate candidate(Map<String, dynamic> json) {
    final scientificName = json['scientific_name'] as String?;
    if (scientificName == null || scientificName.trim().isEmpty) {
      throw const FormatException('Candidate scientific_name is required');
    }
    return SpeciesCandidate(
      id: '${json['id'] ?? json['candidate_id'] ?? ''}',
      commonName: json['common_name'] as String?,
      scientificName: scientificName,
      confidence: ((json['confidence'] as num?)?.toDouble() ?? 0).clamp(0, 1),
      genus: json['genus'] as String?,
      family: json['family'] as String?,
      description: json['description'] as String?,
      representativeImageUrl: ApiConfig.normalizeAssetUrl(
        json['representative_image_url'] as String?,
      ),
      imageSourceUrl: json['image_source_url'] as String?,
    );
  }

  static NearbyTreeCandidate nearby(Map<String, dynamic> json) =>
      NearbyTreeCandidate(
        treeId: '${json['tree_id'] ?? json['id'] ?? ''}',
        displayName:
            json['display_name'] as String? ?? json['common_name'] as String?,
        scientificName: json['scientific_name'] as String?,
        imageUrl: ApiConfig.normalizeAssetUrl(json['image_url'] as String?),
        distanceMeters: (json['distance_meters'] as num?)?.toDouble() ?? 0,
        horizontalAccuracyMeters: (json['horizontal_accuracy_meters'] as num?)
            ?.toDouble(),
        registeredAt:
            DateTime.tryParse('${json['registered_at']}')?.toLocal() ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );

  static TreeRecord tree(Map<String, dynamic> json) {
    final location = Map<String, dynamic>.from(
      json['location'] as Map? ?? const <String, dynamic>{},
    );
    final identification = Map<String, dynamic>.from(
      json['identification'] as Map? ?? const <String, dynamic>{},
    );
    final healthJson = json['health'] as Map<String, dynamic>?;
    final rawPhotos = json['photos'] as List? ?? const [];
    final photos = rawPhotos
        .map((item) {
          if (item is String) {
            final url = ApiConfig.normalizeAssetUrl(item);
            return url == null ? null : TreePhoto(type: 'unknown', url: url);
          }
          if (item is Map) {
            final url = ApiConfig.normalizeAssetUrl(item['url'] as String?);
            if (url == null) return null;
            return TreePhoto(type: '${item['type'] ?? 'unknown'}', url: url);
          }
          return null;
        })
        .whereType<TreePhoto>()
        .toList();
    final photoUrls = photos.map((item) => item.url).toList();
    final primaryImage =
        ApiConfig.normalizeAssetUrl(json['primary_image_url'] as String?) ??
        (photoUrls.isEmpty ? null : photoUrls.first);

    return TreeRecord(
      id: '${json['id'] ?? ''}',
      commonName:
          identification['common_name'] as String? ??
          json['common_name'] as String?,
      scientificName:
          identification['scientific_name'] as String? ??
          json['scientific_name'] as String?,
      nickname: json['nickname'] as String? ?? json['name'] as String?,
      primaryImageUrl: primaryImage,
      photoUrls: photoUrls,
      photos: photos,
      registeredAt:
          DateTime.tryParse(
            '${json['registered_at'] ?? json['created_at']}',
          )?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      lastScannedAt: DateTime.tryParse('${json['last_scanned_at']}')?.toLocal(),
      location: TreeLocationEvidence(
        latitude: (location['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (location['longitude'] as num?)?.toDouble() ?? 0,
        horizontalAccuracyMeters:
            (location['horizontal_accuracy_meters'] as num?)?.toDouble() ??
            (location['accuracy_meters'] as num?)?.toDouble() ??
            0,
        acceptedSampleCount:
            (location['accepted_sample_count'] as num?)?.toInt() ?? 0,
        rejectedSampleCount:
            (location['rejected_sample_count'] as num?)?.toInt() ?? 0,
        captureDuration: Duration(
          milliseconds: (location['capture_duration_ms'] as num?)?.toInt() ?? 0,
        ),
        bestSampleAccuracyMeters:
            (location['best_sample_accuracy_meters'] as num?)?.toDouble() ??
            (location['horizontal_accuracy_meters'] as num?)?.toDouble() ??
            0,
        capturedAt:
            DateTime.tryParse('${location['captured_at']}')?.toLocal() ??
            DateTime.fromMillisecondsSinceEpoch(0),
        quality: LocationQuality.fromApi(location['quality'] as String?),
      ),
      aiConfidence: (identification['ai_confidence'] as num?)?.toDouble(),
      aiProvider: identification['ai_provider'] as String?,
      identificationSource: '${identification['source'] ?? 'unknown'}',
      description: identification['description'] as String?,
      health: healthJson == null
          ? null
          : TreeHealthAssessment(
              status: '${healthJson['status'] ?? 'unknown'}',
              confidence: (healthJson['confidence'] as num?)?.toDouble(),
              summary: healthJson['summary'] as String?,
            ),
      ownerId: json['owner_id'] as String?,
      notes: json['notes'] as String?,
      visibility: '${json['visibility'] ?? 'unknown'}',
    );
  }

  static TreeScan scan(Map<String, dynamic> json) => TreeScan(
    id: '${json['id'] ?? ''}',
    scannedAt:
        DateTime.tryParse(
          '${json['scanned_at'] ?? json['created_at']}',
        )?.toLocal() ??
        DateTime.fromMillisecondsSinceEpoch(0),
    summary: json['summary'] as String?,
    imageUrl: ApiConfig.normalizeAssetUrl(json['image_url'] as String?),
  );
}
