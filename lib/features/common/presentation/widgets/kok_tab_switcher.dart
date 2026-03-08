import 'package:flutter/material.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';

class KokTabSwitcher extends StatelessWidget {
  const KokTabSwitcher({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onChanged,
  });

  final List<String> tabs;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  Widget tabButton(BuildContext context, int index) => Expanded(
    child: GestureDetector(
      onTap: () => onChanged(index),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: index == currentIndex ? AppColors.primary : Colors.transparent,
          borderRadius: Style.border12,
        ),
        child: Text(
          tabs[index],
          style: Style.body14(
            context,
            weight: FontWeight.w600,
            color: index == currentIndex ? Colors.white : AppColors.gray717171,
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(color: Colors.white, borderRadius: Style.border12),
    child: Row(children: List.generate(tabs.length, (index) => tabButton(context, index))),
  );
}
