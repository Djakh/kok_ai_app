import 'package:flutter/material.dart';
import 'package:kok_ai_app/assets/themes/design_tokens.dart';

class AppColors {
  static const Color primary = KokTokens.forest;
  static const Color brightLeafGreen = KokTokens.leaf;
  static const Color deepForestGreen = KokTokens.forest;
  static const Color warmEarthBrown = Color(0xFF9C7A57);
  static const Color lightEarthBrown = Color(0xFFC49A6C);
  static const Color neutralLight = KokTokens.canvas;

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color secondary = KokTokens.ink;
  static const Color gray717171 = KokTokens.inkMuted;
  static const Color grayE8E8E8 = KokTokens.outline;
  static const Color grayA0A0A0 = Color(0xFFA0A0A0);

  static const Color success = KokTokens.success;
  static const Color warning = KokTokens.warning;
  static const Color error = KokTokens.error;

  static const Color transparent = Color(0x00000000);

  // Compatibility aliases for existing project files
  static const Color green49 = primary;
  static const Color green50 = deepForestGreen;
  static const Color orange13 = warmEarthBrown;
  static const Color orange12 = lightEarthBrown;
  static const Color purpleC3 = warmEarthBrown;
  static const Color purpleD6 = lightEarthBrown;
  static const Color gray8D = gray717171;
  static const Color gray8C = gray717171;
  static const Color grayF4 = neutralLight;
}
