import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/core/widgets/buttons/button.dart';
import 'package:kok_ai_app/core/widgets/indicators/page_indicator.dart';
import 'package:kok_ai_app/features/onboarding/data/models/slide_model.dart';
import 'package:kok_ai_app/features/onboarding/presentation/widgets/onboarding_slide_view.dart';
import 'package:kok_ai_app/router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => OnboardingPageState();
}

class OnboardingPageState extends State<OnboardingPage> {
  final pageController = PageController();
  int pageIndex = 0;

  List<SlideModel> get slides => [
    SlideModel(
      title: 'Speak Fearlessly'.tr(),
      description:
          'Chat with your AI tutor anytime, anywhere. No judgment, just practice.',
      icon: Icons.record_voice_over_rounded,
      background: AppColors.green49,
      accent: AppColors.green50,
    ),
    SlideModel(
      title: 'Micro-learning'.tr(),
      description:
          'Master new words and grammar with quick, bite-sized exercises every day.',
      icon: Icons.auto_stories_rounded,
      background: AppColors.purpleC3,
      accent: AppColors.purpleD6,
    ),
    SlideModel(
      title: 'See Your Growth'.tr(),
      description:
          'Get instant feedback and track your progress with clear milestones.',
      icon: Icons.insights_rounded,
      background: AppColors.orange13,
      accent: AppColors.orange12,
    ),
  ];

  /// --- Life cycle ---

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  /// --- Methods ---

  void goToHome() {
    context.go(homeRoute);
  }

  void onContinue() {
    if (pageIndex < slides.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    goToHome();
  }

  /// --- Widgets ---

  Widget get header => Row(
    children: [
      Expanded(
        child: PageIndicator(
          currentIndex: pageIndex,
          total: slides.length,
          activeColor: Colors.white.withAlpha(230),
          inactiveColor: Colors.white.withAlpha(140),
          isFilledIndicators: false,
        ),
      ),
      skipButton(),
    ],
  );

  TextButton skipButton() => TextButton(
    onPressed: goToHome,
    child: Text(
      'Skip'.tr(),
      style: Style.small3w4(context, color: TextColorRole.whiteColor),
    ),
  );

  Widget get pageView => PageView.builder(
    controller: pageController,
    itemCount: slides.length,
    onPageChanged: (value) => setState(() => pageIndex = value),
    itemBuilder: (context, index) => OnboardingSlideView(slide: slides[index]),
  );

  Widget get continueButton => Button.border(
    onTap: onContinue,
    text: pageIndex == slides.length - 1 ? 'Get Started'.tr() : 'Continue'.tr(),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        pageView,
        Positioned(
          left: 24,
          right: 24,
          top: 12,
          child: SafeArea(bottom: false, child: header),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: 24,
          child: SafeArea(top: false, child: continueButton),
        ),
      ],
    ),
  );
}
