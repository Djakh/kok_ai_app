import 'package:flutter/material.dart';
import 'package:kok_ai_app/assets/themes/style.dart';

class KokCard extends StatelessWidget {
  const KokCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.color,
    this.margin,
  });

  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Color? color;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) => Container(
    margin: margin,
    padding: padding ?? Style.paddingAll16,
    decoration: BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: borderRadius ?? Style.border20,
      boxShadow: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 12,
          offset: Offset(0, 6),
          spreadRadius: 0,
        ),
      ],
    ),
    child: child,
  );
}
