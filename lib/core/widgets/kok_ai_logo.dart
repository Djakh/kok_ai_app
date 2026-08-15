import 'package:flutter/material.dart';

/// The reusable KOK.AI brand mark.
///
/// Keep the generated PNG as the single source of truth so the same identity
/// is used across authentication, startup, and future branded surfaces.
class KokAiLogo extends StatelessWidget {
  const KokAiLogo({
    this.size = 96,
    this.semanticLabel = 'KOK.AI logo',
    super.key,
  });

  static const assetPath = 'assets/images/kokai_logo.png';

  final double size;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) => Image.asset(
    assetPath,
    width: size,
    height: size,
    fit: BoxFit.contain,
    filterQuality: FilterQuality.high,
    semanticLabel: semanticLabel,
  );
}
