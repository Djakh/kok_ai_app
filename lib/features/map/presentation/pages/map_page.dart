import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kok_ai_app/assets/themes/design_tokens.dart';
import 'package:kok_ai_app/features/tree_registration/domain/entities/tree_models.dart';
import 'package:kok_ai_app/features/tree_registration/domain/repositories/tree_repository.dart';
import 'package:kok_ai_app/injection_container.dart';
import 'package:kok_ai_app/router.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const _defaultCenter = LatLng(41.2995, 69.2401);
  final TreeRepository _repository = sl();
  GoogleMapController? _controller;
  List<TreeRecord> _trees = [];
  TreeRecord? _selected;
  Position? _position;
  bool _loading = true;
  String? _error;
  bool _permissionDenied = false;
  bool _permissionDeniedForever = false;

  @override
  void initState() {
    super.initState();
    _loadTrees();
    _readExistingLocationAccess();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadTrees() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final center = _position == null
          ? _defaultCenter
          : LatLng(_position!.latitude, _position!.longitude);
      final trees = await _repository.getMapTrees(
        TreeMapQuery(
          center: '${center.latitude},${center.longitude}',
          radius: 50000,
        ),
      );
      if (!mounted) return;
      setState(() {
        _trees = trees.where((tree) {
          final point = tree.location;
          return point.latitude >= -90 &&
              point.latitude <= 90 &&
              point.longitude >= -180 &&
              point.longitude <= 180 &&
              !(point.latitude == 0 && point.longitude == 0);
        }).toList();
        _loading = false;
      });
      if (_trees.isNotEmpty) {
        _controller?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(
              _trees.first.location.latitude,
              _trees.first.location.longitude,
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Registered trees could not be loaded.';
      });
    }
  }

  Future<void> _readExistingLocationAccess() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      await _locate(requestPermission: false);
    }
  }

  Future<void> _locate({bool requestPermission = true}) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location services are disabled.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: Geolocator.openLocationSettings,
            ),
          ),
        );
      }
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (requestPermission && permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() => _permissionDeniedForever = true);
      return;
    }
    if (permission == LocationPermission.denied) {
      setState(() => _permissionDenied = true);
      return;
    }
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );
      if (!mounted) return;
      setState(() {
        _position = position;
        _permissionDenied = false;
        _permissionDeniedForever = false;
      });
      await _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          16,
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Current position is unavailable.')),
        );
      }
    }
  }

  Set<Marker> get _markers => _trees
      .map(
        (tree) => Marker(
          markerId: MarkerId(tree.id),
          position: LatLng(tree.location.latitude, tree.location.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          onTap: () => setState(() => _selected = tree),
          infoWindow: InfoWindow(
            title: tree.displayName,
            snippet:
                'Recorded ±${tree.location.horizontalAccuracyMeters.toStringAsFixed(1)} m',
          ),
        ),
      )
      .toSet();

  Set<Circle> get _circles {
    final position = _position;
    if (position == null || position.accuracy <= 0) return {};
    return {
      Circle(
        circleId: const CircleId('current-accuracy'),
        center: LatLng(position.latitude, position.longitude),
        radius: position.accuracy,
        fillColor: Colors.blue.withValues(alpha: .12),
        strokeColor: Colors.blue,
        strokeWidth: 1,
      ),
    };
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: _defaultCenter,
            zoom: 12.5,
          ),
          onMapCreated: (controller) => _controller = controller,
          markers: _markers,
          circles: _circles,
          myLocationEnabled: _position != null,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onTap: (_) => setState(() => _selected = null),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Material(
                    color: KokTokens.surface,
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.map_outlined, color: KokTokens.forest),
                          SizedBox(width: 10),
                          Text(
                            'Registered trees',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  heroTag: 'map-refresh',
                  onPressed: _loadTrees,
                  backgroundColor: KokTokens.surface,
                  foregroundColor: KokTokens.forest,
                  child: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),
        ),
        if (_permissionDenied || _permissionDeniedForever)
          Positioned(
            top: 86,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Material(
                color: KokTokens.warningContainer,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_disabled_outlined,
                        color: KokTokens.warning,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Your position is hidden. Registered trees remain available.',
                        ),
                      ),
                      if (_permissionDeniedForever)
                        TextButton(
                          onPressed: Geolocator.openAppSettings,
                          child: const Text('Settings'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          Center(
            child: Card(
              margin: const EdgeInsets.all(28),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_outlined, size: 38),
                    const SizedBox(height: 10),
                    Text(_error!),
                    TextButton(
                      onPressed: _loadTrees,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (_trees.isEmpty)
          Center(
            child: Card(
              margin: const EdgeInsets.all(28),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.park_outlined,
                      size: 44,
                      color: KokTokens.leaf,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'No trees on this map yet',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => context.push(registerTreeRoute),
                      child: const Text('Register a tree'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Positioned(
          right: 16,
          bottom: _selected == null ? 20 : 160,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: 'map-add',
                onPressed: () => context.push(registerTreeRoute),
                backgroundColor: KokTokens.forest,
                foregroundColor: Colors.white,
                child: const Icon(Icons.add_rounded),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'map-locate',
                onPressed: _locate,
                backgroundColor: KokTokens.surface,
                foregroundColor: KokTokens.forest,
                child: const Icon(Icons.my_location_rounded),
              ),
            ],
          ),
        ),
        if (_selected != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: _TreePreview(tree: _selected!),
          ),
      ],
    ),
  );
}

class _TreePreview extends StatelessWidget {
  const _TreePreview({required this.tree});
  final TreeRecord tree;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: KokTokens.forestContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.park_rounded, color: KokTokens.forest),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tree.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  tree.scientificName ?? 'Identification uncertain',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: KokTokens.inkMuted),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/app/tree/${tree.id}'),
            child: const Text('Details'),
          ),
        ],
      ),
    ),
  );
}
