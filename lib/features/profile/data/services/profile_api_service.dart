import 'package:kok_ai_app/core/network/api_client.dart';

class ProfileApiService {
  const ProfileApiService({required this.apiClient});

  final ApiClient apiClient;

  Future<void> updateLocalization(String languageCode) async {
    await apiClient.patch(
      '/profile/me/localization',
      body: {'language_code': languageCode},
    );
  }
}
