import 'package:kok_ai_app/core/network/api_client.dart';
import 'package:kok_ai_app/features/profile/data/models/profile_achievement.dart';
import 'package:kok_ai_app/features/profile/data/models/profile_settings.dart';
import 'package:kok_ai_app/features/profile/data/models/profile_stats.dart';
import 'package:kok_ai_app/features/profile/data/models/supported_language.dart';
import 'package:kok_ai_app/features/social/data/models/api_social_post.dart';

class ProfileApiService {
  const ProfileApiService({required this.apiClient});

  final ApiClient apiClient;

  Future<ProfileStats> getStats() async {
    final data = await apiClient.get('/profile/me/stats');
    return ProfileStats.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<List<ProfileAchievement>> getAchievements() async {
    final data = await apiClient.get('/profile/me/achievements');
    final raw = data is Map ? data['items'] as List? ?? const [] : data as List;
    return raw
        .whereType<Map>()
        .map(
          (item) =>
              ProfileAchievement.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<List<ApiSocialPost>> getMyPosts() async {
    final data = await apiClient.get('/profile/me/posts');
    final list = List<Map<String, dynamic>>.from(data as List);
    return list.map(ApiSocialPost.fromJson).toList();
  }

  Future<List<ApiSocialPost>> getLikedPosts() async {
    final data = await apiClient.get('/profile/me/liked-posts');
    final list = List<Map<String, dynamic>>.from(data as List);
    return list.map(ApiSocialPost.fromJson).toList();
  }

  Future<ProfileSettings> getSettings() async {
    final data = await apiClient.get('/profile/me/settings');
    return ProfileSettings.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<ProfileSettings> updateSettings({
    bool? privacyProfilePublic,
    bool? notificationsEnabled,
  }) async {
    final body = <String, dynamic>{};
    if (privacyProfilePublic != null) {
      body['privacy_profile_public'] = privacyProfilePublic;
    }
    if (notificationsEnabled != null) {
      body['notifications_enabled'] = notificationsEnabled;
    }
    final data = await apiClient.patch('/profile/me/settings', body: body);
    return ProfileSettings.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<void> updateLocalization(String languageCode) async {
    await apiClient.patch(
      '/profile/me/localization',
      body: {'language_code': languageCode},
    );
  }

  Future<List<SupportedLanguage>> getSupportedLanguages() async {
    final data = await apiClient.get('/localization/languages');
    final raw = data is Map
        ? data['items'] as List? ?? data['languages'] as List? ?? const []
        : data as List;
    return raw.map(SupportedLanguage.fromJsonValue).toList();
  }
}
