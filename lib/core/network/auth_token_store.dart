import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenStore {
  static const accessTokenKey = 'access_token';
  static const refreshTokenKey = 'refresh_token';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(accessTokenKey, accessToken);
    await preferences.setString(refreshTokenKey, refreshToken);
  }

  Future<String?> readAccessToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(accessTokenKey);
  }

  Future<String?> readRefreshToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(refreshTokenKey);
  }

  Future<void> clearTokens() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(accessTokenKey);
    await preferences.remove(refreshTokenKey);
  }
}
