import 'package:kok_ai_app/core/network/api_config.dart';

class ApiUser {
  const ApiUser({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    required this.role,
    required this.bio,
    required this.avatarUrl,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String username;
  final String? fullName;
  final String role;
  final String? bio;
  final String? avatarUrl;
  final DateTime? createdAt;

  factory ApiUser.fromJson(Map<String, dynamic> json) => ApiUser(
    id: '${json['id'] ?? ''}',
    email: '${json['email'] ?? ''}',
    username: '${json['username'] ?? ''}',
    fullName: json['full_name'] as String?,
    role: '${json['role'] ?? ''}',
    bio: json['bio'] as String?,
    avatarUrl: ApiConfig.normalizeAssetUrl(json['avatar_url'] as String?),
    createdAt: DateTime.tryParse('${json['created_at']}'),
  );
}
