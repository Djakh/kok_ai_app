import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/features/auth/data/services/auth_api_service.dart';
import 'package:kok_ai_app/features/common/presentation/widgets/kok_gradient_background.dart';
import 'package:kok_ai_app/injection_container.dart';
import 'package:kok_ai_app/router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authApiService = sl<AuthApiService>();
  bool isSubmitting = false;

  /// --- Life cycle ---

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// --- Methods ---

  Future<void> onLogin() async {
    if (isSubmitting) return;
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty || password.isEmpty) return;

    setState(() => isSubmitting = true);
    try {
      await authApiService.login(email: email, password: password);
      if (!mounted) return;
      setState(() => isSubmitting = false);
      context.go(dashboardRoute);
    } catch (error) {
      if (!mounted) return;
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  /// --- Widgets ---

  Widget logo() => Column(
    children: [
      Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.park_rounded, color: Colors.white, size: 48),
      ),
      const SizedBox(height: 16),
      Text('KOK.AI', style: Style.headline32(context, color: Colors.white)),
      const SizedBox(height: 6),
      Text(
        'Protect Urban Trees',
        style: Style.body18(
          context,
          color: Colors.white.withValues(alpha: 0.92),
        ),
      ),
    ],
  );

  Widget inputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) => Container(
    height: 56,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.95),
      borderRadius: Style.border20,
    ),
    padding: Style.paddingH16,
    child: Row(
      children: [
        Icon(icon, color: AppColors.gray717171, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
            ),
          ),
        ),
      ],
    ),
  );

  Widget loginForm() => Column(
    children: [
      inputField(
        controller: emailController,
        hintText: 'Email or phone',
        icon: Icons.mail_outline_rounded,
      ),
      const SizedBox(height: 14),
      inputField(
        controller: passwordController,
        hintText: 'Password',
        icon: Icons.lock_outline_rounded,
        obscureText: true,
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: onLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: Style.border20),
            elevation: 0,
          ),
          child: isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Login',
                  style: Style.body18(
                    context,
                    color: Colors.white,
                    weight: FontWeight.w600,
                  ),
                ),
        ),
      ),
      const SizedBox(height: 14),
      TextButton(
        onPressed: () => context.go(registerRoute),
        child: Text(
          'Don\'t have an account? Register',
          style: Style.body14(
            context,
            color: Colors.white,
            weight: FontWeight.w500,
          ).copyWith(decoration: TextDecoration.underline),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: KokGradientBackground(
      colors: const [
        AppColors.warmEarthBrown,
        AppColors.lightEarthBrown,
        AppColors.primary,
      ],
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [logo(), const SizedBox(height: 36), loginForm()],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
