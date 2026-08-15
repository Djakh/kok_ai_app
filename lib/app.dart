import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kok_ai_app/assets/themes/theme.dart';
import 'package:kok_ai_app/core/network/auth_token_store.dart';
import 'package:kok_ai_app/core/widgets/app_state_page.dart';
import 'package:kok_ai_app/features/common/presentation/bloc/app_nav_bloc/app_nav_bloc.dart';
import 'package:kok_ai_app/injection_container.dart';
import 'package:kok_ai_app/router.dart';
import 'package:kok_ai_app/size_config.dart';

class KokAiApp extends StatefulWidget {
  const KokAiApp({this.startupCheck, super.key});

  final Future<void> Function()? startupCheck;

  @override
  State<KokAiApp> createState() => _KokAiAppState();
}

class _KokAiAppState extends State<KokAiApp> {
  late Future<void> _startup;

  @override
  void initState() {
    super.initState();
    _startup = _initialize();
  }

  Future<void> _initialize() async {
    try {
      final override = widget.startupCheck;
      if (override != null) {
        await override();
        return;
      }
      await sl<AuthTokenStore>().hasSession();
    } on AuthStorageUnavailableException catch (error) {
      debugPrint('[STARTUP] $error Continuing without a persisted session.');
    }
  }

  void _retryStartup() {
    setState(() {
      _startup = _initialize();
    });
  }

  /// --- Widgets ---

  Widget get materialApp => LayoutBuilder(
    builder: (context, constraints) {
      SizeConfig().init(context, constraints);
      return MultiBlocProvider(
        providers: [BlocProvider(create: (context) => sl<AppNavBloc>())],
        child: FutureBuilder<void>(
          future: _startup,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return _materialApp(home: const AppLoadingPage());
            }
            if (snapshot.hasError) {
              return _materialApp(
                home: AppErrorPage(
                  icon: Icons.cloud_off_rounded,
                  title: 'KOK.AI could not start',
                  message:
                      'Something interrupted app initialization. Your saved data is safe. Please try again.',
                  primaryLabel: 'Retry',
                  onPrimary: _retryStartup,
                ),
              );
            }
            return _routerApp();
          },
        ),
      );
    },
  );

  MaterialApp _materialApp({required Widget home}) => MaterialApp(
    title: 'KOK.AI',
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    themeMode: ThemeMode.light,
    locale: context.locale,
    supportedLocales: context.supportedLocales,
    localizationsDelegates: context.localizationDelegates,
    debugShowCheckedModeBanner: false,
    home: home,
    builder: _whiteBackgroundBuilder,
  );

  MaterialApp _routerApp() => MaterialApp.router(
    title: 'KOK.AI',
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    themeMode: ThemeMode.light,
    locale: context.locale,
    supportedLocales: context.supportedLocales,
    localizationsDelegates: context.localizationDelegates,
    routerConfig: appRouter,
    debugShowCheckedModeBanner: false,
    builder: _whiteBackgroundBuilder,
  );

  Widget _whiteBackgroundBuilder(BuildContext context, Widget? child) =>
      ColoredBox(color: Colors.white, child: child ?? const AppLoadingPage());

  @override
  Widget build(BuildContext context) => materialApp;
}
