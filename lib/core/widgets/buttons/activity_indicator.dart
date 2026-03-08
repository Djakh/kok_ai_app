import 'package:flutter/material.dart';

class ActivityIndicator extends StatelessWidget {
  const ActivityIndicator({super.key, this.size = 20, this.strokeWidth = 2});

  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CircularProgressIndicator(strokeWidth: strokeWidth),
  );
}
