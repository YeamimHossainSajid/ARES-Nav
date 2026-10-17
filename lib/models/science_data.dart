import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide Path;

/// ============================================================================
/// ARES NAV - NASA MULTI-MISSION SCIENCE DATA MODELS
/// Integrates telemetry and observation datasets from:
/// 1. MGS MOLA (Mars Orbiter Laser Altimeter) - Slope & Escarpment Hazards
/// 2. MRO CRISM (Compact Reconnaissance Imaging Spectrometer) - Hydrated Minerals
/// 3. Mars Odyssey THEMIS (Thermal Emission Imaging System) - Subsurface Ice
/// 4. Perseverance MEDA / Curiosity REMS - Real-Time Atmospheric Weather HUD
/// ============================================================================

enum HazardSeverity {
  nominal, // < 12° Slope: Green corridor
  caution, // 12° - 20° Slope: Amber caution
  severe,  // > 20° Slope: Red hazard / Impassable for EVA suit & Rover
}

/// MGS MOLA Slope Hazard Zone
class MolaSlopeHazard {
  final String id;
  final String name;
  final double averageSlopeDeg;
  final double maxSlopeDeg;
  final HazardSeverity severity;
  final List<LatLng> polygon;
  final LatLng centroid;
  final String description;
  final String recommendation;

  const MolaSlopeHazard({
    required this.id,
    required this.name,
    required this.averageSlopeDeg,
    required this.maxSlopeDeg,
    required this.severity,
    required this.polygon,
    required this.centroid,
    required this.description,
    required this.recommendation,
  });

  Color get displayColor {
    switch (severity) {
      case HazardSeverity.severe:
        return const Color(0xFFFF3344);
      case HazardSeverity.caution:
        return const Color(0xFFFFA000);
      case HazardSeverity.nominal:
        return const Color(0xFF00E676);
    }
  }

  Color get fillColor => displayColor.withOpacity(0.28);
  Color get borderColor => displayColor.withOpacity(0.9);
}

enum MineralCategory {
  phyllosilicates, // Fe/Mg Smectite Clays (High biosignature potential)
  sulfates,        // Polyhydrated / Gypsum Sulfates (Evaporites)
  carbonates,      // Mg/Ca Carbonates (Alkaline ancient waters)
  silica,          // Hydrated Opaline Silica (Hydrothermal spring activity)
}

/// MRO CRISM Hydrated Mineral Deposit
class CrismMineralDeposit {
  final String id;
  final String mineralName;
  final MineralCategory category;
  final List<LatLng> polygon;
  final LatLng centroid;
  final double biosignatureScore; // 0 - 100%
  final String spectralAbsorption; // e.g. "1.9 µm & 2.2 µm doublet"
  final String geologicContext;
  final String scienceSignificance;

  const CrismMineralDeposit({
    required this.id,
    required this.mineralName,
    required this.category,
    required this.polygon,
    required this.centroid,
    required this.biosignatureScore,
    required this.spectralAbsorption,
    required this.geologicContext,
    required this.scienceSignificance,
  });

  Color get categoryColor {
    switch (category) {
      case MineralCategory.phyllosilicates:
        return const Color(0xFF00E5FF); // Luminous Cyan
      case MineralCategory.sulfates:
        return const Color(0xFFE040FB); // Vibrant Magenta
      case MineralCategory.carbonates:
        return const Color(0xFF00E676); // Emerald Green
      case MineralCategory.silica:
        return const Color(0xFFFFD700); // Amber Gold
    }
  }

  String get categoryLabel {
    switch (category) {
      case MineralCategory.phyllosilicates:
        return 'SMECTITE CLAYS (PHYLLOSILICATES)';
      case MineralCategory.sulfates:
        return 'HYDRATED SULFATES';
      case MineralCategory.carbonates:
        return 'MAGNESIUM CARBONATES';
      case MineralCategory.silica:
        return 'OPALINE SILICA';
    }
  }

  Color get fillColor => categoryColor.withOpacity(0.24);
  Color get borderColor => categoryColor.withOpacity(0.85);
}

/// Mars Odyssey THEMIS Subsurface Water Ice Ground Unit (ISRU Target)
class ThemisIceDeposit {
  final String id;
  final String unitName;
  final double depthMinMeters;
  final double depthMaxMeters;
  final double waterEquivalentHydrogenPct; // e.g. 32% WEH
  final List<LatLng> polygon;
  final LatLng centroid;
  final double estimatedVolumeM3;
  final String extractionViability; // e.g. "Optimal for rotary sublimation drill"
  final String scientificNotes;

  const ThemisIceDeposit({
    required this.id,
    required this.unitName,
    required this.depthMinMeters,
    required this.depthMaxMeters,
    required this.waterEquivalentHydrogenPct,
    required this.polygon,
    required this.centroid,
    required this.estimatedVolumeM3,
    required this.extractionViability,
    required this.scientificNotes,
  });

  Color get displayColor => const Color(0xFF40C4FF);
  Color get fillColor => const Color(0xFF40C4FF).withOpacity(0.22);
  Color get borderColor => const Color(0xFF40C4FF).withOpacity(0.85);
}

