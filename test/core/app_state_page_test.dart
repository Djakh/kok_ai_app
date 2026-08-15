import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kok_ai_app/app.dart';
import 'package:kok_ai_app/core/network/auth_token_store.dart';
import 'package:kok_ai_app/core/widgets/app_state_page.dart';
import 'package:kok_ai_app/core/widgets/kok_ai_logo.dart';
import 'package:kok_ai_app/features/common/presentation/bloc/app_nav_bloc/app_nav_bloc.dart';
import 'package:kok_ai_app/injection_container.dart';
import 'package:kok_ai_app/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('startup loading page is white and branded', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AppLoadingPage()));

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, Colors.white);
    expect(find.byType(KokAiLogo), findsOneWidget);
    expect(find.text('KOK.AI'), findsOneWidget);
    expect(find.text('Preparing your tree workspace…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('error page explains recovery and runs retry', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: AppErrorPage(
          title: 'One restart is needed',
          message: 'Fully stop the app and run it again.',
          primaryLabel: 'Retry',
          onPrimary: () => retried = true,
        ),
      ),
    );

    expect(find.text('One restart is needed'), findsOneWidget);
    expect(find.text('Fully stop the app and run it again.'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  testWidgets('startup Retry installs a new future synchronously', (
    tester,
  ) async {
    await sl.reset();
    addTearDown(sl.reset);
    sl.registerLazySingleton<AppNavBloc>(AppNavBloc.new);
    var attempts = 0;
    final pendingRetry = Completer<void>();

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ru'), Locale('uz')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: KokAiApp(
          startupCheck: () {
            attempts += 1;
            if (attempts == 1) {
              return Future<void>.error(StateError('startup test failure'));
            }
            return pendingRetry.future;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('KOK.AI could not start'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(attempts, 2);
    expect(find.text('Preparing your tree workspace…'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('secure storage absence never blocks app startup', (
    tester,
  ) async {
    await sl.reset();
    addTearDown(sl.reset);
    await initDependencies();

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ru'), Locale('uz')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: KokAiApp(
          startupCheck: () =>
              Future<void>.error(const AuthStorageUnavailableException()),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('One restart is needed'), findsNothing);
    expect(find.byType(AppErrorPage), findsNothing);
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.routerConfig, same(appRouter));
    expect(tester.takeException(), isNull);
  });
}
