import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/features/tree/data/models/tree_registration_payload.dart';
import 'package:kok_ai_app/features/tree/data/services/tree_api_service.dart';
import 'package:kok_ai_app/features/tree/data/services/tree_registration_draft_store.dart';
import 'package:kok_ai_app/injection_container.dart';
import 'package:kok_ai_app/router.dart';

class RegisterTreeNamePage extends StatefulWidget {
  const RegisterTreeNamePage({super.key});

  @override
  State<RegisterTreeNamePage> createState() => RegisterTreeNamePageState();
}

class RegisterTreeNamePageState extends State<RegisterTreeNamePage> {
  final treeNameController = TextEditingController();
  final draftStore = sl<TreeRegistrationDraftStore>();
  final treeApiService = sl<TreeApiService>();

  bool showSuccess = false;
  bool isSubmitting = false;
  Timer? timer;
  TreeRegistrationPayload? payload;

  final suggestedNames = const [
    'Grand Oak',
    'Park Maple',
    'Guardian Willow',
    'Street Elm',
    'Noble Pine',
    'Heritage Cedar',
  ];

  /// --- Life cycle ---

  @override
  void dispose() {
    timer?.cancel();
    treeNameController.dispose();
    super.dispose();
  }

  /// --- Methods ---

  Future<void> onRegisterTree() async {
    if (isSubmitting) return;

    final entered = treeNameController.text.trim();
    if (entered.isEmpty) return;

    draftStore.setName(entered);

    final prepared = draftStore.preparePayload();
    if (prepared == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('register_name_incomplete'.tr())));
      return;
    }

    setState(() {
      payload = prepared;
      isSubmitting = true;
    });

    try {
      await treeApiService.registerTree(prepared);
      if (!mounted) return;

      setState(() {
        showSuccess = true;
        isSubmitting = false;
      });

      timer = Timer(const Duration(milliseconds: 2800), () {
        if (!mounted) return;
        context.go(dashboardRoute);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  void onClosePage() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(dashboardRoute);
  }

  /// --- Widgets ---

  Widget successView() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primary, AppColors.brightLeafGreen],
      ),
    ),
    child: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 900),
                curve: Curves.elasticOut,
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.park_rounded,
                    color: AppColors.primary,
                    size: 56,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'register_name_success_title'.tr(),
                style: Style.headline32(context, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                '${treeNameController.text} ${'register_name_success_subtitle'.tr()}',
                style: Style.body16(
                  context,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: Style.border16,
                ),
                child: Text(
                  payload == null
                      ? ''
                      : 'name: ${payload!.name}\nlat: ${payload!.latitude.toStringAsFixed(6)}\nlng: ${payload!.longitude.toStringAsFixed(6)}\naccuracy: ±${payload!.accuracyMeters.toStringAsFixed(1)}m\nfront: ${payload!.frontImagePath}\ntrunk: ${payload!.trunkImagePath}\nleaves: ${payload!.leavesImagePath}',
                  style: Style.body12(
                    context,
                    color: Colors.white,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget topHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Row(
      children: [
        IconButton(
          onPressed: onClosePage,
          icon: const Icon(Icons.close_rounded, color: AppColors.secondary),
        ),
        Expanded(
          child: Center(
            child: Text(
              'register_name_title'.tr(),
              style: Style.body16(context, weight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    ),
  );

  Widget namingForm() => Expanded(
    child: ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      children: [
        Center(
          child: Stack(
            children: [
              Container(
                width: 132,
                height: 132,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.brightLeafGreen],
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.park_rounded,
                  size: 62,
                  color: Colors.white,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text('🌳', style: TextStyle(fontSize: 24)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'register_name_heading'.tr(),
          style: Style.headline28(context),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'register_name_subheading'.tr(),
          style: Style.body14(context, color: AppColors.gray717171),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18),
        TextField(
          controller: treeNameController,
          decoration: InputDecoration(
            hintText: 'register_name_hint'.tr(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: Style.border20,
              borderSide: const BorderSide(
                color: AppColors.grayE8E8E8,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: Style.border20,
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            fillColor: Colors.white,
            filled: true,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'register_name_suggestions'.tr(),
          style: Style.body12(context, color: AppColors.gray717171),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestedNames
              .map(
                (item) => GestureDetector(
                  onTap: () => setState(() => treeNameController.text = item),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: Style.border20,
                      border: Border.all(color: AppColors.grayE8E8E8),
                    ),
                    child: Text(
                      item,
                      style: Style.body12(context, color: AppColors.secondary),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 42),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: onRegisterTree,
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
                    'register_tree_title'.tr(),
                    style: Style.body18(
                      context,
                      color: Colors.white,
                      weight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: showSuccess
        ? successView()
        : Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.neutralLight,
                  Color(0xFFE8F5E9),
                  Color(0xFFC8E6C9),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(children: [topHeader(), namingForm()]),
            ),
          ),
  );
}
