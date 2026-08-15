import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/design_tokens.dart';
import 'package:kok_ai_app/router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// --- Methods ---

  void onTapNavigation(int index) {
    final current = navigationShell.currentIndex;
    navigationShell.goBranch(index, initialLocation: current == index);
  }

  /// --- Widgets ---

  int get visualIndex {
    if (navigationShell.currentIndex < 2) return navigationShell.currentIndex;
    return navigationShell.currentIndex + 1;
  }

  void onDestinationSelected(BuildContext context, int index) {
    if (index == 2) {
      context.push(registerTreeRoute);
      return;
    }
    onTapNavigation(index < 2 ? index : index - 1);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: visualIndex,
      onDestinationSelected: (index) => onDestinationSelected(context, index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map_rounded),
          label: 'Map',
        ),
        NavigationDestination(icon: _AddTreeNavIcon(), label: 'Add Tree'),
        NavigationDestination(
          icon: Icon(Icons.park_outlined),
          selectedIcon: Icon(Icons.park_rounded),
          label: 'My Trees',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    ),
  );
}

class _AddTreeNavIcon extends StatelessWidget {
  const _AddTreeNavIcon();
  @override
  Widget build(BuildContext context) => Container(
    width: 42,
    height: 42,
    decoration: const BoxDecoration(
      color: KokTokens.forest,
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.add_rounded, color: Colors.white),
  );
}
