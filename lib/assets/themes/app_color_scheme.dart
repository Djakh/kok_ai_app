import 'package:flutter/material.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/design_tokens.dart';

class AppColorScheme {
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: KokTokens.forest,
    onPrimary: AppColors.white,
    secondary: KokTokens.leaf,
    onSecondary: AppColors.white,
    secondaryContainer: KokTokens.forestContainer,
    surface: KokTokens.canvas,
    onSurface: KokTokens.ink,
    tertiary: AppColors.white,
    onTertiary: KokTokens.inkMuted,
    error: AppColors.error,
    onError: AppColors.white,
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    secondary: AppColors.warmEarthBrown,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.grayE8E8E8,
    surface: Color(0xFF1A1A1A),
    onSurface: AppColors.white,
    tertiary: AppColors.white,
    onTertiary: AppColors.gray717171,
    error: AppColors.error,
    onError: AppColors.white,
  );
}
