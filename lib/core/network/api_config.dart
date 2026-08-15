import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig.internal();

  static const _apiBaseUrlDefine = String.fromEnvironment('API_BASE_URL');
  static const _androidApiBaseUrlDefine = String.fromEnvironment(
    'ANDROID_API_BASE_URL',
  );
  static const _iosApiBaseUrlDefine = String.fromEnvironment(
    'IOS_API_BASE_URL',
  );
  static const _dataModeDefine = String.fromEnvironment('KOKAI_DATA_MODE');

  /// The implemented backend is now the default. Fixture mode remains
  /// available only when explicitly requested for UI/demo work.
  static bool get useFixtures {
    return _dataModeDefine == 'fixture';
  }

  static String get dataModeLabel => useFixtures ? 'Demo data' : 'Live API';

  static String get baseUrl {
    final configuredBaseUrl = _normalizeBaseUrl(_apiBaseUrlDefine);
    if (configuredBaseUrl != null) return configuredBaseUrl;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidBaseUrl = _normalizeBaseUrl(_androidApiBaseUrlDefine);
      if (androidBaseUrl != null) return androidBaseUrl;
      if (kReleaseMode) {
        throw StateError(
          'API_BASE_URL is required when building KOK.AI in remote release mode.',
        );
      }
      return 'http://10.0.2.2:8000/api/v1';
    }

    final iosBaseUrl = _normalizeBaseUrl(_iosApiBaseUrlDefine);
    if (iosBaseUrl != null) return iosBaseUrl;

    if (kReleaseMode) {
      throw StateError(
        'API_BASE_URL is required when building KOK.AI in remote release mode.',
      );
    }

    return 'http://localhost:8000/api/v1';
  }

  static bool get isLoopbackBaseUrl {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null) return false;
    return _isLoopbackHost(uri.host);
  }

  static String get apiRootUrl {
    final uri = Uri.parse(baseUrl);
    return uri
        .replace(path: '', query: null, fragment: null)
        .toString()
        .replaceFirst(RegExp(r'/$'), '');
  }

  static String get apiBasePath {
    final path = Uri.parse(baseUrl).path.replaceFirst(RegExp(r'/$'), '');
    return path.isEmpty ? '/api/v1' : path;
  }

  static String? get releaseBuildHint {
    if (!kReleaseMode || !isLoopbackBaseUrl) return null;

    return 'This APK is using $baseUrl. Physical devices cannot reach '
        'emulator localhost. Rebuild with '
        '--dart-define=API_BASE_URL=http://<your-computer-lan-ip>:8000/api/v1';
  }

  static String? normalizeAssetUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final uri = Uri.tryParse(value);
    if (uri == null) return value;

    final apiUri = Uri.tryParse(baseUrl);
    if (apiUri != null &&
        uri.hasScheme &&
        _isLoopbackHost(uri.host) &&
        !_isLoopbackHost(apiUri.host)) {
      return uri
          .replace(
            scheme: apiUri.scheme,
            host: apiUri.host,
            port: apiUri.hasPort ? apiUri.port : null,
          )
          .toString();
    }

    if (defaultTargetPlatform == TargetPlatform.android &&
        uri.host == 'localhost') {
      return uri.replace(host: '10.0.2.2').toString();
    }

    return value;
  }

  static String? _normalizeBaseUrl(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) return null;
    return trimmedValue.replaceFirst(RegExp(r'/$'), '');
  }

  static bool _isLoopbackHost(String host) {
    return host == 'localhost' || host == '127.0.0.1' || host == '10.0.2.2';
  }
}
