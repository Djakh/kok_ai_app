import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/features/common/presentation/widgets/kok_card.dart';
import 'package:kok_ai_app/features/profile/data/models/supported_language.dart';
import 'package:kok_ai_app/features/profile/data/services/profile_api_service.dart';
import 'package:kok_ai_app/injection_container.dart';

class ProfileLocalizationPage extends StatefulWidget {
  const ProfileLocalizationPage({super.key});

  @override
  State<ProfileLocalizationPage> createState() =>
      ProfileLocalizationPageState();
}

class ProfileLocalizationPageState extends State<ProfileLocalizationPage> {
  final profileApiService = sl<ProfileApiService>();

  List<SupportedLanguage> languages = const [
    SupportedLanguage(code: 'en', name: 'English'),
    SupportedLanguage(code: 'ru', name: 'Русский'),
    SupportedLanguage(code: 'uz', name: 'O‘zbek'),
  ];

  @override
  void initState() {
    super.initState();
    loadSupportedLanguages();
  }

  /// --- Methods ---

  Future<void> loadSupportedLanguages() async {
    try {
      final remote = await profileApiService.getSupportedLanguages();
      final supported = remote
          .where((item) => const {'en', 'ru', 'uz'}.contains(item.code))
          .toList();
      if (!mounted || supported.isEmpty) return;
      setState(() => languages = supported);
    } catch (_) {
      // The three contract languages remain available while offline.
    }
  }

  Future<void> onSelectLocale(Locale locale) async {
    await context.setLocale(locale);
    try {
      await profileApiService.updateLocalization(locale.languageCode);
    } catch (_) {}
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
        Expanded(
          child: Text(
            'settings_localization'.tr(),
            style: Style.title20(context),
          ),
        ),
      ],
    ),
  );

  Widget localeCard(BuildContext context, SupportedLanguage language) {
    final locale = Locale(language.code);
    final selected = context.locale.languageCode == language.code;

    return GestureDetector(
      onTap: () => onSelectLocale(locale),
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
                    language.name,
                    style: Style.body16(context, weight: FontWeight.w700),
                  ),
                  Text(
                    language.code.toUpperCase(),
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
                  localeCard(context, languages[index]),
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemCount: languages.length,
            ),
          ),
        ],
      ),
    ),
  );
}
