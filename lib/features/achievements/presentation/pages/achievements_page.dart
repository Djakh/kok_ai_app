import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/features/common/presentation/widgets/kok_card.dart';
import 'package:kok_ai_app/features/profile/data/models/profile_achievement.dart';
import 'package:kok_ai_app/features/profile/data/services/profile_api_service.dart';
import 'package:kok_ai_app/injection_container.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  late Future<List<ProfileAchievement>> _achievements;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _achievements = sl<ProfileApiService>().getAchievements();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.neutralLight,
    appBar: AppBar(
      leading: IconButton(
        onPressed: context.pop,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: Text('Achievements', style: Style.title20(context)),
    ),
    body: FutureBuilder<List<ProfileAchievement>>(
      future: _achievements,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _Message(
            icon: Icons.cloud_off_rounded,
            title: 'Achievements are unavailable',
            action: () => setState(_load),
          );
        }
        final items = snapshot.data ?? const [];
        if (items.isEmpty) {
          return const _Message(
            icon: Icons.emoji_events_outlined,
            title: 'No achievements yet',
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            setState(_load);
            await _achievements;
          },
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: .92,
            ),
            itemBuilder: (context, index) => _AchievementCard(items[index]),
          ),
        );
      },
    ),
  );
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard(this.item);
  final ProfileAchievement item;

  @override
  Widget build(BuildContext context) => KokCard(
    color: item.unlocked ? Colors.white : AppColors.neutralLight,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(item.icon ?? '🏅', style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 7),
        Text(
          item.title,
          textAlign: TextAlign.center,
          style: Style.body14(
            context,
            weight: FontWeight.w700,
            color: item.unlocked ? AppColors.secondary : AppColors.gray717171,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          item.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Style.body12(context, color: AppColors.gray717171),
        ),
        if (item.target != null && item.target! > 0) ...[
          const SizedBox(height: 9),
          LinearProgressIndicator(
            value: ((item.progress ?? 0) / item.target!).clamp(0, 1),
            minHeight: 6,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 3),
          Text(
            '${item.progress ?? 0} / ${item.target}',
            style: Style.body12(context),
          ),
        ],
      ],
    ),
  );
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.title, this.action});
  final IconData icon;
  final String title;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(title, style: Style.body16(context, weight: FontWeight.w700)),
          if (action != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(onPressed: action, child: const Text('Retry')),
          ],
        ],
      ),
    ),
  );
}
