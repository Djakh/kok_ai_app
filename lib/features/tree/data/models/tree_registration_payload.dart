class TreeRegistrationPayload {
  const TreeRegistrationPayload({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.frontImagePath,
    required this.trunkImagePath,
    required this.leavesImagePath,
    required this.capturedAt,
  });

  final String name;
  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final String frontImagePath;
  final String trunkImagePath;
  final String leavesImagePath;
  final DateTime capturedAt;

  Map<String, dynamic> toJson() => {
    'name': name,
    'location': {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy_meters': accuracyMeters,
    },
    'images': {
      'front': frontImagePath,
      'trunk': trunkImagePath,
      'leaves': leavesImagePath,
    },
    'captured_at': capturedAt.toIso8601String(),
  };
}
