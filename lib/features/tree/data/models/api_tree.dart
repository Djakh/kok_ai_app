import 'package:kok_ai_app/core/network/api_config.dart';

class ApiTree {
  const ApiTree({
    required this.id,
    required this.name,
    required this.status,
    required this.ownerId,
    required this.capturedAt,
    required this.createdAt,
    required this.latitude,
    required this.longitude,
    required this.frontImageUrl,
    required this.trunkImageUrl,
    required this.leavesImageUrl,
  });

  final String id;
  final String name;
  final String status;
  final String ownerId;
  final DateTime? capturedAt;
  final DateTime? createdAt;
  final double? latitude;
  final double? longitude;
  final String? frontImageUrl;
  final String? trunkImageUrl;
  final String? leavesImageUrl;

  factory ApiTree.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    final images = json['images'] as Map<String, dynamic>?;
    final identification = json['identification'] as Map<String, dynamic>?;
    final photos = json['photos'] as List? ?? const [];
    String? photoOfType(String type) {
      for (final photo in photos.whereType<Map>()) {
        if (photo['type'] == type) return photo['url'] as String?;
      }
      return null;
    }

    final primaryImage = json['primary_image_url'] as String?;
    return ApiTree(
      id: '${json['id'] ?? ''}',
      name:
          '${json['nickname'] ?? json['name'] ?? identification?['common_name'] ?? identification?['scientific_name'] ?? ''}',
      status: '${json['status'] ?? identification?['source'] ?? 'unknown'}',
      ownerId: '${json['owner_id'] ?? ''}',
      capturedAt: DateTime.tryParse(
        '${json['captured_at'] ?? location?['captured_at']}',
      ),
      createdAt: DateTime.tryParse(
        '${json['created_at'] ?? json['registered_at']}',
      ),
      latitude: (location?['latitude'] as num?)?.toDouble(),
      longitude: (location?['longitude'] as num?)?.toDouble(),
      frontImageUrl: ApiConfig.normalizeAssetUrl(
        images?['front'] as String? ??
            photoOfType('whole_tree') ??
            primaryImage,
      ),
      trunkImageUrl: ApiConfig.normalizeAssetUrl(
        images?['trunk'] as String? ?? photoOfType('bark'),
      ),
      leavesImageUrl: ApiConfig.normalizeAssetUrl(
        images?['leaves'] as String? ?? photoOfType('leaf'),
      ),
    );
  }
}
