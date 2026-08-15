import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/core/network/api_client.dart';
import 'package:kok_ai_app/core/network/auth_token_store.dart';
import 'package:kok_ai_app/core/widgets/kok_ai_logo.dart';
import 'package:kok_ai_app/features/auth/data/services/auth_api_service.dart';
import 'package:kok_ai_app/features/auth/presentation/pages/login_page.dart';
import 'package:kok_ai_app/injection_container.dart';

void main() {
  setUp(() async {
    await sl.reset();
    final tokenStore = AuthTokenStore(storage: InMemoryAuthTokenStorage());
    sl.registerSingleton<AuthTokenStore>(tokenStore);
    sl.registerSingleton<AuthApiService>(
      AuthApiService(
        apiClient: ApiClient(tokenStore: tokenStore),
        tokenStore: tokenStore,
      ),
    );
  });

  tearDown(() => sl.reset());

  testWidgets('six logo taps create the static debug session', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const LoginPage()),
        GoRoute(
          path: '/app',
          builder: (_, _) => const Scaffold(body: Text('Debug dashboard')),
        ),
        GoRoute(
          path: '/register',
          builder: (_, _) => const Scaffold(body: Text('Register')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    final logo = find.byKey(const Key('debug-login-logo'));
    expect(logo, findsOneWidget);
    expect(find.byType(KokAiLogo), findsOneWidget);

    for (var index = 0; index < 6; index += 1) {
      await tester.tap(logo);
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();

    expect(find.text('Debug dashboard'), findsOneWidget);
    expect(
      await sl<AuthTokenStore>().readAccessToken(),
      AuthTokenStore.debugAccessToken,
    );
    expect(
      await sl<AuthTokenStore>().readRefreshToken(),
      AuthTokenStore.debugRefreshToken,
    );
  });
}
