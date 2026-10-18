import 'package:latlong2/latlong.dart';

/// Real InSight Marsquake SEIS Event (NASA JPL InSight Mission)
class MarsquakeEvent {
  final String id;
  final int sol;
  final DateTime timestamp;
  final double magnitude; // Richter equivalent on Mars (usually 1.5 to 4.7)
  final String qualityClass; // 'A' (precise epicenter) to 'D' (broad detection)
  final LatLng location;
  final double depthKm;
  final String seismicRegion;
  final String description;

  const MarsquakeEvent({
    required this.id,
    required this.sol,
    required this.timestamp,
    required this.magnitude,
    required this.qualityClass,
    required this.location,
    required this.depthKm,
    required this.seismicRegion,
    required this.description,
  });

  /// Catalog of curated real InSight SEIS seismic events
  static List<MarsquakeEvent> get mockInSightCatalog => [
    MarsquakeEvent(
      id: 'S1222a',
      sol: 1222,
      timestamp: DateTime.utc(2022, 5, 4, 23, 23),
      magnitude: 4.7,
      qualityClass: 'A',
      location: const LatLng(3.2, 137.8), // Cerberus Fossae fracture system
      depthKm: 28.5,
      seismicRegion: 'Cerberus Fossae Epicenter',
      description: 'Largest recorded marsquake in history. Surface waves circled Mars multiple times.',
    ),
    MarsquakeEvent(
      id: 'S0173a',
      sol: 173,
      timestamp: DateTime.utc(2019, 5, 23, 17, 04),
      magnitude: 3.7,
      qualityClass: 'A',
      location: const LatLng(4.5, 142.1),
      depthKm: 45.0,
      seismicRegion: 'Cerberus Fossae East',
      description: 'First definitive deep teleseismic event linked to active magma cooling in tectonic grabens.',
    ),
    MarsquakeEvent(
      id: 'S1000a',
      sol: 1000,
      timestamp: DateTime.utc(2021, 9, 18, 11, 45),
      magnitude: 4.2,
      qualityClass: 'B',
      location: const LatLng(10.8, 160.2),
      depthKm: 52.0,
      seismicRegion: 'Elysium Planitia Flank',
      description: 'Long-duration seismic shaking (>90 minutes), high-frequency P and S wave separation.',
    ),
    MarsquakeEvent(
      id: 'S0235b',
      sol: 235,
      timestamp: DateTime.utc(2019, 7, 26, 12, 18),
      magnitude: 3.6,
      qualityClass: 'A',
      location: const LatLng(18.1, 78.2), // Near Jezero Basin margin
      depthKm: 34.0,
      seismicRegion: 'Syrtis Major - Jezero Basin Border',
      description: 'Tectonic compression along the ancient Isidis impact basin rim.',
    ),
  ];
}

/// Rover Science Mission Telemetry (Mars 2020 Perseverance & Curiosity)
class RoverScienceTrack {
  final String missionId; // 'PERSEVERANCE_M2020' or 'CURIOSITY_MSL'
  final String callsign;
  final LatLng currentPosition;
  final double totalOdometerKm;
  final int sol;
  final List<LatLng> traversedWaypoints;
  final String currentActivity;
  final Map<String, String> instrumentTelemetry;
  final int samplesCollected;

  const RoverScienceTrack({
    required this.missionId,
    required this.callsign,
    required this.currentPosition,
    required this.totalOdometerKm,
    required this.sol,
    required this.traversedWaypoints,
    required this.currentActivity,
    required this.instrumentTelemetry,
    required this.samplesCollected,
  });

  static RoverScienceTrack get perseveranceJezero => const RoverScienceTrack(
    missionId: 'PERSEVERANCE_M2020',
    callsign: 'Perseverance (Mars 2020)',
    currentPosition: LatLng(18.4215, 77.6350), // Delta Front Section 4B
    totalOdometerKm: 28.74,
    sol: 1242,
    traversedWaypoints: [
      LatLng(18.3842, 77.5819), // Octavia E. Butler Landing Site
      LatLng(18.3910, 77.5740), // Sample Depot 1 (Three Forks)
      LatLng(18.4050, 77.5980), // Hawksbill Gap
      LatLng(18.4120, 77.6180), // Rocky Top sedimentary bed
      LatLng(18.4215, 77.6350), // Current target: Belva Crater Delta
    ],
    currentActivity: 'Abrasion & Core Extraction: Silicate mudstone target "Swift Run"',
    instrumentTelemetry: {
      'PIXL X-Ray': 'ACTIVE // Scanning elemental matrix (Fe/Si/Ca peaks)',
      'SHERLOC UV Raman': 'STANDBY // Organic fluorophore signature detected',
      'MOXIE O2 Generator': 'OFFLINE // Last cycle: 12.2 g O2/hour nominal',
      'Mastcam-Z Multispectral': 'STREAMING // 110mm stereo mosaic acquired',
      'MEDA Weather Station': '-62°C • 0.636 kPa • 18 km/h ENE',
    },
    samplesCollected: 24,
  );
}
