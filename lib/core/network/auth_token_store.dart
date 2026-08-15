import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorageUnavailableException implements Exception {
  const AuthStorageUnavailableException();

  @override
  String toString() => 'Secure sign-in storage is unavailable.';
}

abstract interface class AuthTokenStorage {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
}

class PlatformSecureAuthTokenStorage implements AuthTokenStorage {
  PlatformSecureAuthTokenStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  @override
  Future<void> write(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } on MissingPluginException {
      throw const AuthStorageUnavailableException();
    } on PlatformException {
      throw const AuthStorageUnavailableException();
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } on MissingPluginException {
      throw const AuthStorageUnavailableException();
    } on PlatformException {
      throw const AuthStorageUnavailableException();
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } on MissingPluginException {
      throw const AuthStorageUnavailableException();
    } on PlatformException {
      throw const AuthStorageUnavailableException();
    }
  }
}

/// A deterministic adapter for widget/unit tests. Never register it in a
/// production dependency graph.
class InMemoryAuthTokenStorage implements AuthTokenStorage {
  final Map<String, String> _values = {};

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> delete(String key) async => _values.remove(key);
}

/// Persistent compatibility storage used only by debug builds when the
/// native secure-storage channel is unavailable. Release builds never place
/// authentication tokens in shared preferences.
class DebugPersistentAuthTokenStorage implements AuthTokenStorage {
  static const _keyPrefix = 'kokai_debug_auth_';

  @override
  Future<void> write(String key, String value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('$_keyPrefix$key', value);
  }

  @override
  Future<String?> read(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString('$_keyPrefix$key');
  }

  @override
  Future<void> delete(String key) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('$_keyPrefix$key');
  }
}

/// Keeps authentication usable when a running native process has not loaded
/// the secure-storage plugin yet (for example, after adding it during a hot
/// restart). The fallback is intentionally memory-only: credentials are never
/// persisted in plain text and a future full launch retries secure storage.
class ResilientAuthTokenStorage implements AuthTokenStorage {
  ResilientAuthTokenStorage({
    AuthTokenStorage? primary,
    AuthTokenStorage? fallback,
  }) : _primary = primary ?? PlatformSecureAuthTokenStorage(),
       _fallback =
           fallback ??
           (kDebugMode
               ? DebugPersistentAuthTokenStorage()
               : InMemoryAuthTokenStorage());

  final AuthTokenStorage _primary;
  final AuthTokenStorage _fallback;
  bool _usingFallback = false;
  bool _didReportFallback = false;

  bool get isUsingFallback => _usingFallback;

  String get activeStorageLabel {
    if (!_usingFallback) return 'secure storage';
    return switch (_fallback) {
      DebugPersistentAuthTokenStorage() => 'persistent debug fallback',
      InMemoryAuthTokenStorage() => 'memory-only fallback',
      _ => 'custom fallback',
    };
  }

  @override
  Future<void> write(String key, String value) => _run(
    primary: () => _primary.write(key, value),
    fallback: () => _fallback.write(key, value),
  );

  @override
  Future<String?> read(String key) => _run(
    primary: () => _primary.read(key),
    fallback: () => _fallback.read(key),
  );

  @override
  Future<void> delete(String key) => _run(
    primary: () => _primary.delete(key),
    fallback: () => _fallback.delete(key),
  );

  Future<T> _run<T>({
    required Future<T> Function() primary,
    required Future<T> Function() fallback,
  }) async {
    if (_usingFallback) return fallback();

    try {
      return await primary();
    } on AuthStorageUnavailableException catch (error) {
      _usingFallback = true;
      if (!_didReportFallback) {
        _didReportFallback = true;
        if (kDebugMode) {
          debugPrint(
            '[AUTH STORAGE] Secure storage unavailable ($error). '
            'Using $activeStorageLabel.',
          );
        }
      }
      return fallback();
    }
  }
}

class AuthTokenStore {
  AuthTokenStore({AuthTokenStorage? storage})
    : _storage = storage ?? ResilientAuthTokenStorage();

  static const tokenPairKey = 'kokai_auth_token_pair';
  static const debugAccessToken = 'kokai-debug-static-access-token';
  static const debugRefreshToken = 'kokai-debug-static-refresh-token';

  final AuthTokenStorage _storage;
  bool? _lastReportedSessionState;

  String get storageLabel => switch (_storage) {
    ResilientAuthTokenStorage storage => storage.activeStorageLabel,
    DebugPersistentAuthTokenStorage() => 'persistent debug storage',
    InMemoryAuthTokenStorage() => 'memory storage',
    _ => 'custom secure storage',
  };

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(
      tokenPairKey,
      jsonEncode({'access_token': accessToken, 'refresh_token': refreshToken}),
    );
    _lastReportedSessionState = true;
    if (kDebugMode) {
      debugPrint('[AUTH STORAGE] Token pair saved using $storageLabel.');
    }
  }

  Future<String?> readAccessToken() async => (await _readPair()).$1;

  Future<String?> readRefreshToken() async => (await _readPair()).$2;

  Future<bool> isDebugSession() async {
    if (!kDebugMode) return false;
    final pair = await _readPair();
    return pair.$1 == debugAccessToken && pair.$2 == debugRefreshToken;
  }

  Future<bool> hasSession() async {
    final pair = await _readPair();
    final hasSession =
        (pair.$1?.isNotEmpty ?? false) || (pair.$2?.isNotEmpty ?? false);
    if (_lastReportedSessionState != hasSession) {
      _lastReportedSessionState = hasSession;
      if (kDebugMode) {
        debugPrint(
          '[AUTH STORAGE] Persisted session '
          '${hasSession ? 'found' : 'not found'} using $storageLabel.',
        );
      }
    }
    return hasSession;
  }

  Future<void> clearTokens() async {
    await _storage.delete(tokenPairKey);
    _lastReportedSessionState = false;
    if (kDebugMode) {
      debugPrint('[AUTH STORAGE] Token pair cleared from $storageLabel.');
    }
  }

  Future<(String?, String?)> _readPair() async {
    final encoded = await _storage.read(tokenPairKey);
    if (encoded == null || encoded.isEmpty) return (null, null);
    try {
      final json = Map<String, dynamic>.from(jsonDecode(encoded) as Map);
      return (
        _nonEmpty(json['access_token']),
        _nonEmpty(json['refresh_token']),
      );
    } catch (_) {
      await clearTokens();
      return (null, null);
    }
  }

  static String? _nonEmpty(dynamic value) {
    final text = value?.toString();
    return text == null || text.isEmpty ? null : text;
  }
}
