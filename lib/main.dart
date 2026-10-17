import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'models/science_data.dart';
import 'widgets/weather_hud_pill.dart';
import 'widgets/science_layer_control_sheet.dart';
import 'widgets/science_detail_dialog.dart';

/// ============================================================================
/// ARES NAV (Martian Planetary Navigation & Nomenclature Search)
/// Web Mercator (EPSG:3857) Map Engine with NASA Trek Satellite + OpenPlanetary
/// Overlay and Google Maps-style Planetary Nomenclature Autocomplete & Bouncing Pin
/// ============================================================================

void main() {
  runApp(const AresNavApp());
}

class AresNavApp extends StatelessWidget {
  const AresNavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARES Nav - Mars Tactical Navigation',
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

// ============================================================================
// 1. DATA MODEL: MARS NOMENCLATURE FEATURE (USGS IAU GAZETTEER)
// ============================================================================

class MarsFeature {
  final String id;
  final String name;
  final String type;
  final LatLng location;
  final double diameterKm;
  final int elevationM;
  final String description;

  const MarsFeature({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.diameterKm,
    required this.elevationM,
    required this.description,
  });

  factory MarsFeature.fromJson(Map<String, dynamic> json) {
    final double rawLat = (json['lat'] as num).toDouble();
    final double rawLon = (json['lon'] as num).toDouble();

    // Planetocentric to Web Mercator Longitude Normalization:
    // USGS data often uses 0..360° positive East. Convert >180° to -180..+180°.
    final double normLon = rawLon > 180.0 ? rawLon - 360.0 : rawLon;
    // Safe latitude clamping to prevent Web Mercator tangent infinity
    final double normLat = rawLat.clamp(-85.0, 85.0);

    return MarsFeature(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      location: LatLng(normLat, normLon),
      diameterKm: (json['diameter_km'] as num).toDouble(),
      elevationM: (json['elevation_m'] as num).toInt(),
      description: json['description'] as String,
    );
  }

  /// Calculates optimal camera zoom depending on the feature's physical scale
  double get recommendedZoom {
    if (diameterKm > 2000) return 4.0;
    if (diameterKm > 800) return 4.8;
    if (diameterKm > 200) return 5.8;
    if (diameterKm > 50) return 6.8;
    if (diameterKm > 10) return 7.8;
    return 8.6;
  }
}

// ============================================================================
// 2. SEARCH SERVICE: FAST LOCAL IN-MEMORY INDEXING
// ============================================================================

class MarsSearchService {
  List<MarsFeature> _features = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<MarsFeature> get allFeatures => _features;

  Future<void> loadFeatures() async {
    try {
      final String jsonStr = await rootBundle.loadString('assets/data/mars_nomenclature.json');
      final List<dynamic> rawList = jsonDecode(jsonStr) as List<dynamic>;
      _features = rawList.map((item) => MarsFeature.fromJson(item as Map<String, dynamic>)).toList();
      _isLoaded = true;
    } catch (e) {
      debugPrint('Failed to load mars nomenclature dataset: $e');
    }
  }

  List<MarsFeature> search(String query) {
    if (query.trim().isEmpty) return [];
    final cleanQuery = query.toLowerCase().trim();

    return _features.where((f) {
      final matchName = f.name.toLowerCase().contains(cleanQuery);
      final matchType = f.type.toLowerCase().contains(cleanQuery);
      return matchName || matchType;
    }).toList();
  }
}

// ============================================================================
// 3. MAIN MAP SCREEN
// ============================================================================

class AresNavMapScreen extends StatefulWidget {
  const AresNavMapScreen({super.key});

  @override
  State<AresNavMapScreen> createState() => _AresNavMapScreenState();
}

class _AresNavMapScreenState extends State<AresNavMapScreen> with TickerProviderStateMixin {
  late final MapController _mapController;
  late final AnimationController _pulseController;
  late final AnimationController _flyToController;

  // Search Engine
  final MarsSearchService _searchService = MarsSearchService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<MarsFeature> _searchResults = [];
  bool _showSuggestions = false;
  MarsFeature? _selectedFeature;

