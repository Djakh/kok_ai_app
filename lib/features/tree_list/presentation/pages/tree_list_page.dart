import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/features/common/presentation/widgets/kok_card.dart';
import 'package:kok_ai_app/router.dart';

class TreeListPage extends StatelessWidget {
  const TreeListPage({super.key});

  List<(String, String, String, String, String)> get trees => const [
    ('1', 'Park Maple', 'Central Park', 'Mar 7, 2026', '🍁'),
    ('2', 'Street Oak', '5th Avenue', 'Mar 5, 2026', '🌳'),
    ('3', 'Garden Willow', 'Riverside Park', 'Mar 3, 2026', '🌿'),
    ('4', 'Plaza Pine', 'Union Square', 'Mar 1, 2026', '🌲'),
    ('5', 'Heritage Cedar', 'Green Avenue', 'Feb 26, 2026', '🌲'),
  ];

  /// --- Widgets ---

  Widget header(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [AppColors.warmEarthBrown, AppColors.lightEarthBrown]),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Trees', style: Style.headline28(context, color: Colors.white)),
        const SizedBox(height: 4),
        Text(
          'All registered trees in your account',
          style: Style.body14(context, color: Colors.white.withValues(alpha: 0.9)),
        ),
      ],
    ),
  );

  Widget treeCard(BuildContext context, (String, String, String, String, String) tree) => GestureDetector(
    onTap: () => context.push('/app/tree/${tree.$1}'),
    child: KokCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.brightLeafGreen]),
              borderRadius: Style.border12,
            ),
            alignment: Alignment.center,
            child: Text(tree.$5, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tree.$2, style: Style.body16(context, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('📍 ${tree.$3}', style: Style.body12(context, color: AppColors.gray717171)),
                Text(tree.$4, style: Style.body12(context, color: AppColors.gray717171)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primary),
        ],
      ),
    ),
  );

  Widget registerTreeFab(BuildContext context) => GestureDetector(
    onTap: () => context.push(registerTreeCameraRoute),
    child: Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.brightLeafGreen]),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 8))],
      ),
      child: const Icon(Icons.park_rounded, color: Colors.white, size: 30),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.neutralLight,
    body: Column(
      children: [
        SafeArea(child: header(context)),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 92),
            itemBuilder: (context, index) => treeCard(context, trees[index]),
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemCount: trees.length,
          ),
        ),
      ],
    ),
    floatingActionButton: registerTreeFab(context),
  );
}
