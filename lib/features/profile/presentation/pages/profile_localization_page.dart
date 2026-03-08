import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/features/common/presentation/widgets/kok_card.dart';

class ProfileLocalizationPage extends StatefulWidget {
  const ProfileLocalizationPage({super.key});

  @override
  State<ProfileLocalizationPage> createState() =>
      ProfileLocalizationPageState();
}

class ProfileLocalizationPageState extends State<ProfileLocalizationPage> {
  final localeItems = const [
    (Locale('en'), 'English', 'English'),
    (Locale('ru'), 'Русский', 'Russian'),
    (Locale('uz'), 'O‘zbek', 'Uzbek'),
  ];

  /// --- Methods ---

  Future<void> onSelectLocale(Locale locale) async {
    await context.setLocale(locale);
    if (!mounted) return;
    setState(() {});
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
        Expanded(child: Text('Localization', style: Style.title20(context))),
      ],
    ),
  );

  Widget localeCard(BuildContext context, (Locale, String, String) localeItem) {
    final selected = context.locale.languageCode == localeItem.$1.languageCode;

    return GestureDetector(
      onTap: () => onSelectLocale(localeItem.$1),
      child: KokCard(
        color: selected ? const Color(0x1A4CAF6D) : Colors.white,
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.18)
                    : AppColors.grayE8E8E8.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.language_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localeItem.$2,
                    style: Style.body16(context, weight: FontWeight.w700),
                  ),
                  Text(
                    localeItem.$3,
                    style: Style.body12(context, color: AppColors.gray717171),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.primary : AppColors.grayA0A0A0,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.neutralLight,
    body: SafeArea(
      child: Column(
        children: [
          header(context),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemBuilder: (context, index) =>
                  localeCard(context, localeItems[index]),
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemCount: localeItems.length,
            ),
          ),
        ],
      ),
    ),
  );
}
