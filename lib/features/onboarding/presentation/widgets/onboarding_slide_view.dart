import 'package:flutter/material.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/features/onboarding/data/models/slide_model.dart';
import 'package:kok_ai_app/features/onboarding/presentation/widgets/back_drop.dart';

class OnboardingSlideView extends StatelessWidget {
  const OnboardingSlideView({super.key, required this.slide});

  final SlideModel slide;

  /// --- Widgets ---

  Widget get iconView => Center(
    child: Icon(
      slide.icon,
      size: 220,
      color: Colors.white.withValues(alpha: 0.95),
    ),
  );

  Widget view(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          iconView,
          const SizedBox(height: 8),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: Style.headlinew7(context, color: TextColorRole.whiteColor),
          ),
          const SizedBox(height: 8),
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: Style.bodyw5(context, color: TextColorRole.whiteColor),
          ),
          const SizedBox(height: 96),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: Backdrop(background: slide.background, accent: slide.accent),
      ),
      view(context),
    ],
  );
}
