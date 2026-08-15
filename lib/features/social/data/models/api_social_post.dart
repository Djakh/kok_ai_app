import 'package:kok_ai_app/core/network/api_config.dart';

class ApiSocialPost {
  const ApiSocialPost({
    required this.id,
    required this.authorId,
    required this.content,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  final String id;
  final String authorId;
  final String content;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;

  factory ApiSocialPost.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    return ApiSocialPost(
      id: '${json['id'] ?? ''}',
      authorId: '${json['author_id'] ?? ''}',
      content: '${json['content'] ?? ''}',
      imageUrl: ApiConfig.normalizeAssetUrl(json['image_url'] as String?),
      latitude: (location?['latitude'] as num?)?.toDouble(),
      longitude: (location?['longitude'] as num?)?.toDouble(),
      createdAt: DateTime.tryParse('${json['created_at']}'),
    );
  }
}
