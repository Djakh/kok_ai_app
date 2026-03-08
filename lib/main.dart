import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kok_ai_app/app.dart';
import 'package:kok_ai_app/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await initDependencies();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ru'), Locale('uz')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const KokAiApp(),
    ),
  );
}