/// Perseverance MEDA / Curiosity REMS Live Martian Environmental Telemetry
class MarsWeatherTelemetry {
  final int sol;
  final double solarLongitudeLs; // 0 - 360°
  final String season;
  final double ambientTempCelsius;
  final double groundTempCelsius;
  final double minDiurnalTempCelsius;
  final double maxDiurnalTempCelsius;
  final double pressurePascals;
  final double windSpeedKmh;
  final double windGustKmh;
  final double windDirectionDegrees;
  final String windDirectionCompass;
  final double opticalDepthTau; // Atmospheric dust opacity
  final double uvIndex;
  final double radiationMsvDay;
  final String localTrueSolarTime;
  final bool dustStormAlert;

  const MarsWeatherTelemetry({
    required this.sol,
    required this.solarLongitudeLs,
    required this.season,
    required this.ambientTempCelsius,
    required this.groundTempCelsius,
    required this.minDiurnalTempCelsius,
    required this.maxDiurnalTempCelsius,
    required this.pressurePascals,
    required this.windSpeedKmh,
    required this.windGustKmh,
    required this.windDirectionDegrees,
    required this.windDirectionCompass,
    required this.opticalDepthTau,
    required this.uvIndex,
    required this.radiationMsvDay,
    required this.localTrueSolarTime,
    required this.dustStormAlert,
  });

  /// Factory providing high-fidelity Chryse Planitia telemetry based on Viking & Perseverance instruments
  factory MarsWeatherTelemetry.currentChryseTelemetry() {
    return const MarsWeatherTelemetry(
      sol: 1142,
      solarLongitudeLs: 142.6,
      season: 'Late Northern Summer',
      ambientTempCelsius: -62.4,
      groundTempCelsius: -41.8,
      minDiurnalTempCelsius: -88.0,
      maxDiurnalTempCelsius: -19.5,
      pressurePascals: 748.2,
      windSpeedKmh: 16.5,
      windGustKmh: 31.2,
      windDirectionDegrees: 118.0,
      windDirectionCompass: 'ESE',
      opticalDepthTau: 0.38,
      uvIndex: 4.8,
      radiationMsvDay: 0.24,
      localTrueSolarTime: '14:26 MTC',
      dustStormAlert: false,
    );
  }

  String get tauStatus {
    if (opticalDepthTau < 0.5) return 'NOMINAL CLEAR';
    if (opticalDepthTau < 1.0) return 'HAZY ATMOSPHERE';
    if (opticalDepthTau < 2.0) return 'DUST SUSPENSION';
    return 'REGIONAL DUST STORM (CRITICAL)';
  }

  Color get tauStatusColor {
    if (opticalDepthTau < 0.5) return const Color(0xFF00E676);
    if (opticalDepthTau < 1.0) return const Color(0xFFFFA000);
    return const Color(0xFFFF3344);
  }
}

/// Science Mission Data Repository
class MarsScienceRepository {
  /// Chryse Planitia Sector Slope Hazards (MGS MOLA)
  static final List<MolaSlopeHazard> molaHazards = [
    // 1. Severe Escarpment Scarp across route
    MolaSlopeHazard(
      id: 'mola_scarp_alpha',
      name: 'Chryse Chasma Escarpment Scarp',
      averageSlopeDeg: 24.8,
      maxSlopeDeg: 31.2,
      severity: HazardSeverity.severe,
      centroid: const LatLng(21.78, -20.25),
      polygon: const [
        LatLng(21.68, -20.40),
        LatLng(21.82, -20.36),
        LatLng(21.88, -20.15),
        LatLng(21.75, -20.10),
        LatLng(21.66, -20.28),
      ],
      description: 'Basaltic fault scarp with unstable boulder scree and steep drop-off.',
      recommendation: 'PROHIBITED TRAVERSAL: Rover pitch limit (18°) exceeded. Route bypass required.',
    ),

    // 2. Cautionary Crater Rim Slope
    MolaSlopeHazard(
      id: 'mola_rim_bravo',
      name: 'Viking Basin Outer Rim Incline',
      averageSlopeDeg: 15.6,
      maxSlopeDeg: 18.9,
      severity: HazardSeverity.caution,
      centroid: const LatLng(22.06, -19.55),
      polygon: const [
        LatLng(21.98, -19.68),
        LatLng(22.12, -19.62),
        LatLng(22.16, -19.42),
        LatLng(22.02, -19.46),
      ],
      description: 'Moderate loose regolith incline with potential tire wheel slip of 25%.',
      recommendation: 'CAUTION: Maintain low traversal speed (< 2 km/h) with telemetry monitoring.',
    ),

    // 3. Steep Boulder Ridge
    MolaSlopeHazard(
      id: 'mola_ridge_charlie',
      name: 'South-West Chryse Crest',
      averageSlopeDeg: 26.4,
      maxSlopeDeg: 34.0,
      severity: HazardSeverity.severe,
      centroid: const LatLng(21.36, -20.85),
      polygon: const [
        LatLng(21.28, -20.98),
        LatLng(21.42, -20.90),
        LatLng(21.46, -20.75),
        LatLng(21.31, -20.78),
      ],
      description: 'Exposed bedrock cliffs with $>30^\circ$ talus slopes.',
      recommendation: 'NO-GO ZONE: Astronaut EVA tethering required if approach within 50m.',
    ),
  ];

