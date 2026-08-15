import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kok_ai_app/assets/themes/design_tokens.dart';
import 'package:kok_ai_app/core/network/api_config.dart';
import 'package:kok_ai_app/features/tree_registration/domain/entities/tree_models.dart';
import 'package:kok_ai_app/features/tree_registration/domain/services/location_quality_service.dart';
import 'package:kok_ai_app/features/tree_registration/presentation/controller/tree_registration_cubit.dart';
import 'package:kok_ai_app/injection_container.dart';
import 'package:permission_handler/permission_handler.dart' as permissions;

class TreeRegistrationPage extends StatelessWidget {
  const TreeRegistrationPage({super.key, this.cubit});

  final TreeRegistrationCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final providedCubit = cubit;
    if (providedCubit != null) {
      return BlocProvider.value(
        value: providedCubit,
        child: const _RegistrationView(),
      );
    }
    return BlocProvider(
      create: (_) => sl<TreeRegistrationCubit>()..restore(),
      child: const _RegistrationView(),
    );
  }
}

class _RegistrationView extends StatelessWidget {
  const _RegistrationView();

  static const titles = [
    'Before you begin',
    'Guided photos',
    'Tree location',
    'Tree analysis',
    'Review identification',
    'Nearby tree check',
    'Confirm registration',
    'Tree registered',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TreeRegistrationCubit, TreeRegistrationState>(
      builder: (context, state) {
        return PopScope(
          canPop: state.stage == RegistrationStage.introduction,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) context.read<TreeRegistrationCubit>().back();
          },
          child: Scaffold(
            appBar: state.stage == RegistrationStage.success
                ? null
                : AppBar(
                    leading: IconButton(
                      tooltip: state.stage == RegistrationStage.introduction
                          ? 'Close registration'
                          : 'Previous step',
                      onPressed: () {
                        if (state.stage == RegistrationStage.introduction) {
                          context.pop();
                        } else {
                          context.read<TreeRegistrationCubit>().back();
                        }
                      },
                      icon: Icon(
                        state.stage == RegistrationStage.introduction
                            ? Icons.close_rounded
                            : Icons.arrow_back_rounded,
                      ),
                    ),
                    title: Text(titles[state.stage.index]),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(24),
                      child: _ProgressHeader(stage: state.stage),
                    ),
                  ),
            body: SafeArea(
              top: state.stage == RegistrationStage.success,
              child: AnimatedSwitcher(
                duration: KokTokens.motionStandard,
                child: KeyedSubtree(
                  key: ValueKey(state.stage),
                  child: _stage(context, state),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _stage(BuildContext context, TreeRegistrationState state) {
    switch (state.stage) {
      case RegistrationStage.introduction:
        return _IntroductionStep(state: state);
      case RegistrationStage.photos:
        return _PhotoStep(state: state);
      case RegistrationStage.location:
        return _LocationStep(state: state);
      case RegistrationStage.analysis:
        return _AnalysisStep(state: state);
      case RegistrationStage.identification:
        return _IdentificationStep(state: state);
      case RegistrationStage.duplicates:
        return _DuplicateStep(state: state);
      case RegistrationStage.confirmation:
        return _ConfirmationStep(state: state);
      case RegistrationStage.success:
        return _SuccessStep(state: state);
    }
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.stage});
  final RegistrationStage stage;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
    child: Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(KokTokens.radiusPill),
            child: LinearProgressIndicator(
              value: (stage.index + 1) / RegistrationStage.values.length,
              minHeight: 5,
              backgroundColor: KokTokens.outline,
              color: KokTokens.leaf,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${stage.index + 1} of ${RegistrationStage.values.length}',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: KokTokens.inkMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _IntroductionStep extends StatelessWidget {
  const _IntroductionStep({required this.state});
  final TreeRegistrationState state;

  @override
  Widget build(BuildContext context) => _StepScaffold(
    body: ListView(
      padding: const EdgeInsets.all(KokTokens.space20),
      children: [
        if (ApiConfig.useFixtures) const _DemoBanner(),
        if (state.resumed) ...[
          const SizedBox(height: 12),
          const _NoticeCard(
            icon: Icons.history_rounded,
            title: 'Draft restored',
            message: 'Your photos and location remain on this device.',
          ),
        ],
        const SizedBox(height: 20),
        Container(
          height: 184,
          decoration: BoxDecoration(
            color: KokTokens.forest,
            borderRadius: BorderRadius.circular(KokTokens.radiusLarge),
          ),
          padding: const EdgeInsets.all(24),
          child: const Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'One tree. Clear evidence.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Photos, a measured location, and your confirmation create a trustworthy record.',
                      style: TextStyle(color: Color(0xFFD9EDE3), height: 1.35),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Icon(Icons.park_rounded, color: KokTokens.lime, size: 76),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Capture safely', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        const _InstructionRow(
          icon: Icons.center_focus_strong_rounded,
          text:
              'Photograph one physical tree: the whole tree, leaves, and bark when possible.',
        ),
        const _InstructionRow(
          icon: Icons.health_and_safety_outlined,
          text:
              'Stand safely near the trunk. Do not enter restricted property or include private people.',
        ),
        const _InstructionRow(
          icon: Icons.location_searching_rounded,
          text:
              'Keep the phone mostly still while several GPS readings are collected. Accuracy varies by device and surroundings.',
        ),
        const _InstructionRow(
          icon: Icons.psychology_alt_outlined,
          text:
              'AI identification is a suggestion. You will review it before saving.',
        ),
      ],
    ),
    action: ElevatedButton.icon(
      key: const Key('start-registration'),
      onPressed: context.read<TreeRegistrationCubit>().start,
      icon: const Icon(Icons.arrow_forward_rounded),
      label: const Text('Start guided registration'),
    ),
  );
}

class _PhotoStep extends StatefulWidget {
  const _PhotoStep({required this.state});
  final TreeRegistrationState state;

  @override
  State<_PhotoStep> createState() => _PhotoStepState();
}

class _PhotoStepState extends State<_PhotoStep> {
  final _picker = ImagePicker();
  bool _capturing = false;
  bool _permanentlyDenied = false;

  static const slots = [
    (
      TreePhotoType.wholeTree,
      'Whole tree',
      'Required · include the full crown and trunk',
      Icons.park_outlined,
    ),
    (
      TreePhotoType.leaf,
      'Leaf or needles',
      'Required when available · fill the frame',
      Icons.eco_outlined,
    ),
    (
      TreePhotoType.bark,
      'Bark / trunk',
      'Strongly recommended · capture texture',
      Icons.texture_rounded,
    ),
    (
      TreePhotoType.flowerOrFruit,
      'Flower or fruit',
      'Optional · capture reproductive features',
      Icons.local_florist_outlined,
    ),
    (
      TreePhotoType.additional,
      'Additional view',
      'Optional · another useful angle',
      Icons.add_a_photo_outlined,
    ),
  ];

  Future<void> _capture(TreePhotoType type) async {
    if (_capturing) return;
    setState(() => _capturing = true);
    try {
      final status = await permissions.Permission.camera.request();
      if (status.isPermanentlyDenied) {
        setState(() => _permanentlyDenied = true);
        return;
      }
      if (!status.isGranted) return;
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 88,
        maxWidth: 2400,
        maxHeight: 2400,
        requestFullMetadata: false,
      );
      if (photo != null && mounted) {
        await context.read<TreeRegistrationCubit>().setPhoto(type, photo.path);
      }
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return _StepScaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '${state.photos.length} of ${slots.length} views captured',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'Each photo keeps its category so the backend can interpret it correctly.',
            style: TextStyle(color: KokTokens.inkMuted),
          ),
          if (_permanentlyDenied) ...[
            const SizedBox(height: 12),
            _NoticeCard(
              icon: Icons.no_photography_outlined,
              title: 'Camera access is blocked',
              message:
                  'Enable camera access in system settings, then try again.',
              actionLabel: 'Open settings',
              onAction: permissions.openAppSettings,
            ),
          ],
          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            _ErrorNotice(message: state.errorMessage!),
          ],
          const SizedBox(height: 16),
          ...slots.map((slot) {
            TreePhotoDraft? photo;
            for (final item in state.photos) {
              if (item.type == slot.$1) photo = item;
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PhotoSlot(
                type: slot.$1,
                title: slot.$2,
                subtitle: slot.$3,
                icon: slot.$4,
                photo: photo,
                isBusy: _capturing,
                onCapture: () => _capture(slot.$1),
                onRemove: photo == null
                    ? null
                    : () => context.read<TreeRegistrationCubit>().removePhoto(
                        slot.$1,
                      ),
              ),
            );
          }),
        ],
      ),
      action: ElevatedButton(
        key: const Key('continue-from-photos'),
        onPressed: _capturing
            ? null
            : context.read<TreeRegistrationCubit>().continueFromPhotos,
        child: const Text('Continue to location'),
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.photo,
    required this.isBusy,
    required this.onCapture,
    this.onRemove,
  });
  final TreePhotoType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final TreePhotoDraft? photo;
  final bool isBusy;
  final VoidCallback onCapture;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 72,
              height: 72,
              child: photo == null
                  ? const ColoredBox(
                      color: KokTokens.surfaceMuted,
                      child: Icon(
                        Icons.add_a_photo_outlined,
                        color: KokTokens.leaf,
                      ),
                    )
                  : Image.file(
                      File(photo!.localPath),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const ColoredBox(
                        color: KokTokens.surfaceMuted,
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: KokTokens.forest),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (photo != null)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: KokTokens.success,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: KokTokens.inkMuted),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  children: [
                    TextButton(
                      onPressed: isBusy ? null : onCapture,
                      child: Text(photo == null ? 'Capture' : 'Retake'),
                    ),
                    if (onRemove != null)
                      TextButton(
                        onPressed: onRemove,
                        child: const Text('Remove'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _LocationStep extends StatefulWidget {
  const _LocationStep({required this.state});
  final TreeRegistrationState state;

  @override
  State<_LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends State<_LocationStep> {
  static const _captureSeconds = 12;
  final _qualityService = const LocationQualityService();
  final _samples = <LocationSample>[];
  StreamSubscription<Position>? _subscription;
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _collecting = false;
  bool _permissionDeniedForever = false;
  String? _error;
  double? _liveAccuracy;

  @override
  void dispose() {
    _subscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startCapture() async {
    if (_collecting) return;
    if (!await Geolocator.isLocationServiceEnabled()) {
      setState(
        () => _error =
            'Location services are off. Enable them to collect a tree position.',
      );
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() => _permissionDeniedForever = true);
      return;
    }
    if (permission == LocationPermission.denied) {
      setState(
        () => _error =
            'Location permission was denied. Your photos remain saved in the draft.',
      );
      return;
    }

    _samples.clear();
    setState(() {
      _collecting = true;
      _elapsedSeconds = 0;
      _error = null;
      _liveAccuracy = null;
    });
    _subscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 0,
          ),
        ).listen(
          (position) {
            final sample = LocationSample(
              latitude: position.latitude,
              longitude: position.longitude,
              horizontalAccuracyMeters: position.accuracy,
              altitudeMeters: position.altitude,
              altitudeAccuracyMeters: position.altitudeAccuracy,
              recordedAt: position.timestamp,
            );
            if (mounted) {
              setState(() {
                _samples.add(sample);
                _liveAccuracy = position.accuracy;
              });
            }
          },
          onError: (Object error) => _finish(
            errorMessage:
                'Location updates stopped unexpectedly. Please retry.',
          ),
        );
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _elapsedSeconds += 1);
      if (_elapsedSeconds >= _captureSeconds) _finish();
    });
  }

  Future<void> _finish({String? errorMessage}) async {
    await _subscription?.cancel();
    _timer?.cancel();
    if (!mounted) return;
    if (errorMessage != null) {
      setState(() {
        _collecting = false;
        _error = errorMessage;
      });
      return;
    }
    try {
      final evidence = _qualityService.calculate(
        _samples,
        captureDuration: Duration(seconds: _elapsedSeconds),
      );
      await context.read<TreeRegistrationCubit>().setLocation(evidence);
      if (mounted) setState(() => _collecting = false);
    } on InsufficientLocationSamples catch (error) {
      setState(() {
        _collecting = false;
        _error =
            'Only ${error.acceptedCount} reliable readings were collected. Move to a clearer position near the same tree and retry.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final evidence = widget.state.location;
    return _StepScaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _NoticeCard(
            icon: Icons.my_location_rounded,
            title: 'Stay still near the trunk',
            message:
                'We collect several foreground GPS readings for 12 seconds. Walking around records your path and does not improve the tree coordinate.',
          ),
          if (_permissionDeniedForever) ...[
            const SizedBox(height: 12),
            _NoticeCard(
              icon: Icons.location_disabled_rounded,
              title: 'Location access is blocked',
              message: 'Enable location while using KOK.AI in system settings.',
              actionLabel: 'Open settings',
              onAction: Geolocator.openAppSettings,
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            _ErrorNotice(message: _error!),
          ],
          const SizedBox(height: 24),
          if (_collecting)
            _LocationCollecting(
              progress: _elapsedSeconds / _captureSeconds,
              secondsRemaining: _captureSeconds - _elapsedSeconds,
              accuracy: _liveAccuracy,
              sampleCount: _samples.length,
            )
          else if (evidence == null)
            Center(
              child: Column(
                children: [
                  const _AccuracyRings(quality: null),
                  const SizedBox(height: 18),
                  Text(
                    'Ready to measure',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Camera permission is not needed for this step.',
                    style: TextStyle(color: KokTokens.inkMuted),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    key: const Key('start-location-capture'),
                    onPressed: _startCapture,
                    icon: const Icon(Icons.location_searching_rounded),
                    label: const Text('Collect location'),
                  ),
                ],
              ),
            )
          else
            _LocationResult(evidence: evidence, onRetry: _startCapture),
        ],
      ),
      action: evidence == null || _collecting
          ? null
          : ElevatedButton.icon(
              key: const Key('analyze-tree'),
              onPressed: context.read<TreeRegistrationCubit>().analyze,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: Text(
                evidence.quality == LocationQuality.poor
                    ? 'Continue with accuracy warning'
                    : 'Confirm location & analyze',
              ),
            ),
    );
  }
}

class _LocationCollecting extends StatelessWidget {
  const _LocationCollecting({
    required this.progress,
    required this.secondsRemaining,
    required this.accuracy,
    required this.sampleCount,
  });
  final double progress;
  final int secondsRemaining;
  final double? accuracy;
  final int sampleCount;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Stack(
        alignment: Alignment.center,
        children: [
          const _AccuracyRings(quality: null),
          SizedBox(
            width: 184,
            height: 184,
            child: CircularProgressIndicator(
              value: progress.clamp(0, 1),
              strokeWidth: 7,
              color: KokTokens.leaf,
              backgroundColor: KokTokens.outline,
            ),
          ),
        ],
      ),
      const SizedBox(height: 18),
      Text(
        '$secondsRemaining seconds remaining',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 8),
      Text(
        accuracy == null
            ? 'Waiting for a satellite fix…'
            : 'Live accuracy ±${accuracy!.toStringAsFixed(1)} m',
        style: const TextStyle(color: KokTokens.inkMuted),
      ),
      Text(
        '$sampleCount readings received',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  );
}

class _AccuracyRings extends StatelessWidget {
  const _AccuracyRings({required this.quality});
  final LocationQuality? quality;

  @override
  Widget build(BuildContext context) {
    final color = quality == LocationQuality.poor
        ? KokTokens.warning
        : KokTokens.leaf;
    return SizedBox(
      width: 184,
      height: 184,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 184,
            height: 184,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: .08),
            ),
          ),
          Container(
            width: 126,
            height: 126,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: .12),
            ),
          ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            child: const Icon(
              Icons.my_location_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationResult extends StatelessWidget {
  const _LocationResult({required this.evidence, required this.onRetry});
  final TreeLocationEvidence evidence;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final position = LatLng(evidence.latitude, evidence.longitude);
    final poor = evidence.quality == LocationQuality.poor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 220,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(KokTokens.radiusLarge),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: position, zoom: 18),
              markers: {
                Marker(
                  markerId: const MarkerId('captured-tree'),
                  position: position,
                ),
              },
              circles: {
                Circle(
                  circleId: const CircleId('accuracy'),
                  center: position,
                  radius: evidence.horizontalAccuracyMeters,
                  fillColor: KokTokens.leaf.withValues(alpha: .16),
                  strokeColor: KokTokens.leaf,
                  strokeWidth: 2,
                ),
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              liteModeEnabled: Platform.isAndroid,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _QualityBadge(quality: evidence.quality),
            const Spacer(),
            Text(
              '±${evidence.horizontalAccuracyMeters.toStringAsFixed(1)} m',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${evidence.acceptedSampleCount} accepted · ${evidence.rejectedSampleCount} rejected · best sample ±${evidence.bestSampleAccuracyMeters.toStringAsFixed(1)} m',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: KokTokens.inkMuted),
        ),
        if (poor) ...[
          const SizedBox(height: 12),
          const _NoticeCard(
            icon: Icons.warning_amber_rounded,
            title: 'Poor GPS precision',
            message:
                'Buildings, roofs, and dense foliage can reduce GNSS accuracy. Retry from a clearer position close to the same tree, or continue with the recorded warning.',
            warning: true,
          ),
        ],
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Measure again'),
        ),
      ],
    );
  }
}

