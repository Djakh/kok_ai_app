import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kok_ai_app/core/network/auth_token_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('stores and replaces the token pair in one secure value', () async {
    final storage = _RecordingStorage();
    final store = AuthTokenStore(storage: storage);

    await store.saveTokens(accessToken: 'access-1', refreshToken: 'refresh-1');
    await store.saveTokens(accessToken: 'access-2', refreshToken: 'refresh-2');

    expect(storage.writeCount, 2);
    expect(storage.values.keys, [AuthTokenStore.tokenPairKey]);
    final pair = jsonDecode(storage.values[AuthTokenStore.tokenPairKey]!);
    expect(pair['access_token'], 'access-2');
    expect(pair['refresh_token'], 'refresh-2');
    expect(await store.hasSession(), isTrue);
  });

  test('secure storage unavailability remains a typed startup error', () async {
    final store = AuthTokenStore(storage: _UnavailableStorage());
    await expectLater(
      store.hasSession(),
      throwsA(isA<AuthStorageUnavailableException>()),
    );
  });

  test('resilient storage falls back for the current session', () async {
    final fallback = _RecordingStorage();
    final storage = ResilientAuthTokenStorage(
      primary: _UnavailableStorage(),
      fallback: fallback,
    );
    final store = AuthTokenStore(storage: storage);

    expect(await store.hasSession(), isFalse);
    expect(storage.isUsingFallback, isTrue);

    await store.saveTokens(
      accessToken: 'fallback-access',
      refreshToken: 'fallback-refresh',
    );
    expect(await store.hasSession(), isTrue);

    await store.clearTokens();
    expect(await store.hasSession(), isFalse);
  });

  test('debug fallback persists tokens across store recreation', () async {
    SharedPreferences.setMockInitialValues({});
    final firstStore = AuthTokenStore(
      storage: ResilientAuthTokenStorage(
        primary: _UnavailableStorage(),
        fallback: DebugPersistentAuthTokenStorage(),
      ),
    );
    await firstStore.saveTokens(
      accessToken: 'persisted-access',
      refreshToken: 'persisted-refresh',
    );

    final recreatedStore = AuthTokenStore(
      storage: ResilientAuthTokenStorage(
        primary: _UnavailableStorage(),
        fallback: DebugPersistentAuthTokenStorage(),
      ),
    );
    expect(await recreatedStore.readAccessToken(), 'persisted-access');
    expect(await recreatedStore.readRefreshToken(), 'persisted-refresh');
    expect(await recreatedStore.hasSession(), isTrue);
  });
}

class _RecordingStorage implements AuthTokenStorage {
  final Map<String, String> values = {};
  int writeCount = 0;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    writeCount += 1;
    values[key] = value;
  }
}

class _UnavailableStorage implements AuthTokenStorage {
  @override
  Future<void> delete(String key) =>
      throw const AuthStorageUnavailableException();

  @override
  Future<String?> read(String key) =>
      throw const AuthStorageUnavailableException();

  @override
  Future<void> write(String key, String value) =>
      throw const AuthStorageUnavailableException();
}
