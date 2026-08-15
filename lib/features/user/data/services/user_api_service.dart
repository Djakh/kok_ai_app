import 'package:kok_ai_app/core/network/api_client.dart';
import 'package:kok_ai_app/features/user/data/models/api_user.dart';

class UserApiService {
  const UserApiService({required this.apiClient});

  final ApiClient apiClient;

  Future<ApiUser> getMe() async {
    final data = await apiClient.get('/users/me');
    return ApiUser.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<ApiUser> getUser(String userId) async {
    final data = await apiClient.get('/users/$userId');
    return ApiUser.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<List<ApiUser>> getFollowers(String userId) async {
    final data = await apiClient.get('/users/$userId/followers');
    final list = List<Map<String, dynamic>>.from(data as List);
    return list.map(ApiUser.fromJson).toList();
  }

  Future<List<ApiUser>> getFollowing(String userId) async {
    final data = await apiClient.get('/users/$userId/following');
    final list = List<Map<String, dynamic>>.from(data as List);
    return list.map(ApiUser.fromJson).toList();
  }

  Future<void> follow(String userId) async {
    await apiClient.post('/users/$userId/follow');
  }

  Future<void> unfollow(String userId) async {
    await apiClient.delete('/users/$userId/follow');
  }

  Future<ApiUser> updateMe({
    String? fullName,
    String? bio,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['full_name'] = fullName;
    if (bio != null) body['bio'] = bio;
    if (avatarUrl != null) body['avatar_url'] = avatarUrl;
    final data = await apiClient.patch('/users/me', body: body);
    return ApiUser.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
