import 'package:kok_ai_app/features/social/data/models/social_post_payload.dart';

class SocialPostDraftStore {
  SocialPostPayload? lastPreparedPayload;

  SocialPostPayload preparePayload({
    required String content,
    required String? imagePath,
    required double? latitude,
    required double? longitude,
  }) {
    final now = DateTime.now();
    final payload = SocialPostPayload(
      content: content,
      imagePath: imagePath,
      latitude: latitude,
      longitude: longitude,
      createdAt: now,
      idempotencyKey: 'social-post-${now.microsecondsSinceEpoch}',
    );

    lastPreparedPayload = payload;
    return payload;
  }
}
