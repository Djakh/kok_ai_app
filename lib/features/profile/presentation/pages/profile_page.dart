import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/features/common/presentation/widgets/kok_card.dart';
import 'package:kok_ai_app/router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  /// --- Widgets ---

  Widget profileHeader(BuildContext context) => Container(
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
              onPressed: () => context.go(loginRoute),
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
                    'Sarah Chen',
                    style: Style.title20(context, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Guardian Level 5',
                    style: Style.body14(
                      context,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      userInlineStat(context, '2,540', 'Followers'),
                      userInlineStat(context, '1,132', 'Following'),
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

  Widget userInlineStat(BuildContext context, String value, String label) =>
      Expanded(
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
      );

  Widget statsCardsRow(BuildContext context) => Row(
    children: [
      Expanded(
        child: statCard(
          context,
          Icons.park_rounded,
          '58',
          'Trees',
          AppColors.primary,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: statCard(
          context,
          Icons.monetization_on_rounded,
          '1,240',
          'Coins',
          AppColors.warmEarthBrown,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: statCard(
          context,
          Icons.feed_rounded,
          '86',
          'Posts',
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

  Widget impactCardWithChart(BuildContext context) => KokCard(
    color: const Color(0x1A4CAF6D),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Your Impact',
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
                '2.4t',
                'CO₂ Saved',
                AppColors.primary,
              ),
            ),
            Expanded(
              child: impactMetric(
                context,
                '58',
                'Trees',
                AppColors.warmEarthBrown,
              ),
            ),
            Expanded(
              child: impactMetric(
                context,
                '145',
                'Days',
                AppColors.brightLeafGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(height: 120, child: impactBarChart(context)),
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

  Widget impactBarChart(BuildContext context) {
    final values = [12, 18, 25, 32, 45, 58];
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
                'Today\'s Challenge',
                style: Style.body14(context, weight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                'Register 2 new trees today',
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

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.neutralLight,
    body: SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 92),
        children: [
          profileHeader(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                statsCardsRow(context),
                const SizedBox(height: 10),
                impactCardWithChart(context),
                const SizedBox(height: 10),
                challengeCard(context),
                const SizedBox(height: 10),
                entryTile(
                  context,
                  icon: Icons.emoji_events_rounded,
                  title: 'Achievements',
                  subtitle: '12 unlocked • tap to see all',
                  onTap: () => context.push(achievementsRoute),
                ),
                const SizedBox(height: 10),
                entryTile(
                  context,
                  icon: Icons.military_tech_rounded,
                  title: 'Top Guardians',
                  subtitle: 'Tap to view ranking list',
                  onTap: () => context.push(topGuardiansRoute),
                ),
                const SizedBox(height: 10),
                entryTile(
                  context,
                  icon: Icons.feed_rounded,
                  title: 'Published Posts',
                  subtitle: 'Tap to view your post list',
                  onTap: () => context.push(publishedPostsRoute),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
