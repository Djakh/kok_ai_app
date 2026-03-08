import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/router.dart';

enum MapTreeStatus { healthy, needsAttention, unknown }

class MapTreePoint {
  const MapTreePoint({required this.id, required this.name, required this.position, required this.status});

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

  final points = const [
    MapTreePoint(id: '1', name: 'Central Oak', position: LatLng(40.7829, -73.9654), status: MapTreeStatus.healthy),
    MapTreePoint(id: '2', name: 'Park Maple', position: LatLng(40.7749, -73.9558), status: MapTreeStatus.needsAttention),
    MapTreePoint(id: '3', name: 'Grand Willow', position: LatLng(40.7589, -73.9851), status: MapTreeStatus.healthy),
    MapTreePoint(id: '4', name: 'Street Birch', position: LatLng(40.7614, -73.9776), status: MapTreeStatus.healthy),
    MapTreePoint(id: '5', name: 'Unknown Tree', position: LatLng(40.7580, -73.9855), status: MapTreeStatus.unknown),
  ];

  /// --- Life cycle ---

  @override
  void dispose() {
    searchController.dispose();
    mapController?.dispose();
    super.dispose();
  }

  /// --- Methods ---

  double markerHue(MapTreeStatus status) {
    if (status == MapTreeStatus.healthy) return BitmapDescriptor.hueGreen;
    if (status == MapTreeStatus.needsAttention) return BitmapDescriptor.hueOrange;
    return BitmapDescriptor.hueAzure;
  }

  Set<Marker> buildMarkers() => points
      .map(
        (item) => Marker(
          markerId: MarkerId(item.id),
          position: item.position,
          infoWindow: InfoWindow(title: item.name, snippet: item.status.name),
          icon: BitmapDescriptor.defaultMarkerWithHue(markerHue(item.status)),
          onTap: () => context.push('/app/tree/${item.id}'),
        ),
      )
      .toSet();

  void onRecenter() {
    mapController?.animateCamera(CameraUpdate.newLatLng(const LatLng(40.7829, -73.9654)));
  }

  /// --- Widgets ---

  Widget searchBar() => Container(
    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: Colors.white, borderRadius: Style.border16, boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 4))]),
    child: Row(
      children: [
        Expanded(
          child: Container(
            height: 42,
            padding: Style.paddingH12,
            decoration: BoxDecoration(color: AppColors.neutralLight, borderRadius: Style.border12),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, size: 20, color: AppColors.gray717171),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(controller: searchController, decoration: const InputDecoration(border: InputBorder.none, hintText: 'Search trees...')),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: Colors.white, borderRadius: Style.border12, border: Border.all(color: AppColors.grayE8E8E8)),
          child: const Icon(Icons.tune_rounded, size: 20, color: AppColors.gray717171),
        ),
      ],
    ),
  );

  Widget legendCard() => Container(
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(color: Colors.white, borderRadius: Style.border12, boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 8, offset: Offset(0, 3))]),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        legendItem('Healthy', AppColors.primary),
        legendItem('Needs Attention', AppColors.warmEarthBrown),
        legendItem('Unknown', AppColors.grayA0A0A0),
      ],
    ),
  );

  Widget legendItem(String title, Color color) => Row(
    children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
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
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.95), borderRadius: Style.border20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trees Nearby', style: Style.body12(context, color: AppColors.gray717171)),
                Text('${points.length}', style: Style.headline28(context, color: AppColors.primary)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('In Your Area', style: Style.body12(context, color: AppColors.gray717171)),
                Text('45', style: Style.headline28(context, color: AppColors.warmEarthBrown)),
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
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x1F000000), blurRadius: 8, offset: Offset(0, 3))]),
        child: const Icon(Icons.navigation_rounded, color: AppColors.primary, size: 22),
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
          gradient: LinearGradient(colors: [AppColors.primary, AppColors.brightLeafGreen]),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 8))],
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
            initialCameraPosition: const CameraPosition(target: LatLng(40.7829, -73.9654), zoom: 12.8),
            markers: buildMarkers(),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (controller) => mapController = controller,
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Column(
              children: [
                searchBar(),
                legendCard(),
              ],
            ),
          ),
          recenterButton(),
          mapStatsCard(),
          registerTreeFab(),
        ],
      ),
    ),
  );
}
