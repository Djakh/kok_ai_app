import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/features/common/presentation/widgets/kok_card.dart';
import 'package:kok_ai_app/features/tree/data/models/tree_timeline_item.dart';

class TreeProfilePage extends StatelessWidget {
  const TreeProfilePage({super.key, required this.treeId});

  final String treeId;

  List<TreeTimelineItem> get timeline => const [
    TreeTimelineItem(date: 'March 7, 2026', user: 'You', action: 'Viewed tree profile', icon: '👁️'),
    TreeTimelineItem(date: 'March 5, 2026', user: 'Sarah Chen', action: 'Updated tree photo', icon: '📸'),
    TreeTimelineItem(date: 'March 1, 2026', user: 'Mike Johnson', action: 'Reported healthy status', icon: '✅'),
    TreeTimelineItem(date: 'February 28, 2026', user: 'Sarah Chen', action: 'Registered this tree', icon: '🌳'),
  ];

  Widget header(BuildContext context) => Stack(
    children: [
      Container(
        height: 280,
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.warmEarthBrown, AppColors.primary])),
        alignment: Alignment.center,
        child: const Text('🌳', style: TextStyle(fontSize: 92)),
      ),
      Positioned(
        top: 52,
        left: 16,
        child: circleButton(icon: Icons.arrow_back_rounded, onTap: () => context.pop()),
      ),
      Positioned(
        top: 52,
        right: 16,
        child: Row(
          children: [
            circleButton(icon: Icons.favorite_border_rounded, onTap: () {}),
            const SizedBox(width: 8),
            circleButton(icon: Icons.share_rounded, onTap: () {}),
          ],
        ),
      ),
      Positioned(
        left: 16,
        bottom: 14,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: Style.border12),
          child: Text('Healthy', style: Style.body14(context, color: Colors.white, weight: FontWeight.w600)),
        ),
      ),
    ],
  );

  Widget circleButton({required IconData icon, required VoidCallback onTap}) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2), shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 22),
    ),
  );

  Widget infoCard(BuildContext context) => KokCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Grand Oak', style: Style.headline32(context)),
        Text('Quercus robur', style: Style.body14(context, color: AppColors.gray717171).copyWith(fontStyle: FontStyle.italic)),
        const SizedBox(height: 14),
        infoRow(context, Icons.person_rounded, AppColors.primary, 'Guardian', 'Sarah Chen'),
        const SizedBox(height: 10),
        infoRow(context, Icons.location_on_rounded, AppColors.warmEarthBrown, 'Location', 'Central Park, New York', subtitle: '40.7829° N, 73.9654° W'),
        const SizedBox(height: 14),
        const Divider(color: AppColors.grayE8E8E8, height: 1),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: labelValue(context, 'Registered', 'March 5, 2026')),
            Expanded(child: labelValue(context, 'Last Update', '2 days ago')),
          ],
        ),
      ],
    ),
  );

  Widget infoRow(BuildContext context, IconData icon, Color iconColor, String label, String value, {String? subtitle}) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: iconColor, size: 20),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Style.body12(context, color: AppColors.gray717171)),
            Text(value, style: Style.body14(context, weight: FontWeight.w600)),
            if (subtitle != null) Text(subtitle, style: Style.body12(context, color: AppColors.gray717171)),
          ],
        ),
      ),
    ],
  );

  Widget labelValue(BuildContext context, String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Style.body12(context, color: AppColors.gray717171)),
      Text(value, style: Style.body14(context, weight: FontWeight.w600)),
    ],
  );

  Widget environmentalCard(BuildContext context) => KokCard(
    color: const Color(0xFFE8F5E9),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Environmental Data', style: Style.body16(context, weight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: metric(context, Icons.wb_sunny_rounded, AppColors.primary, 'Height', '15m')),
            Expanded(child: metric(context, Icons.water_drop_rounded, AppColors.brightLeafGreen, 'Age', '~45 years')),
            Expanded(child: metric(context, Icons.air_rounded, AppColors.warmEarthBrown, 'CO₂/year', '48kg')),
          ],
        ),
      ],
    ),
  );

  Widget metric(BuildContext context, IconData icon, Color color, String label, String value) => Column(
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(icon, color: color, size: 22),
      ),
      const SizedBox(height: 6),
      Text(label, style: Style.body12(context, color: AppColors.gray717171)),
      Text(value, style: Style.body14(context, weight: FontWeight.w700)),
    ],
  );

  Widget actionButtons(BuildContext context) => Row(
    children: [
      Expanded(child: actionButton(context, Icons.camera_alt_rounded, AppColors.primary, 'Update Photo')),
      const SizedBox(width: 8),
      Expanded(child: actionButton(context, Icons.report_problem_rounded, AppColors.warmEarthBrown, 'Report Issue')),
      const SizedBox(width: 8),
      Expanded(child: actionButton(context, Icons.navigation_rounded, AppColors.brightLeafGreen, 'Visit Tree')),
    ],
  );

  Widget actionButton(BuildContext context, IconData icon, Color color, String text) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: Style.border12, border: Border.all(color: AppColors.grayE8E8E8)),
    child: Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(text, style: Style.body12(context)),
      ],
    ),
  );

  Widget timelineCard(BuildContext context) => KokCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Activity Timeline', style: Style.body16(context, weight: FontWeight.w700)),
        const SizedBox(height: 10),
        ...timeline.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: AppColors.neutralLight, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(item.icon, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 4,
                      children: [
                        Text(item.user, style: Style.body14(context, weight: FontWeight.w700)),
                        Text(item.action, style: Style.body14(context, color: AppColors.gray717171)),
                      ],
                    ),
                    Text(item.date, style: Style.body12(context, color: AppColors.gray717171)),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.neutralLight,
    body: ListView(
      padding: EdgeInsets.zero,
      children: [
        header(context),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              infoCard(context),
              const SizedBox(height: 10),
              environmentalCard(context),
              const SizedBox(height: 10),
              actionButtons(context),
              const SizedBox(height: 10),
              timelineCard(context),
            ],
          ),
        ),
      ],
    ),
  );
}