  // --------------------------------------------------------------------------
  // SPATIAL PARAMETERS & COORDINATES (Chryse Planitia Sector Default)
  // --------------------------------------------------------------------------
  static const LatLng _chryseCenter = LatLng(21.1483, -21.2798);
  static const double _initialZoom = 6.2;
  static const double _minZoom = 2.0;
  static const double _maxZoom = 12.0;

  // Origin: Astronaut EVA-1 Base Camp in Chryse Planitia
  static const LatLng _originLocation = LatLng(21.1483, -21.2798);

  // Active Target Destination (Dynamic, can be changed via search)
  LatLng _destinationLocation = const LatLng(22.4200, -18.8500);

  // Planetary Camera Bounds (Safe Web Mercator limits)
  final LatLngBounds _planetaryBounds = LatLngBounds(
    const LatLng(-85.0, -180.0),
    const LatLng(85.0, 180.0),
  );

  // State Management
  bool _isSatelliteView = false;
  late double _distanceKm;
  late String _formattedDistance;
  bool _isSosActive = false;

  // NASA Multi-Mission Science Layer States (Phase 1)
  bool _showMolaHazards = true;
  bool _showCrismMinerals = true;
  bool _showThemisIce = true;
  bool _showWeatherHud = true;
  final MarsWeatherTelemetry _weatherTelemetry = MarsWeatherTelemetry.currentChryseTelemetry();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Pulse animation for radar markers
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Fly-to smooth animation controller
    _flyToController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _recomputeDistance();

    // Load offline USGS Martian nomenclature dataset
    _searchService.loadFeatures().then((_) {
      if (mounted) setState(() {});
    });

    _searchFocusNode.addListener(() {
      setState(() {
        _showSuggestions = _searchFocusNode.hasFocus && _searchController.text.isNotEmpty;
      });
    });
  }

