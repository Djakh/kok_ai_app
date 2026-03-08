class SocialPostPayload {
  const SocialPostPayload({
    required this.content,
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  final String content;
  final String? imagePath;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'content': content,
    'image_path': imagePath,
    'location': {
      'latitude': latitude,
      'longitude': longitude,
    },
    'created_at': createdAt.toIso8601String(),
  };
}
