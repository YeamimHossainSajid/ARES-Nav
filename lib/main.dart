import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// ============================================================================
/// ARES NAV (Chryse Planitia Sector)
/// Web Mercator (EPSG:3857) Planetary Map Engine with Normal/Satellite Toggle
/// and Natural Cartographic Area Names in Satellite View (Matching OpenPlanetary)
/// ============================================================================

void main() {
  runApp(const AresNavApp());
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
        primaryColor: const Color(0xFFC1440E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFC1440E),
          secondary: Color(0xFF00E676),
          surface: Color(0xFF11151F),
          error: Color(0xFFFF3344),
        ),
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

class _AresNavMapScreenState extends State<AresNavMapScreen> with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late final AnimationController _pulseController;

  // --------------------------------------------------------------------------
  // 1. SPATIAL PARAMETERS & COORDINATES (Chryse Planitia Sector)
  // --------------------------------------------------------------------------
  static const LatLng _chryseCenter = LatLng(21.1483, -21.2798);
  static const double _initialZoom = 6.2;
  static const double _minZoom = 2.0;
  static const double _maxZoom = 12.0;

  // Origin: Astronaut EVA-1 Base Camp in Chryse Planitia
  static const LatLng _originLocation = LatLng(21.1483, -21.2798);

  // Target Destination: Outcrop Delta
  static const LatLng _destinationLocation = LatLng(22.4200, -18.8500);

  // Planetary Camera Bounds (Safe Web Mercator latitude limits to prevent infinity crash)
  final LatLngBounds _planetaryBounds = LatLngBounds(
    const LatLng(-85.0, -180.0),
    const LatLng(85.0, 180.0),
  );

  // --------------------------------------------------------------------------
  // 2. STATE MANAGEMENT: NORMAL TERRAIN VS. SATELLITE VIEW
  // --------------------------------------------------------------------------
  bool _isSatelliteView = false;

  // Calculated distance variables
  late final double _distanceKm;
  late final String _formattedDistance;

  // Emergency SOS Mode
  bool _isSosActive = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Pulse animation for radar markers
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Calculate real-time straight-line distance
    final double distanceMeters = const Distance().distance(
      _originLocation,
      _destinationLocation,
    );
    _distanceKm = distanceMeters / 1000.0;
    _formattedDistance = '${_distanceKm.toStringAsFixed(1)} km';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _toggleMapView() {
    setState(() {
      _isSatelliteView = !_isSatelliteView;
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF131822),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: _isSatelliteView ? const Color(0xFF00E5FF) : const Color(0xFF00E676),
          ),
        ),
        content: Row(
          children: [
            Icon(
              _isSatelliteView ? Icons.satellite_alt_rounded : Icons.terrain_rounded,
              color: _isSatelliteView ? const Color(0xFF00E5FF) : const Color(0xFF00E676),
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              _isSatelliteView
                  ? 'SWITCHED TO SATELLITE VIEW'
                  : 'SWITCHED TO NORMAL TERRAIN',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _recenterOnOrigin() {
    _mapController.move(_originLocation, 6.2);
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1.0);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1.0);
  }

  void _toggleSos() {
    setState(() {
      _isSosActive = !_isSosActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ==================================================================
          // 1. FLUTTER_MAP ENGINE: DEFAULT WEB MERCATOR (EPSG:3857)
          // ==================================================================
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              // Default Web Mercator is used (do NOT override CRS to prevent white screen)
              initialCenter: _chryseCenter,
              initialZoom: _initialZoom,
              minZoom: _minZoom,
              maxZoom: _maxZoom,
              // Planetary bounds prevent crashes when panning
              cameraConstraint: CameraConstraint.contain(
                bounds: _planetaryBounds,
              ),
            ),
            children: [
              // Dynamic TileLayer Swapped by State (Key ensures instant clean re-render)
              TileLayer(
                key: ValueKey<bool>(_isSatelliteView),
                urlTemplate: _isSatelliteView
                    // SATELLITE VIEW: NASA Mars Trek Realistic Color Surface Stream
                    ? 'https://trek.nasa.gov/tiles/Mars/EQ/Mars_MOLA_blend200ppx_HRSC_ClrShade_clon0dd_200mpp_lzw/1.0.0/default/default028mm/{z}/{y}/{x}.jpg'
                    // NORMAL TERRAIN VIEW: OpenPlanetary Mars Vector Cartography
                    : 'https://cartocdn-gusc.global.ssl.fastly.net/opmbuilder/api/v1/map/named/opm-mars-basemap-v0-2/all/{z}/{x}/{y}.png',
                fallbackUrl:
                    // Resilient fallback to OpenPlanetary basemap if any tile fails
                    'https://cartocdn-gusc.global.ssl.fastly.net/opmbuilder/api/v1/map/named/opm-mars-basemap-v0-2/all/{z}/{x}/{y}.png',
                userAgentPackageName: 'org.spaceapps.aresnav',
                maxZoom: _maxZoom,
                minZoom: _minZoom,
                tileProvider: NetworkTileProvider(
                  headers: const {
                    'User-Agent': 'AresNav/1.0 (org.spaceapps.aresnav; Flutter)',
                    'Accept': 'image/webp,image/png,image/jpeg,*/*',
                  },
                ),
              ),

              // ==============================================================
              // 2. OPENPLANETARY TRANSPARENT NOMENCLATURE TILE OVERLAY
              // Streams the exact same IAU feature names and nomenclature layer
              // from the non-satellite OpenPlanetary basemap directly over the
              // NASA satellite imagery, covering every area name across Mars!
              // ==============================================================
              if (_isSatelliteView)
                TileLayer(
                  key: const ValueKey<String>('opm_satellite_nomenclature_overlay'),
                  urlTemplate:
                      'https://cartocdn-gusc.global.ssl.fastly.net/opmbuilder/api/v1/map/named/opm-mars-basemap-v0-2/4,5/{z}/{x}/{y}.png',
                  fallbackUrl:
                      'https://cartocdn-gusc.global.ssl.fastly.net/nmanaud/api/v1/map/named/opm-mars-basemap-v0-1/5/{z}/{x}/{y}.png',
                  userAgentPackageName: 'org.spaceapps.aresnav',
                  maxZoom: _maxZoom,
                  minZoom: _minZoom,
                  tileProvider: NetworkTileProvider(
                    headers: const {
                      'User-Agent': 'AresNav/1.0 (org.spaceapps.aresnav; Flutter)',
                      'Accept': 'image/webp,image/png,image/jpeg,*/*',
                    },
                  ),
                ),

              // Planned Route: Dashed neon-green line connecting Origin to Destination
              PolylineLayer(
                polylines: [
                  // Outer soft glowing aura
                  Polyline(
                    points: [_originLocation, _destinationLocation],
                    color: const Color(0xFF00E676).withOpacity(0.35),
                    strokeWidth: 7.0,
                  ),
                  // Core dashed walking line
                  Polyline(
                    points: [_originLocation, _destinationLocation],
                    color: const Color(0xFF00E676),
                    strokeWidth: 3.5,
                    pattern: StrokePattern.dashed(segments: const [10, 6]),
                  ),
                ],
              ),

              // Markers: Glowing Cyan Beacon (Origin) & Pulsing Red Pin (Destination)
              MarkerLayer(
                markers: [
                  // Origin: Astronaut EVA-1 Location Marker
                  Marker(
                    point: _originLocation,
                    width: 140,
                    height: 75,
                    alignment: Alignment.center,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) {
                        return AstronautCyanBeaconMarker(
                          pulseProgress: _pulseController.value,
                        );
                      },
                    ),
                  ),

                  // Destination: Red Waypoint Pin
                  Marker(
                    point: _destinationLocation,
                    width: 140,
                    height: 75,
                    alignment: Alignment.center,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) {
                        return DestinationRedPinMarker(
                          pulseProgress: _pulseController.value,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ==================================================================
          // 2. EMERGENCY RED ALERT VIGNETTE (When SOS is Active)
          // ==================================================================
          if (_isSosActive)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFFF3344), width: 8),
                    gradient: RadialGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFFFF3344).withOpacity(0.22),
                      ],
                      radius: 1.0,
                    ),
                  ),
                ),
              ),
            ),

          // ==================================================================
          // 3. TOP FLOATING HEADER BAR (MATCHING REFERENCE DESIGN EXACTLY)
          // ==================================================================
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: TopMissionHeaderBar(
                distanceFormatted: _formattedDistance,
                isSatelliteView: _isSatelliteView,
                originLocation: _originLocation,
                destinationLocation: _destinationLocation,
                isSosActive: _isSosActive,
              ),
            ),
          ),

          // ==================================================================
          // 4. RIGHT-HAND FLOATING CONTROLS: VIEW TOGGLE, RECENTER, ZOOM
          // ==================================================================
          Positioned(
            right: 16,
            top: 220,
            child: Column(
              children: [
                // Layer View Toggle Button (Normal vs. Satellite)
                _buildFloatingControlButton(
                  icon: Icons.layers_rounded,
                  tooltip: _isSatelliteView ? 'Switch to Normal Terrain' : 'Switch to Satellite View',
                  highlight: _isSatelliteView,
                  accentColor: _isSatelliteView ? const Color(0xFF00E5FF) : Colors.white70,
                  onTap: _toggleMapView,
                ),
                const SizedBox(height: 12),

                // Recenter Button (Jump to EVA-1)
                _buildFloatingControlButton(
                  icon: Icons.my_location_rounded,
                  tooltip: 'Recenter on EVA-1',
                  accentColor: const Color(0xFF00E676),
                  onTap: _recenterOnOrigin,
                ),
                const SizedBox(height: 12),

                // Zoom In
                _buildFloatingControlButton(
                  icon: Icons.add,
                  tooltip: 'Zoom In',
                  onTap: _zoomIn,
                ),
                const SizedBox(height: 6),

                // Zoom Out
                _buildFloatingControlButton(
                  icon: Icons.remove,
                  tooltip: 'Zoom Out',
                  onTap: _zoomOut,
                ),
              ],
            ),
          ),

          // ==================================================================
          // 5. BOTTOM TACTICAL GUIDANCE CARD (MATCHING REFERENCE DESIGN)
          // ==================================================================
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: BottomTacticalGuidanceCard(
                isSosActive: _isSosActive,
                onToggleSos: _toggleSos,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingControlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color accentColor = Colors.white,
    bool highlight = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xDD1B1F27),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: highlight ? accentColor : Colors.white12,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: accentColor, size: 22),
        ),
      ),
    );
  }
}

