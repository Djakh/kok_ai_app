import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/features/common/presentation/widgets/kok_card.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  List<(String, String, String, bool)> get achievements => const [
    ('First Tree', 'Registered your first tree', '🌱', true),
    ('Tree Hunter', 'Registered 10 trees', '🎯', true),
    ('Guardian', 'Registered 50 trees', '🛡️', true),
    ('Forest Keeper', 'Registered 100 trees', '🏆', false),
    ('Community Leader', 'Helped 50 people', '⭐', false),
    ('Week Warrior', '7 day streak', '🔥', true),
    ('Tree Analyst', 'Updated 25 tree reports', '📊', false),
    ('Explorer', 'Visited 20 tree locations', '🧭', true),
  ];

  Widget header(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
    child: Row(
      children: [
        IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded)),
        Expanded(child: Text('Achievements', style: Style.title20(context))),
      ],
    ),
  );

  Widget achievementCard(BuildContext context, (String, String, String, bool) item) => KokCard(
    color: item.$4 ? Colors.white : AppColors.neutralLight,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(item.$3, style: TextStyle(fontSize: 36, color: item.$4 ? null : Colors.black38)),
        const SizedBox(height: 6),
        Text(item.$1, textAlign: TextAlign.center, style: Style.body14(context, weight: FontWeight.w700, color: item.$4 ? AppColors.secondary : AppColors.gray717171)),
        const SizedBox(height: 2),
        Text(item.$2, textAlign: TextAlign.center, style: Style.body12(context, color: AppColors.gray717171)),
        if (item.$4)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: Style.border8),
            child: Text('Unlocked', style: Style.body12(context, color: Colors.white, weight: FontWeight.w600)),
          ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.neutralLight,
    body: SafeArea(
      child: Column(
        children: [
          header(context),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: achievements.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1),
              itemBuilder: (context, index) => achievementCard(context, achievements[index]),
            ),
          ),
        ],
      ),
    ),
  );
}
