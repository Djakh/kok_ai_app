import 'package:flutter/material.dart';
import 'package:kok_ai_app/assets/themes/app_color_scheme.dart';
import 'package:kok_ai_app/assets/themes/design_tokens.dart';

class AppTheme {
  static ThemeData light() {
    final scheme = AppColorScheme.light;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: KokTokens.canvas,
      brightness: Brightness.light,
      fontFamily: 'Ubuntu',
      appBarTheme: const AppBarTheme(
        backgroundColor: KokTokens.canvas,
        foregroundColor: KokTokens.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: KokTokens.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(KokTokens.radiusMedium),
          ),
          side: BorderSide(color: KokTokens.outline),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: KokTokens.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(KokTokens.radiusMedium),
          ),
          borderSide: BorderSide(color: KokTokens.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(KokTokens.radiusMedium),
          ),
          borderSide: BorderSide(color: KokTokens.outline),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 54),
          backgroundColor: KokTokens.forest,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KokTokens.radiusMedium),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 52),
          foregroundColor: KokTokens.forest,
          side: const BorderSide(color: KokTokens.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KokTokens.radiusMedium),
          ),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: KokTokens.surface,
        indicatorColor: KokTokens.forestContainer,
        elevation: 0,
        height: 72,
      ),
      dividerTheme: const DividerThemeData(color: KokTokens.outline),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorScheme.dark,
      scaffoldBackgroundColor: AppColorScheme.dark.surface,
      brightness: Brightness.dark,
    );
  }
}
