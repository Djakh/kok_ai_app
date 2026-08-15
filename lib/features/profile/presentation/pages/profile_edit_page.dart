import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/features/user/data/services/user_api_service.dart';
import 'package:kok_ai_app/injection_container.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => ProfileEditPageState();
}

class ProfileEditPageState extends State<ProfileEditPage> {
  final userApiService = sl<UserApiService>();
  final nameController = TextEditingController();
  final userNameController = TextEditingController();
  final bioController = TextEditingController();
  bool isLoading = true;
  bool isSaving = false;

  /// --- Life cycle ---

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  @override
  void dispose() {
    nameController.dispose();
    userNameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  /// --- Methods ---

  Future<void> loadUser() async {
    try {
      final user = await userApiService.getMe();
      if (!mounted) return;
      nameController.text = user.fullName ?? '';
      userNameController.text = user.username;
      bioController.text = user.bio ?? '';
      setState(() => isLoading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> onSaveProfile() async {
    if (isSaving) return;
    setState(() => isSaving = true);

    try {
      await userApiService.updateMe(
        fullName: nameController.text.trim(),
        bio: bioController.text.trim(),
      );
      if (!mounted) return;
      setState(() => isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('edit_profile_saved'.tr())));
      context.pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }

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
          child: Text(
            'settings_edit_profile'.tr(),
            style: Style.title20(context),
          ),
        ),
      ],
    ),
  );

  Widget textFieldBox({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    bool readOnly = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Style.body12(context, color: AppColors.gray717171),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: Style.border16,
          borderSide: const BorderSide(color: AppColors.grayE8E8E8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Style.border16,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    ),
  );

  Widget avatarBox(BuildContext context) => Center(
    child: Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 104,
          height: 104,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.brightLeafGreen],
            ),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '🌟',
            style: Style.headline32(context, color: Colors.white),
          ),
        ),
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            color: AppColors.primary,
            size: 18,
          ),
        ),
      ],
    ),
  );

  Widget saveButton(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 54,
    child: ElevatedButton(
      onPressed: onSaveProfile,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: Style.border16),
      ),
      child: isSaving
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : Text(
              'edit_profile_save_changes'.tr(),
              style: Style.body16(
                context,
                color: Colors.white,
                weight: FontWeight.w700,
              ),
            ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.neutralLight,
    body: SafeArea(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                header(context),
                const SizedBox(height: 8),
                avatarBox(context),
                const SizedBox(height: 18),
                textFieldBox(
                  context: context,
                  label: 'edit_profile_name'.tr(),
                  controller: nameController,
                ),
                textFieldBox(
                  context: context,
                  label: 'edit_profile_username'.tr(),
                  controller: userNameController,
                  readOnly: true,
                ),
                textFieldBox(
                  context: context,
                  label: 'edit_profile_bio'.tr(),
                  controller: bioController,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                saveButton(context),
              ],
            ),
    ),
  );
}
