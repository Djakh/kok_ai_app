import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/router.dart';

enum MapTreeStatus { healthy, needsAttention, unknown }

class MapTreePoint {
  const MapTreePoint({
    required this.id,
    required this.name,
    required this.position,
    required this.status,
  });

  final String id;
  final String name;
  final LatLng position;
  final MapTreeStatus status;
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  final searchController = TextEditingController();

  GoogleMapController? mapController;
  BitmapDescriptor? healthyTreeIcon;
  BitmapDescriptor? warningTreeIcon;
  BitmapDescriptor? unknownTreeIcon;
  bool myLocationEnabled = false;

  final points = const [
    MapTreePoint(
      id: '1',
      name: 'Central Oak',
      position: LatLng(40.7829, -73.9654),
      status: MapTreeStatus.healthy,
    ),
    MapTreePoint(
      id: '2',
      name: 'Park Maple',
      position: LatLng(40.7749, -73.9558),
      status: MapTreeStatus.needsAttention,
    ),
    MapTreePoint(
      id: '3',
      name: 'Grand Willow',
      position: LatLng(40.7589, -73.9851),
      status: MapTreeStatus.healthy,
    ),
    MapTreePoint(
      id: '4',
      name: 'Street Birch',
      position: LatLng(40.7614, -73.9776),
      status: MapTreeStatus.healthy,
    ),
    MapTreePoint(
      id: '5',
      name: 'Unknown Tree',
      position: LatLng(40.7580, -73.9855),
      status: MapTreeStatus.unknown,
    ),
  ];

  /// --- Life cycle ---

  @override
  void initState() {
    super.initState();
    initializeMapAssets();
    initializeLocationAccess();
  }

  @override
  void dispose() {
    searchController.dispose();
    mapController?.dispose();
    super.dispose();
  }

  /// --- Methods ---

  Future<void> initializeMapAssets() async {
    healthyTreeIcon = await createTreeMarkerIcon(const Color(0xFF4CAF50), '🌳');
    warningTreeIcon = await createTreeMarkerIcon(const Color(0xFFB67A3C), '🌲');
    unknownTreeIcon = await createTreeMarkerIcon(const Color(0xFF78909C), '🌿');
    if (!mounted) return;
    setState(() {});
  }

  Future<void> initializeLocationAccess() async {
    final allowed = await ensureLocationPermission();
    if (!mounted) return;
    setState(() => myLocationEnabled = allowed);
  }

  Future<bool> ensureLocationPermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  double markerHue(MapTreeStatus status) {
    if (status == MapTreeStatus.healthy) {
      return BitmapDescriptor.hueGreen;
    }
    if (status == MapTreeStatus.needsAttention) {
      return BitmapDescriptor.hueOrange;
    }
    return BitmapDescriptor.hueAzure;
  }

  Future<BitmapDescriptor> createTreeMarkerIcon(
    Color backgroundColor,
    String emoji,
  ) async {
    const size = 140.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final fillPaint = Paint()..color = backgroundColor;
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(const Offset(size / 2, size / 2), 46, fillPaint);
    canvas.drawCircle(const Offset(size / 2, size / 2), 46, borderPaint);

    final textPainter = TextPainter(
      text: TextSpan(text: emoji, style: const TextStyle(fontSize: 50)),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final image = await recorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  BitmapDescriptor iconByStatus(MapTreeStatus status) {
    if (status == MapTreeStatus.healthy) {
      return healthyTreeIcon ??
          BitmapDescriptor.defaultMarkerWithHue(markerHue(status));
    }
    if (status == MapTreeStatus.needsAttention) {
      return warningTreeIcon ??
          BitmapDescriptor.defaultMarkerWithHue(markerHue(status));
    }
    return unknownTreeIcon ??
        BitmapDescriptor.defaultMarkerWithHue(markerHue(status));
  }

  Set<Marker> buildMarkers() => points
      .map(
        (item) => Marker(
          markerId: MarkerId(item.id),
          position: item.position,
          infoWindow: InfoWindow(title: item.name, snippet: item.status.name),
          icon: iconByStatus(item.status),
          onTap: () => context.push('/app/tree/${item.id}'),
        ),
      )
      .toSet();

  Future<void> onRecenter() async {
    final allowed = await ensureLocationPermission();
    if (!allowed) {
      mapController?.animateCamera(
        CameraUpdate.newLatLng(const LatLng(40.7829, -73.9654)),
      );
      return;
    }

    if (!myLocationEnabled) {
      setState(() => myLocationEnabled = true);
    }

    final currentPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    );
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(currentPosition.latitude, currentPosition.longitude),
        15.2,
      ),
    );
  }

  /// --- Widgets ---

  Widget searchBar() => Container(
    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: Style.border16,
      boxShadow: const [
        BoxShadow(
          color: Color(0x12000000),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Container(
            height: 42,
            padding: Style.paddingH12,
            decoration: BoxDecoration(
              color: AppColors.neutralLight,
              borderRadius: Style.border12,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: AppColors.gray717171,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'map_search_trees'.tr(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: Style.border12,
            border: Border.all(color: AppColors.grayE8E8E8),
          ),
          child: const Icon(
            Icons.tune_rounded,
            size: 20,
            color: AppColors.gray717171,
          ),
        ),
      ],
    ),
  );

  Widget legendCard() => Container(
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: Style.border12,
      boxShadow: const [
        BoxShadow(
          color: Color(0x10000000),
          blurRadius: 8,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        legendItem('map_healthy'.tr(), AppColors.primary),
        legendItem('map_needs_attention'.tr(), AppColors.warmEarthBrown),
        legendItem('map_unknown'.tr(), AppColors.grayA0A0A0),
      ],
    ),
  );

  Widget legendItem(String title, Color color) => Row(
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 4),
      Text(title, style: Style.body12(context, color: AppColors.gray717171)),
    ],
  );

  Widget mapStatsCard() => Positioned(
    left: 16,
    right: 16,
    bottom: 16,
    child: Container(
      padding: Style.paddingAll16,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: Style.border20,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'map_trees_nearby'.tr(),
                  style: Style.body12(context, color: AppColors.gray717171),
                ),
                Text(
                  '${points.length}',
                  style: Style.headline28(context, color: AppColors.primary),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'map_in_your_area'.tr(),
                  style: Style.body12(context, color: AppColors.gray717171),
                ),
                Text(
                  '45',
                  style: Style.headline28(
                    context,
                    color: AppColors.warmEarthBrown,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget recenterButton() => Positioned(
    right: 16,
    top: 130,
    child: GestureDetector(
      onTap: onRecenter,
      child: Container(
        width: 46,
        height: 46,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(
          Icons.navigation_rounded,
          color: AppColors.primary,
          size: 22,
        ),
      ),
    ),
  );

  Widget registerTreeFab() => Positioned(
    right: 20,
    bottom: 98,
    child: GestureDetector(
      onTap: () => context.push(registerTreeCameraRoute),
      child: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.brightLeafGreen],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.park_rounded, color: Colors.white, size: 30),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      bottom: false,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(40.7829, -73.9654),
              zoom: 12.8,
            ),
            markers: buildMarkers(),
            myLocationEnabled: myLocationEnabled,
            myLocationButtonEnabled: myLocationEnabled,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (controller) => mapController = controller,
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Column(children: [searchBar(), legendCard()]),
          ),
          recenterButton(),
          mapStatsCard(),
          registerTreeFab(),
        ],
      ),
    ),
  );
}
