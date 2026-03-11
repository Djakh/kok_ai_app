import 'package:easy_localization/easy_localization.dart';
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
        Expanded(
          child: Text('settings_title'.tr(), style: Style.title20(context)),
        ),
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
          sectionTitle(context, 'settings_account_section'.tr()),
          actionTile(
            context,
            icon: Icons.edit_rounded,
            title: 'settings_edit_profile'.tr(),
            subtitle: 'settings_edit_profile_subtitle'.tr(),
            onTap: () => context.push(profileEditRoute),
          ),
          const SizedBox(height: 10),
          actionTile(
            context,
            icon: Icons.language_rounded,
            title: 'settings_localization'.tr(),
            subtitle: 'settings_localization_subtitle'.tr(),
            onTap: () => context.push(profileLocalizationRoute),
          ),
          const SizedBox(height: 10),
          sectionTitle(context, 'settings_social_section'.tr()),
          actionTile(
            context,
            icon: Icons.favorite_rounded,
            title: 'settings_liked_posts'.tr(),
            subtitle: 'settings_liked_posts_subtitle'.tr(),
            onTap: () => context.push(profileLikedPostsRoute),
          ),
          const SizedBox(height: 10),
          switchTile(
            context,
            icon: Icons.bookmark_rounded,
            title: 'settings_auto_save_posts'.tr(),
            subtitle: 'settings_auto_save_posts_subtitle'.tr(),
            value: autoSavePostsEnabled,
            onChanged: (value) => setState(() => autoSavePostsEnabled = value),
          ),
          const SizedBox(height: 10),
          switchTile(
            context,
            icon: Icons.notifications_active_rounded,
            title: 'settings_push_notifications'.tr(),
            subtitle: 'settings_push_notifications_subtitle'.tr(),
            value: pushNotificationsEnabled,
            onChanged: (value) =>
                setState(() => pushNotificationsEnabled = value),
          ),
          const SizedBox(height: 10),
          sectionTitle(context, 'settings_privacy_section'.tr()),
          switchTile(
            context,
            icon: Icons.lock_rounded,
            title: 'settings_private_account'.tr(),
            subtitle: 'settings_private_account_subtitle'.tr(),
            value: privateAccountEnabled,
            onChanged: (value) => setState(() => privateAccountEnabled = value),
          ),
          const SizedBox(height: 10),
          switchTile(
            context,
            icon: Icons.visibility_rounded,
            title: 'settings_activity_status'.tr(),
            subtitle: 'settings_activity_status_subtitle'.tr(),
            value: showActivityStatusEnabled,
            onChanged: (value) =>
                setState(() => showActivityStatusEnabled = value),
          ),
          const SizedBox(height: 10),
          switchTile(
            context,
            icon: Icons.alternate_email_rounded,
            title: 'settings_allow_tagging'.tr(),
            subtitle: 'settings_allow_tagging_subtitle'.tr(),
            value: allowTaggingEnabled,
            onChanged: (value) => setState(() => allowTaggingEnabled = value),
          ),
        ],
      ),
    ),
  );
}