  /// Chryse Planitia Sector Hydrated Mineral Deposits (MRO CRISM)
  static final List<CrismMineralDeposit> crismDeposits = [
    // 1. Phyllosilicate (Smectite Clay) - Prime Astrobiology Target
    CrismMineralDeposit(
      id: 'crism_clay_01',
      mineralName: 'Fe/Mg Smectite Clay (Nontronite)',
      category: MineralCategory.phyllosilicates,
      centroid: const LatLng(21.52, -20.65),
      polygon: const [
        LatLng(21.45, -20.75),
        LatLng(21.58, -20.72),
        LatLng(21.61, -20.52),
        LatLng(21.48, -20.55),
      ],
      biosignatureScore: 94.5,
      spectralAbsorption: '2.28 µm & 2.40 µm Fe-OH overtone absorption doublet',
      geologicContext: 'Ancient Noachian-era lacustrine mudstone sediment bed.',
      scienceSignificance: 'CRITICAL SAMPLE SITE: Clay minerals preserve organic macromolecules and ancient biosignatures from Mars wet aqueous era.',
    ),

    // 2. Hydrated Sulfates (Polyhydrated)
    CrismMineralDeposit(
      id: 'crism_sulfate_01',
      mineralName: 'Polyhydrated Magnesium Sulfate (Epsomite-type)',
      category: MineralCategory.sulfates,
      centroid: const LatLng(21.92, -19.95),
      polygon: const [
        LatLng(21.85, -20.08),
        LatLng(21.99, -20.02),
        LatLng(22.02, -19.82),
        LatLng(21.88, -19.86),
      ],
      biosignatureScore: 82.0,
      spectralAbsorption: '1.93 µm & 2.42 µm hydrate vibration bands',
      geologicContext: 'Hesperian-era paleolake evaporation crust.',
      scienceSignificance: 'Records the transition of Mars climate from warm-wet to hyper-arid cold conditions.',
    ),

    // 3. Magnesium Carbonates
    CrismMineralDeposit(
      id: 'crism_carbonate_01',
      mineralName: 'Magnesite & Hydromagnesite Carbonates',
      category: MineralCategory.carbonates,
      centroid: const LatLng(22.32, -19.20),
      polygon: const [
        LatLng(22.25, -19.32),
        LatLng(22.39, -19.26),
        LatLng(22.42, -19.08),
        LatLng(22.28, -19.12),
      ],
      biosignatureScore: 88.0,
      spectralAbsorption: '2.31 µm & 2.52 µm planar radical asymmetric stretch',
      geologicContext: 'Alkaline aqueous alteration rind on olivine-bearing basalt.',
      scienceSignificance: 'Proves presence of neutral-to-alkaline ancient surface waters favorable for microbial prebiotic chemistry.',
    ),
  ];

  /// Chryse Planitia Subsurface Water Ice Ground Units (Mars Odyssey THEMIS)
  static final List<ThemisIceDeposit> themisIceUnits = [
    // 1. Shallow Permafrost Layer
    ThemisIceDeposit(
      id: 'themis_ice_01',
      unitName: 'Chryse Subsurface Permafrost Slab A',
      depthMinMeters: 0.25,
      depthMaxMeters: 0.65,
      waterEquivalentHydrogenPct: 32.5,
      centroid: const LatLng(21.68, -20.90),
      polygon: const [
        LatLng(21.60, -21.02),
        LatLng(21.75, -20.96),
        LatLng(21.78, -20.78),
        LatLng(21.63, -20.82),
      ],
      estimatedVolumeM3: 38500.0,
      extractionViability: 'OPTIMAL: Accessible via standard rotary sublimation drill (depth < 0.5m).',
      scientificNotes: 'Porous regolith pore-ice matrix. Provides direct ISRU drinking water and propellant feedstock ($H_2 / O_2$).',
    ),

    // 2. Deep Massive Ice Deposit
    ThemisIceDeposit(
      id: 'themis_ice_02',
      unitName: 'North Chryse Glacial Basal Ice Unit',
      depthMinMeters: 0.75,
      depthMaxMeters: 1.40,
      waterEquivalentHydrogenPct: 26.0,
      centroid: const LatLng(22.22, -19.70),
      polygon: const [
        LatLng(22.15, -19.82),
        LatLng(22.29, -19.76),
        LatLng(22.32, -19.56),
        LatLng(22.18, -19.60),
      ],
      estimatedVolumeM3: 74200.0,
      extractionViability: 'MODERATE: Requires heavy percussion coring assembly.',
      scientificNotes: 'Likely buried relic glacier ice covered by protective insulating mantling dust.',
    ),
  ];
}
