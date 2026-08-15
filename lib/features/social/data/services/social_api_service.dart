import 'package:kok_ai_app/core/network/api_client.dart';
import 'package:kok_ai_app/features/social/data/models/api_social_comment.dart';
import 'package:kok_ai_app/features/social/data/models/api_social_post.dart';
import 'package:kok_ai_app/features/social/data/models/social_post_payload.dart';
import 'package:kok_ai_app/features/social/data/models/social_post_result.dart';
import 'package:kok_ai_app/features/upload/data/services/upload_api_service.dart';

class SocialApiService {
  const SocialApiService({
    required this.apiClient,
    required this.uploadApiService,
  });

  final ApiClient apiClient;
  final UploadApiService uploadApiService;

  Future<List<ApiSocialPost>> listPosts({
    String? cursor,
    int limit = 20,
    String? userId,
    String? near,
  }) async {
    final data = await apiClient.get(
      '/social/posts',
      queryParameters: {
        'cursor': cursor,
        'limit': limit,
        'user_id': userId,
        'near': near,
      },
    );
    final raw = data is Map ? data['items'] as List? ?? const [] : data as List;
    final list = List<Map<String, dynamic>>.from(raw);
    return list.map(ApiSocialPost.fromJson).toList();
  }

  Future<ApiSocialPost> getPost(String postId) async {
    final data = await apiClient.get('/social/posts/$postId');
    return ApiSocialPost.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<ApiSocialPost> updatePost(String postId, String content) async {
    final data = await apiClient.patch(
      '/social/posts/$postId',
      body: {'content': content},
    );
    return ApiSocialPost.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<void> deletePost(String postId) async {
    await apiClient.delete('/social/posts/$postId');
  }

  Future<void> likePost(String postId) async {
    await apiClient.post('/social/posts/$postId/likes');
  }

  Future<void> unlikePost(String postId) async {
    await apiClient.delete('/social/posts/$postId/likes');
  }

  Future<List<dynamic>> listLikes(String postId) async {
    final data = await apiClient.get('/social/posts/$postId/likes');
    final raw = data is Map ? data['items'] as List? ?? const [] : data as List;
    return List<dynamic>.from(raw);
  }

  Future<List<ApiSocialComment>> listComments(String postId) async {
    final data = await apiClient.get('/social/posts/$postId/comments');
    final raw = data is Map ? data['items'] as List? ?? const [] : data as List;
    final list = List<Map<String, dynamic>>.from(raw);
    return list.map(ApiSocialComment.fromJson).toList();
  }

  Future<void> createComment(String postId, String content) async {
    await apiClient.post(
      '/social/posts/$postId/comments',
      body: {'content': content},
    );
  }

  Future<void> deleteComment(String commentId) async {
    await apiClient.delete('/social/comments/$commentId');
  }

  Future<SocialPostResult> createPost(SocialPostPayload payload) async {
    if (payload.uploadId == null &&
        payload.imagePath != null &&
        payload.imagePath!.isNotEmpty) {
      final upload = await uploadApiService.uploadImage(
        path: payload.imagePath!,
      );
      payload.uploadId = upload.id;
    }

    final body = {
      'content': payload.content,
      'upload_id': payload.uploadId,
      'created_at': payload.createdAt.toUtc().toIso8601String(),
      'location': payload.latitude == null || payload.longitude == null
          ? null
          : {'latitude': payload.latitude, 'longitude': payload.longitude},
    };

    final data = await apiClient.post(
      '/social/posts',
      body: body,
      headers: {'Idempotency-Key': payload.idempotencyKey},
    );
    return SocialPostResult.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
