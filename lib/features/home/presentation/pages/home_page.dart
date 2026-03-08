import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// --- Methods ---

  void onTapNavigation(int index) {
    final current = navigationShell.currentIndex;
    navigationShell.goBranch(index, initialLocation: current == index);
  }

  /// --- Widgets ---

  Widget navigationItem(BuildContext context, int index, IconData icon, String label) {
    final selected = navigationShell.currentIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTapNavigation(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.gray717171, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: Style.body12(
                context,
                color: selected ? AppColors.primary : AppColors.gray717171,
                weight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomNavigation(BuildContext context) => Container(
    decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.grayE8E8E8, width: 1))),
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 68,
        child: Row(
          children: [
            navigationItem(context, 0, Icons.dashboard_rounded, 'Dashboard'),
            navigationItem(context, 1, Icons.map_rounded, 'Map'),
            navigationItem(context, 2, Icons.park_rounded, 'my tees'),
            navigationItem(context, 3, Icons.person_rounded, 'Profile'),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(body: navigationShell, bottomNavigationBar: bottomNavigation(context));
}