  void _recomputeDistance() {
    final double distanceMeters = const Distance().distance(
      _originLocation,
      _destinationLocation,
    );
    _distanceKm = distanceMeters / 1000.0;
    _formattedDistance = '${_distanceKm.toStringAsFixed(1)} km';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _pulseController.dispose();
    _flyToController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // CAMERA FLY-TO / PAN INTERPOLATION (60 FPS CURVED MOTION)
  // --------------------------------------------------------------------------
  void _flyTo(LatLng targetCenter, double targetZoom) {
    final startCenter = _mapController.camera.center;
    final startZoom = _mapController.camera.zoom;

    _flyToController.stop();
    _flyToController.reset();

    final latTween = Tween<double>(begin: startCenter.latitude, end: targetCenter.latitude);
    final lonTween = Tween<double>(begin: startCenter.longitude, end: targetCenter.longitude);
    final zoomTween = Tween<double>(begin: startZoom, end: targetZoom);

    final Animation<double> curved = CurvedAnimation(
      parent: _flyToController,
      curve: Curves.fastOutSlowIn,
    );

    void listener() {
      final lat = latTween.evaluate(curved);
      final lon = lonTween.evaluate(curved);
      final zoom = zoomTween.evaluate(curved);
      _mapController.move(LatLng(lat, lon), zoom);
    }

    _flyToController.addListener(listener);
    _flyToController.forward().then((_) {
      _flyToController.removeListener(listener);
    });
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _showSuggestions = false;
      });
      return;
    }

    final results = _searchService.search(query);
    setState(() {
      _searchResults = results;
      _showSuggestions = true;
    });
  }

  void _selectFeature(MarsFeature feature) {
    _searchFocusNode.unfocus();
    setState(() {
      _selectedFeature = feature;
      _searchController.text = feature.name;
      _showSuggestions = false;
    });

    // Execute smooth 60 FPS fly-to camera movement
    _flyTo(feature.location, feature.recommendedZoom);
  }

  void _setAsNavigationDestination(MarsFeature feature) {
    setState(() {
      _destinationLocation = feature.location;
      _recomputeDistance();
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF131822),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFF00E676)),
        ),
        content: Row(
          children: [
            const Icon(Icons.navigation_rounded, color: Color(0xFF00E676), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'TARGET SET: ${feature.name.toUpperCase()} ($_formattedDistance)',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _showSuggestions = false;
      _selectedFeature = null;
    });
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
              _isSatelliteView ? 'SWITCHED TO SATELLITE VIEW' : 'SWITCHED TO NORMAL TERRAIN',
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
    _flyTo(_originLocation, 6.2);
  }

  void _openScienceLayersSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return ScienceLayerControlSheet(
            showMolaHazards: _showMolaHazards,
            showCrismMinerals: _showCrismMinerals,
            showThemisIce: _showThemisIce,
            showWeatherHud: _showWeatherHud,
            onToggleMola: (val) {
              setModalState(() => _showMolaHazards = val);
              setState(() => _showMolaHazards = val);
            },
            onToggleCrism: (val) {
              setModalState(() => _showCrismMinerals = val);
              setState(() => _showCrismMinerals = val);
            },
            onToggleThemis: (val) {
              setModalState(() => _showThemisIce = val);
              setState(() => _showThemisIce = val);
            },
            onToggleWeather: (val) {
              setModalState(() => _showWeatherHud = val);
              setState(() => _showWeatherHud = val);
            },
          );
        },
      ),
    );
  }

  void _openWeatherTelemetryConsole() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (context) => WeatherTelemetryConsoleDialog(
        telemetry: _weatherTelemetry,
      ),
    );
  }

  void _showScienceDetail(dynamic target) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (context) => ScienceDetailDialog(
        target: target,
        onSetAsWaypoint: () {
          LatLng targetPoint;
          String targetName;
          if (target is MolaSlopeHazard) {
            targetPoint = target.centroid;
            targetName = target.name;
          } else if (target is CrismMineralDeposit) {
            targetPoint = target.centroid;
            targetName = target.mineralName;
          } else if (target is ThemisIceDeposit) {
            targetPoint = target.centroid;
            targetName = target.unitName;
          } else {
            return;
          }

          setState(() {
            _destinationLocation = targetPoint;
            _recomputeDistance();
          });

          _flyTo(targetPoint, 7.8);

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF131822),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Color(0xFF00E5FF)),
              ),
              content: Row(
                children: [
                  const Icon(Icons.science_rounded, color: Color(0xFF00E5FF), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'SCIENCE WAYPOINT SET: ${targetName.toUpperCase()} ($_formattedDistance)',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1.0);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ==================================================================
          // 1. FLUTTER_MAP ENGINE: DEFAULT WEB MERCATOR (EPSG:3857)
          // ==================================================================
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _chryseCenter,
              initialZoom: _initialZoom,
              minZoom: _minZoom,
              maxZoom: _maxZoom,
              cameraConstraint: CameraConstraint.contain(
                bounds: _planetaryBounds,
              ),
              onTap: (_, __) {
                if (_showSuggestions || _searchFocusNode.hasFocus) {
                  _searchFocusNode.unfocus();
                  setState(() => _showSuggestions = false);
                }
              },
            ),
            children: [
              // Dynamic Base Tile Layer
              TileLayer(
                key: ValueKey<bool>(_isSatelliteView),
                urlTemplate: _isSatelliteView
                    // SATELLITE VIEW: NASA Mars Trek High-Resolution Surface Mosaic
                    ? 'https://trek.nasa.gov/tiles/Mars/EQ/Mars_MOLA_blend200ppx_HRSC_ClrShade_clon0dd_200mpp_lzw/1.0.0/default/default028mm/{z}/{y}/{x}.jpg'
                    // NORMAL TERRAIN VIEW: OpenPlanetary Mars Vector Cartography
                    : 'https://cartocdn-gusc.global.ssl.fastly.net/opmbuilder/api/v1/map/named/opm-mars-basemap-v0-2/all/{z}/{x}/{y}.png',
                fallbackUrl:
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

              // Transparent OpenPlanetary Nomenclature Layer Overlay on Satellite View
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

              // ==============================================================
              // NASA SCIENCE MISSION DATA OVERLAYS (POLYGON LAYERS)
              // ==============================================================
              // 1. MGS MOLA Slope Hazards (>20° Incline Warning)
              if (_showMolaHazards)
                PolygonLayer(
                  polygons: MarsScienceRepository.molaHazards.map((hazard) {
                    return Polygon(
                      points: hazard.polygon,
                      color: hazard.fillColor,
                      borderColor: hazard.borderColor,
                      borderStrokeWidth: 2.0,
                    );
                  }).toList(),
                ),

              // 2. MRO CRISM Hydrated Mineralogy & Clays
              if (_showCrismMinerals)
                PolygonLayer(
                  polygons: MarsScienceRepository.crismDeposits.map((deposit) {
                    return Polygon(
                      points: deposit.polygon,
                      color: deposit.fillColor,
                      borderColor: deposit.borderColor,
                      borderStrokeWidth: 2.0,
                    );
                  }).toList(),
                ),

              // 3. Mars Odyssey THEMIS Subsurface Ice Ground Units
              if (_showThemisIce)
                PolygonLayer(
                  polygons: MarsScienceRepository.themisIceUnits.map((ice) {
                    return Polygon(
                      points: ice.polygon,
                      color: ice.fillColor,
                      borderColor: ice.borderColor,
                      borderStrokeWidth: 2.0,
                    );
                  }).toList(),
                ),

              // Traversal Route: Dashed neon-green line connecting Origin to Target
              PolylineLayer(
                polylines: [
                  // Soft outer glow corridor
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

              // Markers: Origin Beacon, Route Waypoint, Science Badges, and Animated Bouncing Search Pin
              MarkerLayer(
                markers: [
                  // ----------------------------------------------------------
                  // NASA SCIENCE TARGET CENTROID BADGES (INTERACTIVE TAPS)
                  // ----------------------------------------------------------
                  // MGS MOLA Hazard Centroid Badges
                  if (_showMolaHazards)
                    ...MarsScienceRepository.molaHazards.map((hazard) => Marker(
                      point: hazard.centroid,
                      width: 105,
                      height: 30,
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () => _showScienceDetail(hazard),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xF210141E),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: hazard.displayColor, width: 1.2),
                            boxShadow: [
                              BoxShadow(color: hazard.displayColor.withOpacity(0.4), blurRadius: 6),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning_amber_rounded, size: 12, color: hazard.displayColor),
                              const SizedBox(width: 3),
                              Text(
                                '${hazard.averageSlopeDeg.toStringAsFixed(0)}° SLOPE',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  color: hazard.displayColor,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),

                  // MRO CRISM Mineralogy Centroid Badges
                  if (_showCrismMinerals)
                    ...MarsScienceRepository.crismDeposits.map((deposit) => Marker(
                      point: deposit.centroid,
                      width: 110,
                      height: 30,
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () => _showScienceDetail(deposit),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xF210141E),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: deposit.categoryColor, width: 1.2),
                            boxShadow: [
                              BoxShadow(color: deposit.categoryColor.withOpacity(0.4), blurRadius: 6),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.biotech_rounded, size: 12, color: deposit.categoryColor),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  deposit.category == MineralCategory.phyllosilicates
                                      ? 'CLAYS 94%'
                                      : deposit.category == MineralCategory.sulfates
                                          ? 'SULFATE'
                                          : 'CARBONATE',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: deposit.categoryColor,
                                    fontFamily: 'monospace',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),

                  // Mars Odyssey THEMIS Subsurface Ice Badges
                  if (_showThemisIce)
                    ...MarsScienceRepository.themisIceUnits.map((ice) => Marker(
                      point: ice.centroid,
                      width: 105,
                      height: 30,
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () => _showScienceDetail(ice),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xF210141E),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: ice.displayColor, width: 1.2),
                            boxShadow: [
                              BoxShadow(color: ice.displayColor.withOpacity(0.4), blurRadius: 6),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.ac_unit_rounded, size: 12, color: ice.displayColor),
                              const SizedBox(width: 3),
                              Text(
                                'ICE WEH ${ice.waterEquivalentHydrogenPct.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  color: ice.displayColor,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),

                  // Origin: Astronaut EVA-1 Location Beacon
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

                  // Destination: Red Route Waypoint Pin
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

                  // ==========================================================
                  // ANIMATED BOUNCING LOCATION PIN (SEARCH RESULT FEATURE)
                  // Drops from above with realistic Curves.bounceOut physics!
                  // ==========================================================
                  if (_selectedFeature != null)
                    Marker(
                      key: ValueKey<String>('bouncing_pin_${_selectedFeature!.id}'),
                      point: _selectedFeature!.location,
                      width: 180,
                      height: 85,
                      alignment: Alignment.bottomCenter,
                      child: BouncingPinMarker(
                        feature: _selectedFeature!,
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
          // 3. RIGHT-HAND FLOATING CONTROLS: VIEW TOGGLE, RECENTER, ZOOM
          // ==================================================================
          Positioned(
            right: 16,
            top: 86,
            child: SafeArea(
              child: Column(
                children: [
                  // NASA Multi-Mission Science Overlays Selector Button
                  _buildFloatingControlButton(
                    icon: Icons.science_rounded,
                    tooltip: 'NASA Science Mission Overlays',
                    highlight: _showMolaHazards || _showCrismMinerals || _showThemisIce,
                    accentColor: const Color(0xFF00E5FF),
                    onTap: _openScienceLayersSheet,
                  ),
                  const SizedBox(height: 12),

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
          ),

          // ==================================================================
          // 4. SELECTED FEATURE DETAIL CARD (FLOATING BOTTOM BANNER)
          // ==================================================================
          if (_selectedFeature != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: FeatureDetailCard(
                    feature: _selectedFeature!,
                    isCurrentTarget: _destinationLocation.latitude == _selectedFeature!.location.latitude &&
                        _destinationLocation.longitude == _selectedFeature!.location.longitude,
                    onSetAsTarget: () => _setAsNavigationDestination(_selectedFeature!),
                    onClose: () => setState(() => _selectedFeature = null),
                  ),
                ),
              ),
            ),

          // ==================================================================
          // 5. GOOGLE MAPS-STYLE SEARCH BAR & AUTOCOMPLETE DROPDOWN
          // ==================================================================
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search Bar Capsule
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xF2121722),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: _searchFocusNode.hasFocus
                              ? const Color(0xFF00E5FF)
                              : Colors.white.withOpacity(0.14),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.55),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF00E5FF),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Search Martian nomenclature (Olympus, Jezero)...',
                                hintStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white38,
                                  fontWeight: FontWeight.normal,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: _onSearchChanged,
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.white60, size: 18),
                              onPressed: _clearSearch,
                              splashRadius: 18,
                              tooltip: 'Clear search',
                            ),
                        ],
                      ),
                    ),

                    // Autocomplete Suggestions Dropdown
                    if (_showSuggestions && _searchResults.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        constraints: const BoxConstraints(maxHeight: 280),
                        decoration: BoxDecoration(
                          color: const Color(0xF8121722),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.65),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              shrinkWrap: true,
                              itemCount: _searchResults.length.clamp(0, 6),
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                thickness: 0.8,
                                color: Colors.white.withOpacity(0.06),
                              ),
                              itemBuilder: (context, index) {
                                final feature = _searchResults[index];
                                return InkWell(
                                  onTap: () => _selectFeature(feature),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    child: Row(
                                      children: [
                                        // Icon by Feature Category
                                        Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: _getFeatureTypeColor(feature.type).withOpacity(0.16),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: _getFeatureTypeColor(feature.type).withOpacity(0.5),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Icon(
                                            _getFeatureTypeIcon(feature.type),
                                            size: 18,
                                            color: _getFeatureTypeColor(feature.type),
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Feature Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                feature.name,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Text(
                                                    feature.type,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                      color: _getFeatureTypeColor(feature.type),
                                                    ),
                                                  ),
                                                  if (feature.diameterKm > 0) ...[
                                                    Text(
                                                      ' • ${feature.diameterKm.toStringAsFixed(0)} km',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white.withOpacity(0.5),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Coordinate readout
                                        Text(
                                          '${feature.location.latitude.toStringAsFixed(1)}°, ${feature.location.longitude.toStringAsFixed(1)}°',
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            color: Colors.white.withOpacity(0.4),
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                    // Perseverance MEDA Real-Time Weather HUD Pill (Displayed when suggestions are closed)
                    if (!_showSuggestions && _showWeatherHud)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: WeatherHudPill(
                            telemetry: _weatherTelemetry,
                            onTap: _openWeatherTelemetryConsole,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFeatureTypeIcon(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('volcano') || lower.contains('mons') || lower.contains('tholus')) {
      return Icons.volcano_rounded;
    }
    if (lower.contains('crater')) {
      return Icons.trip_origin_rounded;
    }
    if (lower.contains('landing') || lower.contains('rover') || lower.contains('station')) {
      return Icons.flag_rounded;
    }
    if (lower.contains('vallis') || lower.contains('chasma') || lower.contains('channel')) {
      return Icons.water_rounded;
    }
    return Icons.public_rounded;
  }

  Color _getFeatureTypeColor(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('volcano') || lower.contains('mons')) {
      return const Color(0xFFFF9100);
    }
    if (lower.contains('crater')) {
      return const Color(0xFF00E5FF);
    }
    if (lower.contains('landing') || lower.contains('rover')) {
      return const Color(0xFF00E676);
    }
    if (lower.contains('vallis') || lower.contains('chasma')) {
      return const Color(0xFF29B6F6);
    }
    return const Color(0xFFAB47BC);
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
// 4. ANIMATED BOUNCING LOCATION PIN (GOOGLE MAPS REALISTIC DROP PHYSICS)
// ============================================================================

class BouncingPinMarker extends StatefulWidget {
  final MarsFeature feature;
  final VoidCallback? onTap;

  const BouncingPinMarker({
    super.key,
    required this.feature,
    this.onTap,
  });

  @override
  State<BouncingPinMarker> createState() => _BouncingPinMarkerState();
}

class _BouncingPinMarkerState extends State<BouncingPinMarker> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<Offset> _dropAnimation;
  late final Animation<double> _shadowScale;
  late final Animation<double> _radarRing;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    );

    // Drop from 2.5x height above target with realistic Curves.bounceOut
    _dropAnimation = Tween<Offset>(
      begin: const Offset(0, -2.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.bounceOut,
    ));

    // Ground shadow scales up as the pin strikes the ground
    _shadowScale = Tween<double>(
      begin: 0.15,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutQuad,
    ));

    // Radar ring expands on final impact
    _radarRing = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // 1. Radar wave expanding at the surface contact point
          AnimatedBuilder(
            animation: _radarRing,
            builder: (context, _) {
              final val = _radarRing.value;
              return Container(
                width: 16 + (val * 28),
                height: 8 + (val * 14),
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: const Color(0xFFFF2A3C).withOpacity((1.0 - val).clamp(0.0, 0.85)),
                    width: 1.5,
                  ),
                ),
              );
            },
          ),

          // 2. Realistic ground shadow directly underneath the tip
          AnimatedBuilder(
            animation: _shadowScale,
            builder: (context, _) {
              return Transform.scale(
                scale: _shadowScale.value,
                child: Container(
                  width: 16,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.7),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 3. Falling & Bouncing Google Maps Classic Red Location Pin
          SlideTransition(
            position: _dropAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Feature Name Tag Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xEE10141D),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFF3344), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.7),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.feature.name,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 3),

                // Classic Teardrop Pin Shape
                SizedBox(
                  width: 36,
                  height: 46,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      CustomPaint(
                        size: const Size(36, 46),
                        painter: const ClassicGooglePinPainter(
                          pinColor: Color(0xFFEA4335), // Google Maps Classic Red
                        ),
                      ),
                      // Inner white circular aperture
                      Positioned(
                        top: 8,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 2),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 5. CLASSIC GOOGLE MAPS TEARDROP PIN PAINTER
// ============================================================================

class ClassicGooglePinPainter extends CustomPainter {
  final Color pinColor;

  const ClassicGooglePinPainter({
    required this.pinColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = pinColor
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    final path = Path();
    final w = size.width;
    final h = size.height;
    final radius = w / 2;

    // Start at bottom sharp tip
    path.moveTo(w / 2, h);
    // Left curve up to circular head
    path.cubicTo(w * 0.08, h * 0.65, 0, h * 0.45, 0, radius);
    // Smooth arc over top
    path.arcToPoint(
      Offset(w, radius),
      radius: Radius.circular(radius),
      clockwise: true,
    );
    // Right curve down to tip
    path.cubicTo(w, h * 0.45, w * 0.92, h * 0.65, w / 2, h);
    path.close();

    // Drop shadow
    canvas.drawPath(path.shift(const Offset(0, 2)), shadowPaint);
    // Pin body
    canvas.drawPath(path, paint);

    // Top-left radial highlight reflection
    final highlightPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(w * 0.35, radius * 0.65),
        radius * 0.85,
        [
          Colors.white.withOpacity(0.38),
          Colors.transparent,
        ],
      );
    canvas.drawCircle(Offset(w * 0.35, radius * 0.65), radius * 0.65, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// 6. SELECTED FEATURE DETAIL CARD (BOTTOM BANNER)
// ============================================================================

class FeatureDetailCard extends StatelessWidget {
  final MarsFeature feature;
  final bool isCurrentTarget;
  final VoidCallback onSetAsTarget;
  final VoidCallback onClose;

  const FeatureDetailCard({
    super.key,
    required this.feature,
    required this.isCurrentTarget,
    required this.onSetAsTarget,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xF2121722),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00E5FF).withOpacity(0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.65),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Title and Close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.type.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: Color(0xFF00E5FF),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      feature.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white60, size: 20),
                onPressed: onClose,
                splashRadius: 20,
                tooltip: 'Dismiss feature preview',
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Telemetry Row
          Row(
            children: [
              _buildMetricChip(
                label: 'LATITUDE',
                value: '${feature.location.latitude.toStringAsFixed(2)}° N',
              ),
              const SizedBox(width: 8),
              _buildMetricChip(
                label: 'LONGITUDE',
                value: '${feature.location.longitude.toStringAsFixed(2)}° W',
              ),
              if (feature.diameterKm > 0) ...[
                const SizedBox(width: 8),
                _buildMetricChip(
                  label: 'DIAMETER',
                  value: '${feature.diameterKm.toStringAsFixed(0)} km',
                ),
              ],
              const SizedBox(width: 8),
              _buildMetricChip(
                label: 'ELEVATION',
                value: '${feature.elevationM >= 0 ? "+" : ""}${feature.elevationM} m',
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Geological Description
          Text(
            feature.description,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.85),
              height: 1.35,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Route to Feature Action Button
          InkWell(
            onTap: onSetAsTarget,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isCurrentTarget
                    ? const Color(0xFFFF3344).withOpacity(0.2)
                    : const Color(0xFF00E676).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrentTarget ? const Color(0xFFFF3344) : const Color(0xFF00E676),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isCurrentTarget ? Icons.check_circle_rounded : Icons.navigation_rounded,
                    color: isCurrentTarget ? const Color(0xFFFF3344) : const Color(0xFF00E676),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCurrentTarget ? 'CURRENT ACTIVE DESTINATION' : 'SET AS NAVIGATION DESTINATION',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      color: isCurrentTarget ? const Color(0xFFFF3344) : const Color(0xFF00E676),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF1B212D),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 7, color: Colors.white.withOpacity(0.45)),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 7. ASTRONAUT GLOWING CYAN BEACON MARKER (EVA-1)
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
              // Outer Expanding Cyan Radar Ring
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

              // Solid Center Cyan Core
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

        // Callsign Badge
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
// 8. DESTINATION PULSING RED PIN MARKER
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
