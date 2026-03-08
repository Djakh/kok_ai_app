import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => ProfileEditPageState();
}

class ProfileEditPageState extends State<ProfileEditPage> {
  final nameController = TextEditingController(text: 'Sarah Chen');
  final userNameController = TextEditingController(text: 'sarah.green');
  final bioController = TextEditingController(
    text: 'Tree guardian and city forest volunteer.',
  );
  final locationController = TextEditingController(text: 'New York, USA');
  final websiteController = TextEditingController(
    text: 'kok.ai/guardians/sarah',
  );

  /// --- Life cycle ---

  @override
  void dispose() {
    nameController.dispose();
    userNameController.dispose();
    bioController.dispose();
    locationController.dispose();
    websiteController.dispose();
    super.dispose();
  }

  /// --- Methods ---

  void onSaveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile changes saved locally')),
    );
    context.pop();
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
        Expanded(child: Text('Edit Profile', style: Style.title20(context))),
      ],
    ),
  );

  Widget textFieldBox({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
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
      child: Text(
        'Save Changes',
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
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          header(context),
          const SizedBox(height: 8),
          avatarBox(context),
          const SizedBox(height: 18),
          textFieldBox(
            context: context,
            label: 'Name',
            controller: nameController,
          ),
          textFieldBox(
            context: context,
            label: 'Username',
            controller: userNameController,
          ),
          textFieldBox(
            context: context,
            label: 'Bio',
            controller: bioController,
            maxLines: 3,
          ),
          textFieldBox(
            context: context,
            label: 'Location',
            controller: locationController,
          ),
          textFieldBox(
            context: context,
            label: 'Website',
            controller: websiteController,
          ),
          const SizedBox(height: 12),
          saveButton(context),
        ],
      ),
    ),
  );
}