class _AnalysisStep extends StatefulWidget {
  const _AnalysisStep({required this.state});
  final TreeRegistrationState state;

  @override
  State<_AnalysisStep> createState() => _AnalysisStepState();
}

class _AnalysisStepState extends State<_AnalysisStep> {
  int _messageIndex = 0;
  Timer? _messageTimer;
  static const messages = [
    'Uploading photographs',
    'Analysing visible characteristics',
    'Comparing possible species',
    'Preparing results',
  ];

  @override
  void initState() {
    super.initState();
    _messageTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        setState(
          () =>
              _messageIndex = (_messageIndex + 1).clamp(0, messages.length - 1),
        );
      }
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(strokeWidth: 6),
          ),
          const SizedBox(height: 28),
          Text(
            messages[_messageIndex],
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'This may take a moment. No percentage is shown because the backend does not report exact progress.',
            textAlign: TextAlign.center,
            style: TextStyle(color: KokTokens.inkMuted),
          ),
          if (widget.state.errorMessage != null) ...[
            const SizedBox(height: 20),
            _ErrorNotice(message: widget.state.errorMessage!),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: context.read<TreeRegistrationCubit>().analyze,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry analysis'),
            ),
          ],
        ],
      ),
    ),
  );
}

class _IdentificationStep extends StatefulWidget {
  const _IdentificationStep({required this.state});
  final TreeRegistrationState state;

