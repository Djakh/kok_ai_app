import 'dart:io';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/features/tree/data/services/tree_registration_draft_store.dart';
import 'package:kok_ai_app/injection_container.dart';
import 'package:kok_ai_app/router.dart';

class RegisterTreeCameraPage extends StatefulWidget {
  const RegisterTreeCameraPage({super.key});

  @override
  State<RegisterTreeCameraPage> createState() => RegisterTreeCameraPageState();
}

class RegisterTreeCameraPageState extends State<RegisterTreeCameraPage> {
  final draftStore = sl<TreeRegistrationDraftStore>();

  CameraController? cameraController;
  bool isCameraReady = false;
  bool isCapturing = false;
  String cameraErrorText = '';

  int currentStep = 0;
  List<bool> photosTaken = [false, false, false];

  final photoSteps = const [
    ('Tree Front', '🌳', 'Full view of the tree'),
    ('Trunk Close-up', '🪵', 'Bark texture detail'),
    ('Leaves', '🍃', 'Foliage and leaf detail'),
  ];

  /// --- Life cycle ---

  @override
  void initState() {
    super.initState();
    draftStore.reset();
    initializeCameraView();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  /// --- Methods ---

  Future<void> initializeCameraView() async {
    try {
      final cameraList = await availableCameras();

      if (cameraList.isEmpty) {
        setState(() => cameraErrorText = 'No camera found on this device');
        return;
      }

      final selected = cameraList.firstWhere(
        (item) => item.lensDirection == CameraLensDirection.back,
        orElse: () => cameraList.first,
      );

      final controller = CameraController(
        selected,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        cameraController = controller;
        isCameraReady = true;
        cameraErrorText = '';
      });
    } catch (error) {
      setState(() => cameraErrorText = 'Camera init error: $error');
    }
  }

  Future<void> onTakePhoto() async {
    final controller = cameraController;
    if (controller == null || !isCameraReady || isCapturing) return;

    setState(() => isCapturing = true);

    try {
      final capture = await controller.takePicture();
      draftStore.setImageByStep(currentStep, capture.path);

      final list = [...photosTaken];
      list[currentStep] = true;

      if (currentStep < photoSteps.length - 1) {
        setState(() {
          photosTaken = list;
          currentStep = currentStep + 1;
          isCapturing = false;
        });
        return;
      }

      setState(() {
        photosTaken = list;
        isCapturing = false;
      });

      if (!mounted) return;
      context.push(registerTreeLocationRoute);
    } catch (error) {
      if (!mounted) return;
      setState(() => isCapturing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Capture error: $error')));
    }
  }

  String? imagePathByStep(int step) {
    if (step == 0) return draftStore.frontImagePath;
    if (step == 1) return draftStore.trunkImagePath;
    return draftStore.leavesImagePath;
  }

  void onClosePage() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(dashboardRoute);
  }

  /// --- Widgets ---

  Widget topHeader() => Container(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xCC000000), Color(0x00000000)],
      ),
    ),
    child: Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onClosePage,
              icon: const Icon(Icons.close_rounded, color: Colors.white),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'register_tree_title'.tr(),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            photoSteps.length,
            (index) => Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: photosTaken[index]
                        ? AppColors.primary
                        : index == currentStep
                        ? Colors.white.withValues(alpha: 0.24)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: photosTaken[index] || index == currentStep
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.45),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: photosTaken[index]
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 18,
                        )
                      : Text(
                          '${index + 1}',
                          style: Style.body12(
                            context,
                            color: Colors.white,
                            weight: FontWeight.w700,
                          ),
                        ),
                ),
                if (index < photoSteps.length - 1)
                  Container(
                    width: 24,
                    height: 2,
                    color: photosTaken[index]
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.4),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget cameraPreviewLayer() {
    if (cameraErrorText.isNotEmpty) {
      return Center(
        child: Text(
          cameraErrorText,
          style: Style.body14(context, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (!isCameraReady || cameraController == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return SizedBox.expand(child: CameraPreview(cameraController!));
  }

  Widget cameraFrameOverlay() => Center(
    child: Container(
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 3,
        ),
        borderRadius: Style.border24,
      ),
      child: Stack(
        children: [
          if (imagePathByStep(currentStep) != null)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: Style.border24,
                child: Image.file(
                  File(imagePathByStep(currentStep)!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          cornerMarker(top: 0, left: 0),
          cornerMarker(top: 0, right: 0),
          cornerMarker(bottom: 0, left: 0),
          cornerMarker(bottom: 0, right: 0),
        ],
      ),
    ),
  );

  Widget cameraFrame() => Expanded(
    child: Stack(
      children: [
        cameraPreviewLayer(),
        Container(color: Colors.black.withValues(alpha: 0.12)),
        Center(child: IgnorePointer(child: gridOverlay())),
        Positioned(
          left: 0,
          right: 0,
          bottom: 12,
          child: Column(
            children: [
              Text(
                photoSteps[currentStep].$2,
                style: const TextStyle(fontSize: 34),
              ),
              const SizedBox(height: 2),
              Text(
                photoSteps[currentStep].$1,
                style: Style.body16(
                  context,
                  color: Colors.white,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                photoSteps[currentStep].$3,
                style: Style.body12(
                  context,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'register_tree_position_hint'.tr(),
                style: Style.body12(
                  context,
                  color: Colors.white.withValues(alpha: 0.78),
                ),
              ),
            ],
          ),
        ),
        cameraFrameOverlay(),
      ],
    ),
  );

  Widget cornerMarker({
    double? top,
    double? right,
    double? bottom,
    double? left,
  }) => Positioned(
    top: top,
    right: right,
    bottom: bottom,
    left: left,
    child: Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        border: Border(
          top: top != null
              ? const BorderSide(color: Color(0xFF48B978), width: 4)
              : BorderSide.none,
          left: left != null
              ? const BorderSide(color: Color(0xFF48B978), width: 4)
              : BorderSide.none,
          right: right != null
              ? const BorderSide(color: Color(0xFF48B978), width: 4)
              : BorderSide.none,
          bottom: bottom != null
              ? const BorderSide(color: Color(0xFF48B978), width: 4)
              : BorderSide.none,
        ),
      ),
    ),
  );

  Widget gridOverlay() => Row(
    children: List.generate(
      3,
      (col) => Expanded(
        child: Column(
          children: List.generate(
            3,
            (row) => Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                    width: 0.8,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget bottomControls() => Container(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Color(0xE6000000), Color(0x00000000)],
      ),
    ),
    child: Column(
      children: [
        GestureDetector(
          onTap: onTakePhoto,
          child: Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: isCapturing
                ? const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 4),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: List.generate(
            photoSteps.length,
            (index) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: photosTaken[index]
                    ? AppColors.primary
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: Style.border20,
              ),
              child: Text(
                photoSteps[index].$1,
                style: Style.body12(
                  context,
                  color: Colors.white,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: Column(children: [topHeader(), cameraFrame(), bottomControls()]),
    ),
  );
}
