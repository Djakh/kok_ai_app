import 'package:kok_ai_app/core/network/api_client.dart';
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

  Future<SocialPostResult> createPost(SocialPostPayload payload) async {
    String? uploadId;
    if (payload.imagePath != null && payload.imagePath!.isNotEmpty) {
      final upload = await uploadApiService.uploadImage(
        path: payload.imagePath!,
      );
      uploadId = upload.id;
    }

    final body = {
      'content': payload.content,
      'upload_id': uploadId,
      'location': {
        'latitude': payload.latitude,
        'longitude': payload.longitude,
      },
      'created_at': payload.createdAt.toUtc().toIso8601String(),
    };

    final idempotencyKey =
        'social-post-${DateTime.now().millisecondsSinceEpoch}';
    final data = await apiClient.post(
      '/social/posts',
      body: body,
      headers: {'Idempotency-Key': idempotencyKey},
    );
    return SocialPostResult.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
