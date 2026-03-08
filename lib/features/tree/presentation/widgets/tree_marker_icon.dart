import 'package:flutter/material.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';

enum TreeMarkerStatus { healthy, needsAttention, unknown }

class TreeMarkerIcon extends StatelessWidget {
  const TreeMarkerIcon({super.key, required this.status});

  final TreeMarkerStatus status;

  Color get markerColor {
    switch (status) {
      case TreeMarkerStatus.healthy:
        return AppColors.primary;
      case TreeMarkerStatus.needsAttention:
        return AppColors.warmEarthBrown;
      case TreeMarkerStatus.unknown:
        return AppColors.grayA0A0A0;
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      Container(
        width: 18,
        height: 14,
        decoration: BoxDecoration(color: markerColor, borderRadius: BorderRadius.circular(8)),
      ),
      Positioned(
        bottom: 0,
        child: Container(
          width: 5,
          height: 10,
          decoration: BoxDecoration(color: const Color(0xFF8B4513), borderRadius: BorderRadius.circular(2)),
        ),
      ),
    ],
  );
}
