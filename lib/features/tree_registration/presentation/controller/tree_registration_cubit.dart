import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kok_ai_app/core/network/api_exception.dart';
import 'package:kok_ai_app/features/tree_registration/data/services/registration_draft_persistence.dart';
import 'package:kok_ai_app/features/tree_registration/domain/entities/tree_models.dart';
import 'package:kok_ai_app/features/tree_registration/domain/repositories/tree_repository.dart';

enum RegistrationStage {
  introduction,
  photos,
  location,
  analysis,
  identification,
  duplicates,
  confirmation,
  success,
}

class TreeRegistrationState {
  const TreeRegistrationState({
    required this.draftId,
    required this.idempotencyKey,
    this.stage = RegistrationStage.introduction,
    this.photos = const [],
    this.location,
    this.analysis,
    this.selectedCandidateId,
    this.manualScientificName,
    this.nearbyTrees = const [],
    this.duplicateCheckStatus,
    this.nickname,
    this.notes,
    this.visibility = 'private',
    this.createdTree,
    this.createdScan,
    this.createdScanTreeId,
    this.isBusy = false,
    this.errorMessage,
    this.resumed = false,
  });

  final String draftId;
  final String idempotencyKey;
  final RegistrationStage stage;
  final List<TreePhotoDraft> photos;
  final TreeLocationEvidence? location;
  final TreeAnalysis? analysis;
  final String? selectedCandidateId;
  final String? manualScientificName;
  final List<NearbyTreeCandidate> nearbyTrees;
  final DuplicateCheckStatus? duplicateCheckStatus;
  final String? nickname;
  final String? notes;
  final String visibility;
  final TreeRecord? createdTree;
  final TreeScan? createdScan;
  final String? createdScanTreeId;
  final bool isBusy;
  final String? errorMessage;
  final bool resumed;

  bool get hasMinimumPhotos {
    final types = photos.map((item) => item.type).toSet();
    return types.contains(TreePhotoType.wholeTree) &&
        types.contains(TreePhotoType.leaf);
  }

  SpeciesCandidate? get selectedCandidate {
    final id = selectedCandidateId;
    if (id == null || analysis == null) return null;
    for (final item in analysis!.candidates) {
      if (item.id == id) return item;
    }
    return null;
  }

  TreeRegistrationState copyWith({
    RegistrationStage? stage,
    List<TreePhotoDraft>? photos,
    Object? location = _unset,
    Object? analysis = _unset,
    Object? selectedCandidateId = _unset,
    Object? manualScientificName = _unset,
    List<NearbyTreeCandidate>? nearbyTrees,
    Object? duplicateCheckStatus = _unset,
    String? nickname,
    String? notes,
    String? visibility,
    Object? createdTree = _unset,
    Object? createdScan = _unset,
    Object? createdScanTreeId = _unset,
    bool? isBusy,
    Object? errorMessage = _unset,
    bool? resumed,
  }) => TreeRegistrationState(
    draftId: draftId,
    idempotencyKey: idempotencyKey,
    stage: stage ?? this.stage,
    photos: photos ?? this.photos,
    location: identical(location, _unset)
        ? this.location
        : location as TreeLocationEvidence?,
    analysis: identical(analysis, _unset)
        ? this.analysis
        : analysis as TreeAnalysis?,
    selectedCandidateId: identical(selectedCandidateId, _unset)
        ? this.selectedCandidateId
        : selectedCandidateId as String?,
    manualScientificName: identical(manualScientificName, _unset)
        ? this.manualScientificName
        : manualScientificName as String?,
    nearbyTrees: nearbyTrees ?? this.nearbyTrees,
    duplicateCheckStatus: identical(duplicateCheckStatus, _unset)
        ? this.duplicateCheckStatus
        : duplicateCheckStatus as DuplicateCheckStatus?,
    nickname: nickname ?? this.nickname,
    notes: notes ?? this.notes,
    visibility: visibility ?? this.visibility,
    createdTree: identical(createdTree, _unset)
        ? this.createdTree
        : createdTree as TreeRecord?,
    createdScan: identical(createdScan, _unset)
        ? this.createdScan
        : createdScan as TreeScan?,
    createdScanTreeId: identical(createdScanTreeId, _unset)
        ? this.createdScanTreeId
        : createdScanTreeId as String?,
    isBusy: isBusy ?? this.isBusy,
    errorMessage: identical(errorMessage, _unset)
        ? this.errorMessage
        : errorMessage as String?,
    resumed: resumed ?? this.resumed,
  );
}

