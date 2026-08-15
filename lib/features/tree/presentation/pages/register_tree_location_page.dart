import 'dart:async';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/features/tree/data/services/tree_registration_draft_store.dart';
import 'package:kok_ai_app/injection_container.dart';
import 'package:kok_ai_app/router.dart';

class RegisterTreeLocationPage extends StatefulWidget {
  const RegisterTreeLocationPage({super.key});

  @override
  State<RegisterTreeLocationPage> createState() =>
      RegisterTreeLocationPageState();
}

class RegisterTreeLocationPageState extends State<RegisterTreeLocationPage> {
  final draftStore = sl<TreeRegistrationDraftStore>();

  Timer? timer;
  int progress = 0;
  bool isVerifying = false;
  String statusText = '';
  Position? capturedPosition;

  /// --- Life cycle ---

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  /// --- Methods ---

  Future<bool> requestLocationPermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      setState(() => statusText = 'register_location_services_disabled'.tr());
      return false;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => statusText = 'register_location_permission_required'.tr());
      return false;
    }

    return true;
  }

  Future<void> captureExactLocation() async {
    final allowed = await requestLocationPermission();
    if (!allowed) return;

    setState(() => statusText = 'register_location_getting'.tr());

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );

    capturedPosition = position;
    draftStore.setLocation(position);
  }

  Future<void> onStartVerification() async {
    if (isVerifying) return;

    setState(() {
      isVerifying = true;
      progress = 5;
      statusText = '';
    });

    try {
      await captureExactLocation();

      if (capturedPosition == null) {
        setState(() {
          isVerifying = false;
          progress = 0;
        });
        return;
      }

      timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (progress >= 100) {
          timer.cancel();
          Future<void>.delayed(const Duration(milliseconds: 500), () {
            if (!mounted) return;
            context.push(registerTreeNameRoute);
          });
          return;
        }

        setState(() => progress = min(progress + 5, 100));
      });
    } catch (error) {
      setState(() {
        isVerifying = false;
        progress = 0;
        statusText = '${'register_location_error'.tr()}: $error';
      });
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

  Widget topHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Row(
      children: [
        IconButton(
          onPressed: onClosePage,
          icon: const Icon(Icons.close_rounded, color: Colors.white),
        ),
        Expanded(
          child: Center(
            child: Text(
              'register_location_verify_title'.tr(),
              style: Style.body16(
                context,
                color: Colors.white,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    ),
  );

  Widget centerView() => Expanded(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.navigation_rounded,
                color: AppColors.primary,
                size: 56,
              ),
            ),
            if (isVerifying)
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: progress / 100,
                  strokeWidth: 8,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                  backgroundColor: Colors.transparent,
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          isVerifying
              ? 'register_location_verifying'.tr()
              : 'register_location_hold_phone'.tr(),
          style: Style.headline28(context, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            isVerifying
                ? 'register_location_keep_close'.tr()
                : 'register_location_touch_tree'.tr(),
            style: Style.body16(
              context,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (capturedPosition != null) ...[
          const SizedBox(height: 10),
          Text(
            'Lat: ${capturedPosition!.latitude.toStringAsFixed(6)}  Lng: ${capturedPosition!.longitude.toStringAsFixed(6)}',
            style: Style.body12(
              context,
              color: Colors.white.withValues(alpha: 0.95),
              weight: FontWeight.w600,
            ),
          ),
          Text(
            'Accuracy: ±${capturedPosition!.accuracy.toStringAsFixed(1)}m',
            style: Style.body12(
              context,
              color: Colors.white.withValues(alpha: 0.95),
              weight: FontWeight.w600,
            ),
          ),
        ],
        if (statusText.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            statusText,
            style: Style.body12(
              context,
              color: Colors.white,
              weight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 18),
        if (isVerifying)
          SizedBox(
            width: 300,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$progress%',
                  style: Style.body16(
                    context,
                    color: Colors.white,
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        if (!isVerifying)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ElevatedButton(
              onPressed: onStartVerification,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: Style.border20),
                minimumSize: const Size(220, 58),
                elevation: 0,
              ),
              child: Text(
                'register_location_start_button'.tr(),
                style: Style.body18(
                  context,
                  color: AppColors.primary,
                  weight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    ),
  );

  Widget tipCard() => Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 22),
    padding: Style.paddingAll16,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: Style.border20,
    ),
    child: Text(
      'register_location_tip'.tr(),
      style: Style.body14(context, color: Colors.white.withValues(alpha: 0.95)),
      textAlign: TextAlign.center,
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.brightLeafGreen],
        ),
      ),
      child: SafeArea(
        child: Column(children: [topHeader(), centerView(), tipCard()]),
      ),
    ),
  );
}