  @override
  State<_IdentificationStep> createState() => _IdentificationStepState();
}

class _IdentificationStepState extends State<_IdentificationStep> {
  bool _manual = false;
  final _manualController = TextEditingController();

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analysis = widget.state.analysis!;
    return _StepScaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _NoticeCard(
            icon: Icons.auto_awesome_rounded,
            title: 'AI-generated suggestion',
            message:
                'Confirm important identifications with a specialist. The original AI result is retained if you make a correction.',
          ),
          const SizedBox(height: 18),
          if (analysis.candidates.isEmpty)
            const _NoticeCard(
              icon: Icons.help_outline_rounded,
              title: 'No confident match',
              message:
                  'You can register this tree as unknown or enter a scientific name if you know it.',
            )
          else
            ...analysis.candidates.asMap().entries.map((entry) {
              final candidate = entry.value;
              final selected =
                  widget.state.selectedCandidateId == candidate.id && !_manual;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  color: selected
                      ? KokTokens.forestContainer
                      : KokTokens.surface,
                  child: ListTile(
                    onTap: () {
                      setState(() => _manual = false);
                      context.read<TreeRegistrationCubit>().selectCandidate(
                        candidate.id,
                      );
                    },
                    leading: Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: selected ? KokTokens.forest : KokTokens.inkMuted,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            candidate.displayName,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Text(
                          '${(candidate.confidence * 100).round()}%',
                          style: const TextStyle(
                            color: KokTokens.forest,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidate.scientificName,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                        if (candidate.genus != null || candidate.family != null)
                          Text(
                            [
                              candidate.genus,
                              candidate.family,
                            ].whereType<String>().join(' · '),
                          ),
                        if (entry.key == 0 &&
                            candidate.description != null) ...[
                          const SizedBox(height: 6),
                          Text(candidate.description!),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          Card(
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    setState(() => _manual = true);
                    context.read<TreeRegistrationCubit>().selectCandidate(null);
                  },
                  leading: Icon(
                    _manual
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: _manual ? KokTokens.forest : KokTokens.inkMuted,
                  ),
                  title: const Text(
                    'Use a correction or mark unknown',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                if (_manual)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: TextField(
                      controller: _manualController,
                      onChanged: context
                          .read<TreeRegistrationCubit>()
                          .setManualIdentification,
                      decoration: const InputDecoration(
                        labelText: 'Scientific name (optional)',
                        hintText: 'Leave empty for unknown',
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Analysis provider: ${analysis.providerName}'
            '${analysis.analyzedAt == null ? '' : ' · ${_dateTime(analysis.analyzedAt!)}'}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: KokTokens.inkMuted),
          ),
        ],
      ),
      action: ElevatedButton(
        key: const Key('check-nearby-trees'),
        onPressed: widget.state.isBusy
            ? null
            : context.read<TreeRegistrationCubit>().checkDuplicates,
        child: widget.state.isBusy
            ? const _ButtonSpinner()
            : const Text('Check nearby trees'),
      ),
    );
  }
}

class _DuplicateStep extends StatelessWidget {
  const _DuplicateStep({required this.state});
  final TreeRegistrationState state;

  @override
  Widget build(BuildContext context) {
    final hasMatches =
        state.duplicateCheckStatus == DuplicateCheckStatus.possibleMatches;
    return _StepScaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(
            hasMatches ? Icons.content_copy_rounded : Icons.task_alt_rounded,
            size: 54,
            color: hasMatches ? KokTokens.warning : KokTokens.success,
          ),
          const SizedBox(height: 14),
          Text(
            hasMatches
                ? '${state.nearbyTrees.length} possible ${state.nearbyTrees.length == 1 ? 'match' : 'matches'} nearby'
                : state.duplicateCheckStatus ==
                      DuplicateCheckStatus.skippedDueToNetworkFailure
                ? 'Nearby check unavailable'
                : 'No nearby trees found',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Distance is only a clue. Neighbouring trees can share overlapping smartphone GPS accuracy.',
            textAlign: TextAlign.center,
            style: TextStyle(color: KokTokens.inkMuted),
          ),
          const SizedBox(height: 20),
          ...state.nearbyTrees.map(
            (candidate) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidate.displayName ??
                            candidate.scientificName ??
                            'Existing tree',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (candidate.scientificName != null)
                        Text(
                          candidate.scientificName!,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        '${candidate.distanceMeters.toStringAsFixed(1)} m away${candidate.horizontalAccuracyMeters == null ? '' : ' · recorded ±${candidate.horizontalAccuracyMeters!.toStringAsFixed(1)} m'}',
                      ),
                      Text('Registered ${_date(candidate.registeredAt)}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () =>
                                context.push('/app/tree/${candidate.treeId}'),
                            child: const Text('Inspect tree'),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: state.isBusy
                                ? null
                                : () => context
                                      .read<TreeRegistrationCubit>()
                                      .addScanToExistingTree(candidate.treeId),
                            icon: const Icon(Icons.check_rounded),
                            label: state.isBusy
                                ? const _ButtonSpinner()
                                : const Text('Same tree'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (state.duplicateCheckStatus ==
              DuplicateCheckStatus.skippedDueToNetworkFailure)
            const _NoticeCard(
              icon: Icons.cloud_off_outlined,
              title: 'Could not verify duplicates',
              message:
                  'You may continue, but the saved record will note that this check was skipped.',
            ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            _ErrorNotice(message: state.errorMessage!),
          ],
        ],
      ),
      action: ElevatedButton(
        key: const Key('continue-as-new-tree'),
        onPressed: context.read<TreeRegistrationCubit>().continueAsNewTree,
        child: Text(hasMatches ? 'This is a new tree' : 'Continue'),
      ),
    );
  }
}

class _ConfirmationStep extends StatefulWidget {
  const _ConfirmationStep({required this.state});
  final TreeRegistrationState state;

  @override
  State<_ConfirmationStep> createState() => _ConfirmationStepState();
}

class _ConfirmationStepState extends State<_ConfirmationStep> {
  late final TextEditingController _nickname = TextEditingController(
    text: widget.state.nickname,
  );
  late final TextEditingController _notes = TextEditingController(
    text: widget.state.notes,
  );
  late String _visibility = widget.state.visibility;

  @override
  void dispose() {
    _nickname.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final cubit = context.read<TreeRegistrationCubit>();
    await cubit.updateDetails(
      nickname: _nickname.text,
      notes: _notes.text,
      visibility: _visibility,
    );
    await cubit.createTree();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final candidate = state.selectedCandidate;
    final species = state.manualScientificName?.isNotEmpty == true
        ? state.manualScientificName!
        : candidate?.displayName ?? 'Unknown species';
    return _StepScaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Review the evidence',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          const Text(
            'Nothing is created until you explicitly confirm.',
            style: TextStyle(color: KokTokens.inkMuted),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _ReviewRow(
                    icon: Icons.eco_outlined,
                    label: 'Identification',
                    value: species,
                  ),
                  _ReviewRow(
                    icon: Icons.auto_awesome_rounded,
                    label: 'AI evidence',
                    value: candidate == null
                        ? 'Unknown or user correction'
                        : '${(candidate.confidence * 100).round()}% · ${state.analysis!.providerName}',
                  ),
                  _ReviewRow(
                    icon: Icons.photo_library_outlined,
                    label: 'Photographs',
                    value: '${state.photos.length} categorised views',
                  ),
                  _ReviewRow(
                    icon: Icons.my_location_rounded,
                    label: 'Location',
                    value:
                        '${state.location!.latitude.toStringAsFixed(6)}, ${state.location!.longitude.toStringAsFixed(6)} · ±${state.location!.horizontalAccuracyMeters.toStringAsFixed(1)} m',
                  ),
                  _ReviewRow(
                    icon: Icons.copy_all_outlined,
                    label: 'Duplicate check',
                    value: _duplicateLabel(state.duplicateCheckStatus!),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nickname,
            maxLength: 60,
            decoration: const InputDecoration(
              labelText: 'Nickname (optional)',
              hintText: 'e.g. Library plane tree',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notes,
            maxLength: 500,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              hintText: 'Observable details only',
            ),
          ),
          const SizedBox(height: 10),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'public',
                icon: Icon(Icons.public_rounded),
                label: Text('Public'),
              ),
              ButtonSegment(
                value: 'private',
                icon: Icon(Icons.lock_outline_rounded),
                label: Text('Private'),
              ),
            ],
            selected: {_visibility},
            onSelectionChanged: (selection) {
              setState(() => _visibility = selection.single);
            },
          ),
          const SizedBox(height: 10),
          _NoticeCard(
            icon: _visibility == 'public'
                ? Icons.public_rounded
                : Icons.lock_outline_rounded,
            title: _visibility == 'public' ? 'Public record' : 'Private record',
            message: _visibility == 'public'
                ? 'Photos and an approximate map position may be visible to other users.'
                : 'Only authorized views should receive this tree and its location.',
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            _ErrorNotice(message: state.errorMessage!),
          ],
        ],
      ),
      action: ElevatedButton.icon(
        key: const Key('confirm-create-tree'),
        onPressed: state.isBusy ? null : _submit,
        icon: state.isBusy ? null : const Icon(Icons.park_rounded),
        label: state.isBusy
            ? const _ButtonSpinner()
            : const Text('Confirm & register tree'),
      ),
    );
  }
}

