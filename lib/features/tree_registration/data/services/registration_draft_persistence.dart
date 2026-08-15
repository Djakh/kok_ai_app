import 'dart:convert';

import 'package:kok_ai_app/features/tree_registration/domain/entities/tree_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersistedRegistrationDraft {
  const PersistedRegistrationDraft({
    required this.draftId,
    required this.idempotencyKey,
    required this.photos,
    required this.stageIndex,
    this.location,
    this.analysis,
    this.selectedCandidateId,
    this.manualScientificName,
    this.nearbyTrees = const [],
    this.duplicateCheckStatus,
    this.nickname,
    this.notes,
    this.visibility = 'private',
  });

  final String draftId;
  final String idempotencyKey;
  final List<TreePhotoDraft> photos;
  final int stageIndex;
  final TreeLocationEvidence? location;
  final TreeAnalysis? analysis;
  final String? selectedCandidateId;
  final String? manualScientificName;
  final List<NearbyTreeCandidate> nearbyTrees;
  final DuplicateCheckStatus? duplicateCheckStatus;
  final String? nickname;
  final String? notes;
  final String visibility;

  Map<String, dynamic> toJson() => {
    'draft_id': draftId,
    'idempotency_key': idempotencyKey,
    'photos': photos.map((item) => item.toJson()).toList(),
    'stage_index': stageIndex,
    'location': location?.toJson(),
    'analysis': analysis == null ? null : _analysisToJson(analysis!),
    'selected_candidate_id': selectedCandidateId,
    'manual_scientific_name': manualScientificName,
    'nearby_trees': nearbyTrees.map(_nearbyToJson).toList(),
    'duplicate_check_status': duplicateCheckStatus?.name,
    'nickname': nickname,
    'notes': notes,
    'visibility': visibility,
  };

  factory PersistedRegistrationDraft.fromJson(
    Map<String, dynamic> json,
  ) => PersistedRegistrationDraft(
    draftId: '${json['draft_id'] ?? ''}',
    idempotencyKey: '${json['idempotency_key'] ?? ''}',
    photos: (json['photos'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => TreePhotoDraft.fromJson(Map<String, dynamic>.from(item)))
        .toList(),
    stageIndex: (json['stage_index'] as num?)?.toInt() ?? 0,
    location: json['location'] is Map
        ? TreeLocationEvidence.fromJson(
            Map<String, dynamic>.from(json['location'] as Map),
          )
        : null,
    analysis: json['analysis'] is Map
        ? _analysisFromJson(Map<String, dynamic>.from(json['analysis'] as Map))
        : null,
    selectedCandidateId: json['selected_candidate_id'] as String?,
    manualScientificName: json['manual_scientific_name'] as String?,
    nearbyTrees: (json['nearby_trees'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => _nearbyFromJson(Map<String, dynamic>.from(item)))
        .toList(),
    duplicateCheckStatus: _duplicateStatus(
      json['duplicate_check_status'] as String?,
    ),
    nickname: json['nickname'] as String?,
    notes: json['notes'] as String?,
    visibility: const {'public', 'private'}.contains(json['visibility'])
        ? '${json['visibility']}'
        : 'private',
  );

  static Map<String, dynamic> _analysisToJson(TreeAnalysis value) => {
    'id': value.id,
    'provider': value.providerName,
    'status': value.status,
    'analyzed_at': value.analyzedAt?.toUtc().toIso8601String(),
    'candidates': value.candidates
        .map(
          (item) => {
            'id': item.id,
            'common_name': item.commonName,
            'scientific_name': item.scientificName,
            'confidence': item.confidence,
            'genus': item.genus,
            'family': item.family,
            'description': item.description,
            'representative_image_url': item.representativeImageUrl,
            'image_source_url': item.imageSourceUrl,
          },
        )
        .toList(),
    'health': value.health == null
        ? null
        : {
            'status': value.health!.status,
            'confidence': value.health!.confidence,
            'summary': value.health!.summary,
          },
  };

  static TreeAnalysis _analysisFromJson(Map<String, dynamic> json) =>
      TreeAnalysis(
        id: '${json['id'] ?? ''}',
        providerName: '${json['provider'] ?? 'KOK.AI'}',
        status: '${json['status'] ?? 'completed'}',
        analyzedAt: DateTime.tryParse('${json['analyzed_at']}')?.toLocal(),
        candidates: (json['candidates'] as List? ?? const [])
            .whereType<Map>()
            .map((item) {
              final value = Map<String, dynamic>.from(item);
              return SpeciesCandidate(
                id: '${value['id'] ?? ''}',
                commonName: value['common_name'] as String?,
                scientificName: '${value['scientific_name'] ?? ''}',
                confidence:
                    (value['confidence'] as num?)
                        ?.toDouble()
                        .clamp(0.0, 1.0)
                        .toDouble() ??
                    0,
                genus: value['genus'] as String?,
                family: value['family'] as String?,
                description: value['description'] as String?,
                representativeImageUrl:
                    value['representative_image_url'] as String?,
                imageSourceUrl: value['image_source_url'] as String?,
              );
            })
            .toList(),
        health: json['health'] is Map
            ? _healthFromJson(Map<String, dynamic>.from(json['health'] as Map))
            : null,
      );

  static TreeHealthAssessment _healthFromJson(Map<String, dynamic> json) =>
      TreeHealthAssessment(
        status: '${json['status'] ?? 'unknown'}',
        confidence: (json['confidence'] as num?)?.toDouble(),
        summary: json['summary'] as String?,
      );

  static Map<String, dynamic> _nearbyToJson(NearbyTreeCandidate value) => {
    'tree_id': value.treeId,
    'display_name': value.displayName,
    'scientific_name': value.scientificName,
    'image_url': value.imageUrl,
    'distance_meters': value.distanceMeters,
    'horizontal_accuracy_meters': value.horizontalAccuracyMeters,
    'registered_at': value.registeredAt.toUtc().toIso8601String(),
  };

  static NearbyTreeCandidate _nearbyFromJson(Map<String, dynamic> json) =>
      NearbyTreeCandidate(
        treeId: '${json['tree_id'] ?? ''}',
        displayName: json['display_name'] as String?,
        scientificName: json['scientific_name'] as String?,
        imageUrl: json['image_url'] as String?,
        distanceMeters: (json['distance_meters'] as num?)?.toDouble() ?? 0,
        horizontalAccuracyMeters: (json['horizontal_accuracy_meters'] as num?)
            ?.toDouble(),
        registeredAt:
            DateTime.tryParse('${json['registered_at']}')?.toLocal() ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );

  static DuplicateCheckStatus? _duplicateStatus(String? value) {
    for (final status in DuplicateCheckStatus.values) {
      if (status.name == value) return status;
    }
    return null;
  }
}

class RegistrationDraftPersistence {
  static const _key = 'kokai_tree_registration_draft_v2';

  Future<void> save(PersistedRegistrationDraft draft) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, jsonEncode(draft.toJson()));
  }

  Future<PersistedRegistrationDraft?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_key);
    if (encoded == null || encoded.isEmpty) return null;
    try {
      return PersistedRegistrationDraft.fromJson(
        Map<String, dynamic>.from(jsonDecode(encoded) as Map),
      );
    } catch (_) {
      await preferences.remove(_key);
      return null;
    }
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key);
  }
}