const _unset = Object();

class TreeRegistrationCubit extends Cubit<TreeRegistrationState> {
  TreeRegistrationCubit({
    required this.repository,
    required this.persistence,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       super(_newState(clock ?? DateTime.now));

  final TreeRepository repository;
  final RegistrationDraftPersistence persistence;
  final DateTime Function() _clock;

  static TreeRegistrationState _newState(DateTime Function() clock) {
    final now = clock();
    final entropy = Random().nextInt(1 << 32).toRadixString(16);
    final id = '${now.microsecondsSinceEpoch}-$entropy';
    return TreeRegistrationState(draftId: id, idempotencyKey: 'tree-$id');
  }

  Future<void> restore() async {
    final draft = await persistence.load();
    if (draft == null || draft.draftId.isEmpty) return;
    var safeStage = draft.stageIndex.clamp(
      0,
      RegistrationStage.confirmation.index,
    );
    if (safeStage > RegistrationStage.location.index &&
        draft.analysis == null) {
      safeStage = RegistrationStage.location.index;
    }
    if (safeStage > RegistrationStage.identification.index &&
        draft.duplicateCheckStatus == null) {
      safeStage = RegistrationStage.identification.index;
    }
    final restoredState = TreeRegistrationState(
      draftId: draft.draftId,
      idempotencyKey: draft.idempotencyKey,
      stage: RegistrationStage.values[safeStage],
      photos: draft.photos,
      location: draft.location,
      analysis: draft.analysis,
      selectedCandidateId: draft.selectedCandidateId,
      manualScientificName: draft.manualScientificName,
      nearbyTrees: draft.nearbyTrees,
      duplicateCheckStatus: draft.duplicateCheckStatus,
      nickname: draft.nickname,
      notes: draft.notes,
      visibility: draft.visibility,
      resumed: true,
    );
    emit(restoredState);
    final analysis = restoredState.analysis;
    if (analysis != null && analysis.status != 'completed') {
      try {
        final latest = await repository.getTreeAnalysis(analysis.id);
        emit(
          state.copyWith(
            analysis: latest,
            stage: latest.status == 'completed'
                ? RegistrationStage.identification
                : state.stage,
            selectedCandidateId: latest.topCandidate?.id,
          ),
        );
        await _persist();
      } catch (_) {
        // Keep the local draft; the user can retry without losing evidence.
      }
    }
  }

  Future<void> start() async {
    emit(state.copyWith(stage: RegistrationStage.photos, errorMessage: null));
    await _persist();
  }

  Future<void> setPhoto(TreePhotoType type, String path) async {
    final photo = TreePhotoDraft(
      localId: '${_clock().microsecondsSinceEpoch}-${type.apiValue}',
      localPath: path,
      type: type,
      capturedAt: _clock(),
    );
    emit(
      state.copyWith(
        photos: [...state.photos.where((item) => item.type != type), photo],
        errorMessage: null,
      ),
    );
    await _persist();
  }

  Future<void> removePhoto(TreePhotoType type) async {
    emit(
      state.copyWith(
        photos: state.photos.where((item) => item.type != type).toList(),
      ),
    );
    await _persist();
  }

  Future<bool> continueFromPhotos() async {
    if (!state.hasMinimumPhotos) {
      emit(
        state.copyWith(
          errorMessage: 'Add a whole-tree and leaf photo to continue.',
        ),
      );
      await _persist();
      return false;
    }
    emit(state.copyWith(stage: RegistrationStage.location, errorMessage: null));
    await _persist();
    return true;
  }

  Future<void> setLocation(TreeLocationEvidence evidence) async {
    emit(state.copyWith(location: evidence, errorMessage: null));
    await _persist();
  }

  Future<void> analyze() async {
    if (!state.hasMinimumPhotos || state.location == null || state.isBusy) {
      return;
    }
    emit(
      state.copyWith(
        stage: RegistrationStage.analysis,
        isBusy: true,
        errorMessage: null,
      ),
    );
    try {
      final analysis = await repository.analyzeTree(
        TreeAnalysisRequest(
          photos: state.photos,
          location: state.location!,
          idempotencyKey: '${state.idempotencyKey}-analysis',
        ),
      );
      emit(
        state.copyWith(
          stage: RegistrationStage.identification,
          analysis: analysis,
          selectedCandidateId: analysis.topCandidate?.id,
          isBusy: false,
        ),
      );
      await _persist();
    } catch (error) {
      emit(state.copyWith(isBusy: false, errorMessage: _friendlyError(error)));
    }
  }

  void selectCandidate(String? candidateId) {
    emit(
      state.copyWith(
        selectedCandidateId: candidateId,
        manualScientificName: null,
        errorMessage: null,
      ),
    );
    unawaited(_persist());
  }

  void setManualIdentification(String value) {
    emit(
      state.copyWith(
        selectedCandidateId: null,
        manualScientificName: value.trim().isEmpty ? null : value.trim(),
      ),
    );
    unawaited(_persist());
  }

  Future<void> checkDuplicates() async {
    if (state.location == null || state.isBusy) return;
    emit(state.copyWith(isBusy: true, errorMessage: null));
    try {
      final nearby = await repository.findNearbyTrees(
        coordinate: state.location!.coordinate,
        radiusMeters: 20,
      );
      emit(
        state.copyWith(
          stage: RegistrationStage.duplicates,
          nearbyTrees: nearby,
          duplicateCheckStatus: nearby.isEmpty
              ? DuplicateCheckStatus.noNearbyTrees
              : DuplicateCheckStatus.possibleMatches,
          isBusy: false,
        ),
      );
      await _persist();
    } catch (_) {
      emit(
        state.copyWith(
          stage: RegistrationStage.duplicates,
          nearbyTrees: const [],
          duplicateCheckStatus: DuplicateCheckStatus.skippedDueToNetworkFailure,
          isBusy: false,
        ),
      );
      await _persist();
    }
  }

  void continueAsNewTree() {
    emit(state.copyWith(stage: RegistrationStage.confirmation));
    unawaited(_persist());
  }

  Future<void> updateDetails({
    required String nickname,
    required String notes,
    String? visibility,
  }) async {
    emit(
      state.copyWith(
        nickname: nickname.trim(),
        notes: notes.trim(),
        visibility: visibility,
      ),
    );
    await _persist();
  }

  Future<void> createTree() async {
    final analysis = state.analysis;
    final location = state.location;
    final duplicateStatus = state.duplicateCheckStatus;
    if (analysis == null ||
        location == null ||
        duplicateStatus == null ||
        state.isBusy) {
      return;
    }
    emit(state.copyWith(isBusy: true, errorMessage: null));
    try {
      final tree = await repository.createTree(
        CreateTreeRequest(
          analysisId: analysis.id,
          photos: state.photos,
          location: location,
          idempotencyKey: '${state.idempotencyKey}-create',
          duplicateCheckStatus: duplicateStatus,
          selectedCandidateId: state.selectedCandidateId,
          manualScientificName: state.manualScientificName,
          nickname: state.nickname,
          notes: state.notes,
          visibility: state.visibility,
        ),
      );
      await persistence.clear();
      emit(
        state.copyWith(
          stage: RegistrationStage.success,
          createdTree: tree,
          isBusy: false,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isBusy: false, errorMessage: _friendlyError(error)));
    }
  }

  Future<void> addScanToExistingTree(String treeId) async {
    if (treeId.trim().isEmpty || state.photos.isEmpty || state.isBusy) return;
    emit(state.copyWith(isBusy: true, errorMessage: null));
    try {
      final capturedAt = state.photos
          .map((photo) => photo.capturedAt)
          .reduce((a, b) => a.isAfter(b) ? a : b);
      final scan = await repository.createTreeScan(
        CreateTreeScanRequest(
          treeId: treeId,
          photos: state.photos,
          location: state.location,
          capturedAt: capturedAt,
          notes: state.notes,
          idempotencyKey: '${state.idempotencyKey}-scan-$treeId',
        ),
      );
      await persistence.clear();
      emit(
        state.copyWith(
          stage: RegistrationStage.success,
          createdTree: null,
          createdScan: scan,
          createdScanTreeId: treeId,
          isBusy: false,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isBusy: false, errorMessage: _friendlyError(error)));
    }
  }

  void back() {
    if (state.isBusy || state.stage.index == 0) return;
    final previous = state.stage == RegistrationStage.analysis
        ? RegistrationStage.location
        : RegistrationStage.values[state.stage.index - 1];
    emit(state.copyWith(stage: previous, errorMessage: null));
    unawaited(_persist());
  }

  Future<void> reset() async {
    await persistence.clear();
    emit(_newState(_clock));
  }

  Future<void> _persist() => persistence.save(
    PersistedRegistrationDraft(
      draftId: state.draftId,
      idempotencyKey: state.idempotencyKey,
      photos: state.photos,
      stageIndex: state.stage.index,
      location: state.location,
      analysis: state.analysis,
      selectedCandidateId: state.selectedCandidateId,
      manualScientificName: state.manualScientificName,
      nearbyTrees: state.nearbyTrees,
      duplicateCheckStatus: state.duplicateCheckStatus,
      nickname: state.nickname,
      notes: state.notes,
      visibility: state.visibility,
    ),
  );

  String _friendlyError(Object error) {
    if (error is ApiException) {
      return switch (error.code) {
        'no_plant_detected' =>
          'No plant was detected. Retake clear whole-tree and detail photos.',
        'ai_provider_rejected_input' =>
          'The analysis service rejected these photos. Retake them and retry.',
        'invalid_image' || 'unsupported_image' =>
          'A photo is invalid or unsupported. Replace it and retry.',
        'upload_too_large' =>
          'A photo is too large. Choose a smaller image and retry.',
        'invalid_location_evidence' =>
          'The location evidence is invalid. Capture your position again.',
        'idempotency_conflict' =>
          'This saved draft changed after submission. Start a new draft.',
        'request_in_progress' =>
          'This request is still processing. Keep this draft and retry shortly.',
        'possible_duplicate' =>
          'A possible duplicate needs review before this tree can be created.',
        'ai_quota_exceeded' || 'ai_rate_limited' || 'rate_limited' =>
          'Analysis capacity is temporarily unavailable. Keep this draft and retry later.',
        'ai_provider_unavailable' ||
        'ai_provider_invalid_response' ||
        'backend_unavailable' ||
        'ai_provider_misconfigured' =>
          'Tree analysis is temporarily unavailable. Your draft is safe.',
        'request_timeout' => 'The request timed out. Your draft is safe.',
        _ => error.message,
      };
    }
    final text = '$error'.toLowerCase();
    if (text.contains('timeout')) {
      return 'The request timed out. Your draft is safe.';
    }
    if (text.contains('quota')) {
      return 'Analysis capacity is temporarily unavailable.';
    }
    if (text.contains('image')) {
      return 'A photo could not be uploaded. Review it and retry.';
    }
    return 'Could not complete this step. Check your connection and retry.';
  }
}
