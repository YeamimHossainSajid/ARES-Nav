import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const AresNavApp());
  void _toggleMapView() => setState(() => _isSatelliteView = !_isSatelliteView);
}

class AresNavApp extends StatelessWidget {
  const AresNavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARES Nav - Chryse Planitia Sector',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0F14),
        fontFamily: 'monospace',
      ),
      home: const AresNavMapScreen(),
    );
  }
}

class AresNavMapScreen extends StatefulWidget {
  const AresNavMapScreen({super.key});

  @override
  State<AresNavMapScreen> createState() => _AresNavMapScreenState();
}

class _AresNavMapScreenState extends State<AresNavMapScreen> {
  late final MapController _mapController;
  bool _isSatelliteView = false;
  static const LatLng _originLocation = LatLng(21.1483, -21.2798);
  static const LatLng _destinationLocation = LatLng(22.4200, -18.8500);
  String _formattedDistance = '-- km';

  @override
  void initState() {
    super.initState();
    final double dist = const Distance().distance(_originLocation, _destinationLocation) / 1000.0;
    _formattedDistance = dist.toStringAsFixed(1) + ' km';
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: // Enforce standard Web Mercator EPSG:3857 (do not override CRS to prevent white screen)
        options: const MapOptions(
          initialCenter: LatLng(21.1483, -21.2798),
          initialZoom: 6.2,
          minZoom: 2.0,
          maxZoom: 12.0,
          cameraConstraint: CameraConstraint.contain(
            bounds: LatLngBounds(const LatLng(-85.0, -180.0), const LatLng(85.0, 180.0)),
          ),
        ),
        children: [
          PolylineLayer(
            polylines: [
              Polyline(
                points: [_originLocation, _destinationLocation],
                color: const Color(0xFF00E676).withOpacity(0.35),
                strokeWidth: 7.0,
              ),
              Polyline(
                points: [_originLocation, _destinationLocation],
                color: const Color(0xFF00E676),
                strokeWidth: 3.5,
                pattern: StrokePattern.dashed(segments: const [10, 6]),
              ),
            ],
          ),
          TileLayer(
            key: ValueKey<bool>(_isSatelliteView),
            urlTemplate: _isSatelliteView
                ? 'https://trek.nasa.gov/tiles/Mars/EQ/Mars_MOLA_blend200ppx_HRSC_ClrShade_clon0dd_200mpp_lzw/1.0.0/default/default028mm/{z}/{y}/{x}.jpg'
                : 'https://cartocdn-gusc.global.ssl.fastly.net/opmbuilder/api/v1/map/named/opm-mars-basemap-v0-2/all/{z}/{x}/{y}.png',
            userAgentPackageName: 'org.spaceapps.aresnav',
            maxZoom: 12.0,
            minZoom: 2.0,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleMapView,
        child: const Icon(Icons.layers),
      ),
    );
  }
}

class AstronautCyanBeaconMarker extends StatelessWidget {
  final double pulseProgress;
  const AstronautCyanBeaconMarker({super.key, required this.pulseProgress});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 14 + (pulseProgress * 28),
                height: 14 + (pulseProgress * 28),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withOpacity((1.0 - pulseProgress) * 0.75),
                    width: 2.0,
                  ),
                ),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF00E5FF),
                  boxShadow: [BoxShadow(color: Color(0xFF00E5FF), blurRadius: 8, spreadRadius: 1)],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xDD0D0F14),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF00E5FF), width: 0.8),
          ),
          child: const Text('EVA-1', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF00E5FF))),
        ),
      ],
    );
  }
}

class DestinationRedPinMarker extends StatelessWidget {
  final double pulseProgress;
  const DestinationRedPinMarker({super.key, required this.pulseProgress});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 18 + (pulseProgress * 24),
                height: 18 + (pulseProgress * 24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFF3344).withOpacity((1.0 - pulseProgress) * 0.8),
                    width: 2.0,
                  ),
                ),
              ),
              const Icon(Icons.location_on, size: 20, color: Color(0xFFFF3344)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xDD0D0F14),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFFF3344), width: 0.8),
          ),
          child: const Text('DEST', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFFF3344))),
        ),
      ],
    );
  }
}
class TopMissionHeaderBar extends StatelessWidget {
  final String distanceFormatted;
  final bool isSatelliteView;
  final LatLng originLocation;
  final LatLng destinationLocation;
  final bool isSosActive;

  const TopMissionHeaderBar({
    super.key,
    required this.distanceFormatted,
    required this.isSatelliteView,
    required this.originLocation,
    required this.destinationLocation,
    required this.isSosActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xF212171E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSosActive ? const Color(0xFFFF3344) : Colors.white12,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Green Status Dot + Sector Name + View Mode Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF00E676),
                        boxShadow: [
                          BoxShadow(color: Color(0xFF00E676), blurRadius: 6),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ARES NAV // CHRYSE PLANITIA SECTOR',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                        color: Color(0xFF00E5FF),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2530),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    isSatelliteView ? 'SATELLITE VIEW' : 'NORMAL TERRAIN',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: isSatelliteView ? const Color(0xFF00E5FF) : Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Row 2: Navigation Icon + Target Distance Readout
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.navigation,
                  color: Color(0xFF00E676),
                  size: 20,
                ),
                const SizedBox(width: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Target Distance: ',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: distanceFormatted,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF00E676),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Row 3: Origin -> Destination Coordinate Path
            Text(
              'EVA-1: ${originLocation.latitude.toStringAsFixed(4)}° N, ${originLocation.longitude.toStringAsFixed(4)}° W   →   DEST: ${destinationLocation.latitude.toStringAsFixed(4)}° N, ${destinationLocation.longitude.toStringAsFixed(4)}° W',
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.65),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// BOTTOM TACTICAL GUIDANCE CARD (MATCHING REFERENCE SCREENSHOT)
// ============================================================================


// Floating control dock utilities
