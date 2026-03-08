import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/features/common/presentation/widgets/kok_gradient_background.dart';
import 'package:kok_ai_app/router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  /// --- Life cycle ---

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  /// --- Methods ---

  void onCreateAccount() {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    context.go(dashboardRoute);
  }

  /// --- Widgets ---

  Widget header() => Column(
    children: [
      Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
        alignment: Alignment.center,
        child: const Icon(Icons.park_rounded, color: Colors.white, size: 40),
      ),
      const SizedBox(height: 12),
      Text('Create Account', style: Style.headline28(context, color: Colors.white)),
      const SizedBox(height: 4),
      Text('Join the tree guardian community', style: Style.body14(context, color: Colors.white.withValues(alpha: 0.92))),
    ],
  );

  Widget inputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) => Container(
    height: 56,
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.95), borderRadius: Style.border20),
    padding: Style.paddingH16,
    child: Row(
      children: [
        Icon(icon, color: AppColors.gray717171, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(border: InputBorder.none, hintText: hintText),
          ),
        ),
      ],
    ),
  );

  Widget form() => Column(
    children: [
      Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
        alignment: Alignment.center,
        child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 32),
      ),
      const SizedBox(height: 14),
      inputField(controller: nameController, hintText: 'Name', icon: Icons.person_outline_rounded),
      const SizedBox(height: 12),
      inputField(controller: emailController, hintText: 'Email or phone', icon: Icons.mail_outline_rounded),
      const SizedBox(height: 12),
      inputField(controller: passwordController, hintText: 'Password', icon: Icons.lock_outline_rounded, obscureText: true),
      const SizedBox(height: 12),
      inputField(
        controller: confirmPasswordController,
        hintText: 'Confirm password',
        icon: Icons.lock_outline_rounded,
        obscureText: true,
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: onCreateAccount,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: Style.border20),
            elevation: 0,
          ),
          child: Text('Create Account', style: Style.body18(context, color: AppColors.primary, weight: FontWeight.w600)),
        ),
      ),
      const SizedBox(height: 12),
      TextButton(
        onPressed: () => context.go(loginRoute),
        child: Text(
          'Already have an account? Login',
          style: Style.body14(context, color: Colors.white, weight: FontWeight.w500).copyWith(decoration: TextDecoration.underline),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: KokGradientBackground(
      colors: const [AppColors.primary, AppColors.brightLeafGreen, AppColors.warmEarthBrown],
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                children: [
                  header(),
                  const SizedBox(height: 28),
                  form(),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
