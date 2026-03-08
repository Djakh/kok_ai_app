import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kok_ai_app/assets/themes/theme.dart';
import 'package:kok_ai_app/features/common/presentation/bloc/app_nav_bloc/app_nav_bloc.dart';
import 'package:kok_ai_app/injection_container.dart';
import 'package:kok_ai_app/router.dart';
import 'package:kok_ai_app/size_config.dart';

class KokAiApp extends StatelessWidget {
  const KokAiApp({super.key});

  /// --- Widgets ---

  Widget get materialApp => LayoutBuilder(
    builder: (context, constraints) {
      SizeConfig().init(context, constraints);
      return MultiBlocProvider(
        providers: [BlocProvider(create: (context) => sl<AppNavBloc>())],
        child: MaterialApp.router(
          title: 'KOK.AI',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.light,
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) => materialApp;
}
