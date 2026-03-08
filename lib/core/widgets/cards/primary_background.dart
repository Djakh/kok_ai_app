import 'package:flutter/material.dart';
import 'package:kok_ai_app/assets/themes/style.dart';

class PrimaryBackground extends StatelessWidget {
  const PrimaryBackground({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding ?? Style.paddingAll16,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: Style.border24,
      boxShadow: const [
        BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 8), spreadRadius: 1),
      ],
    ),
    child: child,
  );
}
