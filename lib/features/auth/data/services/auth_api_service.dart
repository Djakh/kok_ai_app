import 'package:kok_ai_app/core/network/api_client.dart';
import 'package:kok_ai_app/core/network/auth_token_store.dart';
import 'package:kok_ai_app/features/user/data/models/api_user.dart';

class AuthApiService {
  const AuthApiService({required this.apiClient, required this.tokenStore});

  final ApiClient apiClient;
  final AuthTokenStore tokenStore;

  Future<void> login({required String email, required String password}) async {
    final data = await apiClient.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    await saveTokensFromData(Map<String, dynamic>.from(data as Map));
  }

  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String fullName,
  }) async {
    final data = await apiClient.post(
      '/auth/register',
      body: {
        'email': email,
        'username': username,
        'password': password,
        'full_name': fullName,
      },
    );
    await saveTokensFromData(Map<String, dynamic>.from(data as Map));
  }

  Future<void> logout() async {
    final refreshToken = await tokenStore.readRefreshToken();
    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await apiClient.post(
          '/auth/logout',
          body: {'refresh_token': refreshToken},
        );
      }
    } finally {
      await tokenStore.clearTokens();
    }
  }

  Future<void> refresh() async {
    await apiClient.refreshSession();
  }

  Future<ApiUser> getCurrentUser() async {
    final data = await apiClient.get('/auth/me');
    return ApiUser.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<void> saveTokensFromData(Map<String, dynamic> data) async {
    final accessToken = '${data['access_token'] ?? ''}';
    final refreshToken = '${data['refresh_token'] ?? ''}';
    if (accessToken.isEmpty || refreshToken.isEmpty) {
      throw const FormatException('Authentication response omitted tokens');
    }
    await tokenStore.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
