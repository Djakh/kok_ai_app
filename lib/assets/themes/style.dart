import 'package:flutter/material.dart';

enum TextColorRole { onSurface, whiteColor, primaryColor, greyColor }

class Style {
  Style.internal();

  static BorderRadius get border8 => const BorderRadius.all(Radius.circular(8));
  static BorderRadius get border12 =>
      const BorderRadius.all(Radius.circular(12));
  static BorderRadius get border16 =>
      const BorderRadius.all(Radius.circular(16));
  static BorderRadius get border20 =>
      const BorderRadius.all(Radius.circular(20));
  static BorderRadius get border24 =>
      const BorderRadius.all(Radius.circular(24));
  static BorderRadius get border28 =>
      const BorderRadius.all(Radius.circular(28));
  static BorderRadius get border32 =>
      const BorderRadius.all(Radius.circular(32));

  static const EdgeInsets paddingAll12 = EdgeInsets.all(12);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(16);
  static const EdgeInsets paddingAll20 = EdgeInsets.all(20);
  static const EdgeInsets paddingAll24 = EdgeInsets.all(24);

  static const EdgeInsets paddingH12 = EdgeInsets.symmetric(horizontal: 12);
  static const EdgeInsets paddingH16 = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets paddingH20 = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets paddingH24 = EdgeInsets.symmetric(horizontal: 24);

  static const EdgeInsets paddingV8 = EdgeInsets.symmetric(vertical: 8);
  static const EdgeInsets paddingV12 = EdgeInsets.symmetric(vertical: 12);
  static const EdgeInsets paddingV16 = EdgeInsets.symmetric(vertical: 16);
  static const EdgeInsets paddingV20 = EdgeInsets.symmetric(vertical: 20);

  static String get fontFamily => 'Ubuntu';

  static Color textColor(BuildContext context, TextColorRole? role) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (role) {
      case TextColorRole.onSurface:
        return colorScheme.onSurface;
      case TextColorRole.whiteColor:
        return colorScheme.onPrimary;
      case TextColorRole.primaryColor:
        return colorScheme.primary;
      case TextColorRole.greyColor:
        return colorScheme.onTertiary;
      case null:
        return colorScheme.onSurface;
    }
  }

  static TextStyle headline32(BuildContext context, {Color? color}) =>
      TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: color ?? Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle headline28(BuildContext context, {Color? color}) =>
      TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: color ?? Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle headline24(BuildContext context, {Color? color}) =>
      TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: color ?? Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle title20(BuildContext context, {Color? color}) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: color ?? Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle body18(
    BuildContext context, {
    Color? color,
    FontWeight weight = FontWeight.w500,
  }) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: weight,
    height: 1.35,
    color: color ?? Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle body16(
    BuildContext context, {
    Color? color,
    FontWeight weight = FontWeight.w500,
  }) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: weight,
    height: 1.35,
    color: color ?? Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle body14(
    BuildContext context, {
    Color? color,
    FontWeight weight = FontWeight.w400,
  }) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: weight,
    height: 1.35,
    color: color ?? Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle body12(
    BuildContext context, {
    Color? color,
    FontWeight weight = FontWeight.w500,
  }) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: weight,
    height: 1.35,
    color: color ?? Theme.of(context).colorScheme.onSurface,
  );

  // Compatibility aliases for existing project files
  static TextStyle headlinew7(BuildContext context, {TextColorRole? color}) =>
      headline24(context, color: textColor(context, color));
  static TextStyle body2w5(BuildContext context, {TextColorRole? color}) =>
      body18(
        context,
        color: textColor(context, color),
        weight: FontWeight.w500,
      );
  static TextStyle bodyw5(BuildContext context, {TextColorRole? color}) =>
      body16(
        context,
        color: textColor(context, color),
        weight: FontWeight.w500,
      );
  static TextStyle bodyw4(BuildContext context, {TextColorRole? color}) =>
      body16(
        context,
        color: textColor(context, color),
        weight: FontWeight.w400,
      );
  static TextStyle small3w4(BuildContext context, {TextColorRole? color}) =>
      body14(
        context,
        color: textColor(context, color),
        weight: FontWeight.w400,
      );
  static TextStyle small2w5(BuildContext context, {TextColorRole? color}) =>
      body12(
        context,
        color: textColor(context, color),
        weight: FontWeight.w500,
      );
}
