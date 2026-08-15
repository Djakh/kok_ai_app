import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/features/auth/data/services/auth_api_service.dart';
import 'package:kok_ai_app/features/common/presentation/widgets/kok_card.dart';
import 'package:kok_ai_app/features/profile/data/models/profile_stats.dart';
import 'package:kok_ai_app/features/profile/data/services/profile_api_service.dart';
import 'package:kok_ai_app/features/user/data/models/api_user.dart';
import 'package:kok_ai_app/features/user/data/services/user_api_service.dart';
import 'package:kok_ai_app/injection_container.dart';
import 'package:kok_ai_app/router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final userApiService = sl<UserApiService>();
  final profileApiService = sl<ProfileApiService>();

  late Future<(ApiUser, ProfileStats)> profileFuture;

  /// --- Life cycle ---

  @override
  void initState() {
    super.initState();
    profileFuture = loadProfile();
  }

  /// --- Methods ---

  Future<(ApiUser, ProfileStats)> loadProfile() async {
    final user = await userApiService.getMe();
    final stats = await profileApiService.getStats();
    return (user, stats);
  }

  Future<void> onLogout(BuildContext context) async {
    try {
      await sl<AuthApiService>().logout();
    } catch (_) {
      // Local credentials are cleared in AuthApiService even when offline.
    }
    if (!context.mounted) return;
    context.go(loginRoute);
  }

  void onReload() {
    setState(() {
      profileFuture = loadProfile();
    });
  }

  /// --- Widgets ---

  Widget profileHeader(
    BuildContext context,
    ApiUser user,
    ProfileStats stats,
  ) => Container(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.warmEarthBrown,
          AppColors.lightEarthBrown,
          AppColors.primary,
        ],
      ),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () => context.push(profileSettingsRoute),
              icon: const Icon(Icons.settings_rounded, color: Colors.white),
            ),
            IconButton(
              onPressed: () => onLogout(context),
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text('🌟', style: TextStyle(fontSize: 40)),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName ?? user.username,
                    style: Style.title20(context, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${user.username}',
                    style: Style.body14(
                      context,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      userInlineStat(
                        context,
                        '${stats.followersCount}',
                        'profile_followers'.tr(),
                        onTap: () => context.push(
                          '$profileConnectionsRoute/followers/${user.id}',
                        ),
                      ),
                      userInlineStat(
                        context,
                        '${stats.followingCount}',
                        'profile_following'.tr(),
                        onTap: () => context.push(
                          '$profileConnectionsRoute/following/${user.id}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget userInlineStat(
    BuildContext context,
    String value,
    String label, {
    VoidCallback? onTap,
  }) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Style.body16(
                context,
                color: Colors.white,
                weight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: Style.body12(
                context,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget statsCardsRow(BuildContext context, ProfileStats stats) => Row(
    children: [
      Expanded(
        child: statCard(
          context,
          Icons.park_rounded,
          '${stats.treesCount}',
          'profile_trees'.tr(),
          AppColors.primary,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: statCard(
          context,
          Icons.monetization_on_rounded,
          '—',
          'profile_coins'.tr(),
          AppColors.warmEarthBrown,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: statCard(
          context,
          Icons.feed_rounded,
          '${stats.postsCount}',
          'profile_posts'.tr(),
          AppColors.brightLeafGreen,
        ),
      ),
    ],
  );

  Widget statCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color iconColor,
  ) => KokCard(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
    child: Column(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 4),
        Text(value, style: Style.body16(context, weight: FontWeight.w700)),
        Text(label, style: Style.body12(context, color: AppColors.gray717171)),
      ],
    ),
  );

  Widget impactCardWithChart(BuildContext context, ProfileStats stats) =>
      KokCard(
        color: const Color(0x1A4CAF6D),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'profile_your_impact'.tr(),
                    style: Style.body16(context, weight: FontWeight.w700),
                  ),
                ),
                const Icon(
                  Icons.insights_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: impactMetric(
                    context,
                    '${stats.treesCount * 48}kg',
                    'profile_co2_saved'.tr(),
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: impactMetric(
                    context,
                    '${stats.treesCount}',
                    'profile_trees'.tr(),
                    AppColors.warmEarthBrown,
                  ),
                ),
                Expanded(
                  child: impactMetric(
                    context,
                    '${stats.postsCount + stats.treesCount}',
                    'profile_days'.tr(),
                    AppColors.brightLeafGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(height: 120, child: impactBarChart(context, stats)),
          ],
        ),
      );

  Widget impactMetric(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) => Column(
    children: [
      Text(
        value,
        style: Style.body16(context, color: color, weight: FontWeight.w700),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: Style.body12(context, color: AppColors.gray717171),
        textAlign: TextAlign.center,
      ),
    ],
  );

  Widget impactBarChart(BuildContext context, ProfileStats stats) {
    final values = [0, 0, 0, 0, stats.postsCount, stats.treesCount];
    final labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    const maxValue = 60.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(values.length, (index) {
        final color = index.isEven
            ? AppColors.primary
            : AppColors.warmEarthBrown;
        final barHeight = (values[index] / maxValue) * 92;

        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: barHeight,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                labels[index],
                style: Style.body12(context, color: AppColors.gray717171),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget challengeCard(BuildContext context) => KokCard(
    color: const Color(0x1A6BCB77),
    child: Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.emoji_events_rounded, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'profile_todays_challenge'.tr(),
                style: Style.body14(context, weight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                'profile_register_2_trees'.tr(),
                style: Style.body12(context, color: AppColors.gray717171),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: const LinearProgressIndicator(
                  value: 0,
                  minHeight: 8,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget entryTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: KokCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.brightLeafGreen],
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Style.body16(context, weight: FontWeight.w700),
                ),
                Text(
                  subtitle,
                  style: Style.body12(context, color: AppColors.gray717171),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors.primary,
          ),
        ],
      ),
    ),
  );

  Widget profileBody(BuildContext context) =>
      FutureBuilder<(ApiUser, ProfileStats)>(
        future: profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${snapshot.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onReload,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final user = snapshot.data!.$1;
          final stats = snapshot.data!.$2;

          return ListView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 92),
            children: [
              profileHeader(context, user, stats),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  children: [
                    statsCardsRow(context, stats),
                    const SizedBox(height: 10),
                    entryTile(
                      context,
                      icon: Icons.emoji_events_rounded,
                      title: 'profile_achievements'.tr(),
                      subtitle: 'profile_achievements_subtitle'.tr(),
                      onTap: () => context.push(achievementsRoute),
                    ),
                    const SizedBox(height: 10),
                    entryTile(
                      context,
                      icon: Icons.military_tech_rounded,
                      title: 'profile_top_guardians'.tr(),
                      subtitle: 'profile_top_guardians_subtitle'.tr(),
                      onTap: () => context.push(topGuardiansRoute),
                    ),
                    const SizedBox(height: 10),
                    entryTile(
                      context,
                      icon: Icons.feed_rounded,
                      title: 'profile_published_posts'.tr(),
                      subtitle: 'profile_published_posts_subtitle'.tr(),
                      onTap: () => context.push(publishedPostsRoute),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.neutralLight,
    body: SafeArea(bottom: false, child: profileBody(context)),
  );
}
