import 'package:geolocator/geolocator.dart';
import 'package:kok_ai_app/features/tree/data/models/tree_registration_payload.dart';

class TreeRegistrationDraftStore {
  String? frontImagePath;
  String? trunkImagePath;
  String? leavesImagePath;

  double? latitude;
  double? longitude;
  double? accuracyMeters;

  String? name;

  TreeRegistrationPayload? lastPreparedPayload;

  bool get hasAllImages =>
      frontImagePath != null &&
      trunkImagePath != null &&
      leavesImagePath != null;

  bool get hasLocation => latitude != null && longitude != null;

  bool get hasName => name != null && name!.trim().isNotEmpty;

  void setImageByStep(int stepIndex, String path) {
    if (stepIndex == 0) {
      frontImagePath = path;
      return;
    }

    if (stepIndex == 1) {
      trunkImagePath = path;
      return;
    }

    if (stepIndex == 2) {
      leavesImagePath = path;
    }
  }

  void setLocation(Position position) {
    latitude = position.latitude;
    longitude = position.longitude;
    accuracyMeters = position.accuracy;
  }

  void setName(String value) {
    name = value.trim();
  }

  TreeRegistrationPayload? preparePayload() {
    if (!hasAllImages || !hasLocation || !hasName) return null;

    final payload = TreeRegistrationPayload(
      name: name!,
      latitude: latitude!,
      longitude: longitude!,
      accuracyMeters: accuracyMeters ?? 0,
      frontImagePath: frontImagePath!,
      trunkImagePath: trunkImagePath!,
      leavesImagePath: leavesImagePath!,
      capturedAt: DateTime.now(),
    );

    lastPreparedPayload = payload;
    return payload;
  }

  void reset() {
    frontImagePath = null;
    trunkImagePath = null;
    leavesImagePath = null;
    latitude = null;
    longitude = null;
    accuracyMeters = null;
    name = null;
  }
}