class _SuccessStep extends StatelessWidget {
  const _SuccessStep({required this.state});
  final TreeRegistrationState state;

  @override
  Widget build(BuildContext context) {
    final tree = state.createdTree;
    final scanTreeId = state.createdScanTreeId;
    final addedScan = state.createdScan != null;
    return Container(
      color: KokTokens.forest,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: const BoxDecoration(
                color: KokTokens.lime,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.park_rounded,
                size: 56,
                color: KokTokens.forest,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              addedScan ? 'Tree scan added' : 'Tree registered',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              addedScan
                  ? 'The new evidence is now part of the existing tree.'
                  : tree!.displayName,
              style: const TextStyle(
                color: KokTokens.forestContainer,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => context.push(
                '/app/tree/${addedScan ? scanTreeId : tree!.id}',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: KokTokens.forest,
              ),
              child: const Text('View tree'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => context.go('/app/map'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
              ),
              child: const Text('View on map'),
            ),
            TextButton(
              onPressed: context.read<TreeRegistrationCubit>().reset,
              style: TextButton.styleFrom(foregroundColor: KokTokens.lime),
              child: const Text('Register another tree'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({required this.body, this.action});
  final Widget body;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(child: body),
      if (action != null)
        DecoratedBox(
          decoration: const BoxDecoration(
            color: KokTokens.surface,
            border: Border(top: BorderSide(color: KokTokens.outline)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: SizedBox(width: double.infinity, child: action),
          ),
        ),
    ],
  );
}

class _InstructionRow extends StatelessWidget {
  const _InstructionRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: KokTokens.forestContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: KokTokens.forest, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(text, style: const TextStyle(height: 1.4)),
          ),
        ),
      ],
    ),
  );
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.warning = false,
  });
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool warning;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: warning ? KokTokens.warningContainer : KokTokens.forestContainer,
      borderRadius: BorderRadius.circular(KokTokens.radiusMedium),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: warning ? KokTokens.warning : KokTokens.forest),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(message, style: const TextStyle(height: 1.35)),
              if (actionLabel != null)
                TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ErrorNotice extends StatelessWidget {
  const _ErrorNotice({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Icon(
          Icons.error_outline_rounded,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
      ],
    ),
  );
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();
  @override
  Widget build(BuildContext context) => const _NoticeCard(
    icon: Icons.science_outlined,
    title: 'Demo data mode',
    message:
        'Analysis and saved trees use local development fixtures. No AI provider is contacted.',
  );
}

class _QualityBadge extends StatelessWidget {
  const _QualityBadge({required this.quality});
  final LocationQuality quality;
  @override
  Widget build(BuildContext context) {
    final poor = quality == LocationQuality.poor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: poor ? KokTokens.warningContainer : KokTokens.forestContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        quality.apiValue.toUpperCase(),
        style: TextStyle(
          color: poor ? KokTokens.warning : KokTokens.forest,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: KokTokens.leaf),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: KokTokens.inkMuted),
              ),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();
  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 22,
    height: 22,
    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
  );
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';
String _dateTime(DateTime value) =>
    '${_date(value)} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

String _duplicateLabel(DuplicateCheckStatus status) {
  switch (status) {
    case DuplicateCheckStatus.noNearbyTrees:
      return 'No nearby trees found';
    case DuplicateCheckStatus.possibleMatches:
      return 'Nearby candidates reviewed';
    case DuplicateCheckStatus.skippedDueToNetworkFailure:
      return 'Skipped due to network failure';
  }
}
