import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/features/common/presentation/widgets/kok_card.dart';
import 'package:kok_ai_app/router.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => ProfileSettingsPageState();
}

class ProfileSettingsPageState extends State<ProfileSettingsPage> {
  bool pushNotificationsEnabled = true;
  bool privateAccountEnabled = false;
  bool showActivityStatusEnabled = true;
  bool allowTaggingEnabled = true;
  bool autoSavePostsEnabled = true;

  /// --- Widgets ---

  Widget header(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
    child: Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        Expanded(child: Text('Settings', style: Style.title20(context))),
      ],
    ),
  );

  Widget sectionTitle(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
    child: Text(
      title,
      style: Style.body14(
        context,
        color: AppColors.gray717171,
        weight: FontWeight.w700,
      ),
    ),
  );

  Widget actionTile(
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: AppColors.primary),
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

  Widget switchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) => KokCard(
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.warmEarthBrown.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.warmEarthBrown),
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
        Switch(
          value: value,
          activeThumbColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.neutralLight,
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          header(context),
          sectionTitle(context, 'Account'),
          actionTile(
            context,
            icon: Icons.edit_rounded,
            title: 'Edit Profile',
            subtitle: 'Name, username, bio and avatar',
            onTap: () => context.push(profileEditRoute),
          ),
          const SizedBox(height: 10),
          actionTile(
            context,
            icon: Icons.language_rounded,
            title: 'Localization',
            subtitle: 'Choose your app language',
            onTap: () => context.push(profileLocalizationRoute),
          ),
          const SizedBox(height: 10),
          sectionTitle(context, 'Social'),
          actionTile(
            context,
            icon: Icons.favorite_rounded,
            title: 'Liked Posts',
            subtitle: 'Review posts you liked',
            onTap: () => context.push(profileLikedPostsRoute),
          ),
          const SizedBox(height: 10),
          switchTile(
            context,
            icon: Icons.bookmark_rounded,
            title: 'Auto Save My Posts',
            subtitle: 'Store your published posts in personal archive',
            value: autoSavePostsEnabled,
            onChanged: (value) => setState(() => autoSavePostsEnabled = value),
          ),
          const SizedBox(height: 10),
          switchTile(
            context,
            icon: Icons.notifications_active_rounded,
            title: 'Push Notifications',
            subtitle: 'Likes, comments and new followers alerts',
            value: pushNotificationsEnabled,
            onChanged: (value) =>
                setState(() => pushNotificationsEnabled = value),
          ),
          const SizedBox(height: 10),
          sectionTitle(context, 'Privacy & Safety'),
          switchTile(
            context,
            icon: Icons.lock_rounded,
            title: 'Private Account',
            subtitle: 'Only approved followers can see your content',
            value: privateAccountEnabled,
            onChanged: (value) => setState(() => privateAccountEnabled = value),
          ),
          const SizedBox(height: 10),
          switchTile(
            context,
            icon: Icons.visibility_rounded,
            title: 'Show Activity Status',
            subtitle: 'Let people see when you are active',
            value: showActivityStatusEnabled,
            onChanged: (value) =>
                setState(() => showActivityStatusEnabled = value),
          ),
          const SizedBox(height: 10),
          switchTile(
            context,
            icon: Icons.alternate_email_rounded,
            title: 'Allow Tagging',
            subtitle: 'Allow others to mention you in posts',
            value: allowTaggingEnabled,
            onChanged: (value) => setState(() => allowTaggingEnabled = value),
          ),
        ],
      ),
    ),
  );
}