// ============================================================================
// TOP FLOATING HEADER BAR (MATCHING REFERENCE SCREENSHOT)
// ============================================================================

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

class BottomTacticalGuidanceCard extends StatelessWidget {
  final bool isSosActive;
  final VoidCallback onToggleSos;

  const BottomTacticalGuidanceCard({
    super.key,
    required this.isSosActive,
    required this.onToggleSos,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
              color: Colors.black.withOpacity(0.55),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle Pill
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Guidance Row
            Row(
              children: [
                // Direction icon in rounded square
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0x1A00E676),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00E676), width: 1.2),
                  ),
                  child: const Icon(
                    Icons.turn_sharp_right_rounded,
                    color: Color(0xFF00E676),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Tactical instruction
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TACTICAL GUIDANCE',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: Color(0xFF00E676),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Traverse 048° NE along Ares Vallis paleochannel towards Outcrop Delta.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.95),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ASTRONAUT GLOWING CYAN BEACON MARKER
// ============================================================================

class AstronautCyanBeaconMarker extends StatelessWidget {
  final double pulseProgress;

  const AstronautCyanBeaconMarker({
    super.key,
    required this.pulseProgress,
  });

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
              // Outer Glowing Cyan Radar Expansion Ring
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

              // Solid Center Cyan Core with Glow
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF00E5FF),
                  boxShadow: [
                    BoxShadow(color: Color(0xFF00E5FF), blurRadius: 8, spreadRadius: 1),
                  ],
                ),
              ),

              // Center White Pinpoint
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Badge Tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xDD0D0F14),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF00E5FF), width: 0.8),
          ),
          child: const Text(
            'EVA-1',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00E5FF),
              letterSpacing: 0.4,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// DESTINATION PULSING RED PIN MARKER
// ============================================================================

class DestinationRedPinMarker extends StatelessWidget {
  final double pulseProgress;

  const DestinationRedPinMarker({
    super.key,
    required this.pulseProgress,
  });

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
              // Expanding Red Pulse Ring
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

              // Static Red Inner Circle
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF3344).withOpacity(0.3),
                  border: Border.all(color: const Color(0xFFFF3344), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFFF3344).withOpacity(0.6), blurRadius: 8),
                  ],
                ),
              ),

              // Pin Icon
              const Icon(
                Icons.location_on,
                size: 20,
                color: Color(0xFFFF3344),
              ),
            ],
          ),
        ),

        // Destination Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xDD0D0F14),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFFF3344), width: 0.8),
          ),
          child: const Text(
            'DEST',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF3344),
              letterSpacing: 0.4,
            ),
          ),
        ),
      ],
    );
  }
}
