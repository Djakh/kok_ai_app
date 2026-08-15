import 'package:flutter/material.dart';

/// Central design tokens for the KOK.AI environmental technology identity.
abstract final class KokTokens {
  static const Color forest = Color(0xFF123C2D);
  static const Color forestContainer = Color(0xFFD9EDE3);
  static const Color leaf = Color(0xFF2F7D55);
  static const Color lime = Color(0xFF9BCB6B);
  static const Color turquoise = Color(0xFF2B8C82);
  static const Color canvas = Color(0xFFF7F5EF);
  static const Color surface = Color(0xFFFFFDF8);
  static const Color surfaceMuted = Color(0xFFEEF2EC);
  static const Color ink = Color(0xFF17201C);
  static const Color inkMuted = Color(0xFF5C6962);
  static const Color outline = Color(0xFFD8DED8);
  static const Color success = Color(0xFF24734B);
  static const Color warning = Color(0xFF9A6300);
  static const Color warningContainer = Color(0xFFFFE9B8);
  static const Color error = Color(0xFFBA1A1A);

  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;

  static const double radiusSmall = 10;
  static const double radiusMedium = 16;
  static const double radiusLarge = 24;
  static const double radiusPill = 999;

  static const double iconSmall = 18;
  static const double iconMedium = 24;
  static const double iconLarge = 32;

  static const Duration motionFast = Duration(milliseconds: 160);
  static const Duration motionStandard = Duration(milliseconds: 280);
}
