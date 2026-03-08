import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  /// --- Life cycle ---

  @override
  void initState() {
    super.initState();
    redirectToOnboarding();
  }

  /// --- Methods ---

  Future<void> redirectToOnboarding() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    context.go(onboardingRoute);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Text('kok_ai'.tr(), style: Style.headlinew7(context))),
  );
}
