import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../models/science_data.dart';

/// ============================================================================
/// SCIENCE TARGET DETAIL CARD
/// High-fidelity modal inspecting telemetry from MOLA, CRISM, or THEMIS instruments.
/// ============================================================================

class ScienceDetailDialog extends StatelessWidget {
  final dynamic target; // MolaSlopeHazard, CrismMineralDeposit, or ThemisIceDeposit
  final VoidCallback onSetAsWaypoint;

  const ScienceDetailDialog({
    super.key,
    required this.target,
    required this.onSetAsWaypoint,
  });

  @override
  Widget build(BuildContext context) {
    if (target is MolaSlopeHazard) {
      return _buildMolaHazardCard(context, target as MolaSlopeHazard);
    } else if (target is CrismMineralDeposit) {
      return _buildCrismMineralCard(context, target as CrismMineralDeposit);
    } else if (target is ThemisIceDeposit) {
      return _buildThemisIceCard(context, target as ThemisIceDeposit);
    }
    return const SizedBox.shrink();
  }

  Widget _buildBaseCard({
    required BuildContext context,
    required String missionBadge,
    required Color accentColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required LatLng coordinates,
    required List<Widget> bodyContent,
    required String buttonText,
    required VoidCallback onAction,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: const Color(0xF210141F),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: accentColor.withOpacity(0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.7),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: accentColor.withOpacity(0.5),
                          ),
                        ),
                        child: Icon(icon, color: accentColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: accentColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: accentColor.withOpacity(0.6), width: 0.8),
                                  ),
                                  child: Text(
                                    missionBadge,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: accentColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white60),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(color: Colors.white.withOpacity(0.08), height: 1),
                  const SizedBox(height: 14),

                  // Coordinates & Subtitle Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B26),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                          ),
                        ),
                        Text(
                          '${coordinates.latitude.toStringAsFixed(3)}°, ${coordinates.longitude.toStringAsFixed(3)}°',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.5),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Body Content
                  ...bodyContent,
                  const SizedBox(height: 18),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onAction();
                      },
                      icon: const Icon(Icons.navigation_rounded, size: 18),
                      label: Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMolaHazardCard(BuildContext context, MolaSlopeHazard hazard) {
    return _buildBaseCard(
      context: context,
      missionBadge: 'MGS / MOLA ALTIMETER',
      accentColor: hazard.displayColor,
      icon: Icons.warning_amber_rounded,
      title: hazard.name,
      subtitle: 'SLOPE INCLINE: ${hazard.averageSlopeDeg.toStringAsFixed(1)}° (MAX ${hazard.maxSlopeDeg.toStringAsFixed(1)}°)',
      coordinates: hazard.centroid,
      buttonText: 'SET AS HAZARD AVOIDANCE WAYPOINT',
      onAction: onSetAsWaypoint,
      bodyContent: [
        _buildInfoBox(
          title: 'TERRAIN MORPHOLOGY',
          content: hazard.description,
          borderColor: Colors.white12,
        ),
        const SizedBox(height: 10),
        _buildInfoBox(
          title: 'ARES NAV SAFETY ADVISORY',
          content: hazard.recommendation,
          borderColor: hazard.displayColor.withOpacity(0.5),
          backgroundColor: hazard.displayColor.withOpacity(0.1),
        ),
      ],
    );
  }

  Widget _buildCrismMineralCard(BuildContext context, CrismMineralDeposit deposit) {
    return _buildBaseCard(
      context: context,
      missionBadge: 'MRO / CRISM SPECTROMETER',
      accentColor: deposit.categoryColor,
      icon: Icons.biotech_rounded,
      title: deposit.mineralName,
      subtitle: deposit.categoryLabel,
      coordinates: deposit.centroid,
      buttonText: 'DESIGNATE AS PRIMARY SCIENCE WAYPOINT',
      onAction: onSetAsWaypoint,
      bodyContent: [
        // Biosignature Score Bar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF161B26),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: deposit.categoryColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ASTROBIOLOGY BIOSIGNATURE POTENTIAL',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '${deposit.biosignatureScore.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: deposit.categoryColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: deposit.biosignatureScore / 100.0,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(deposit.categoryColor),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _buildInfoBox(
          title: 'SPECTRAL DIAGNOSTIC ABSORPTION',
          content: deposit.spectralAbsorption,
          borderColor: Colors.white12,
        ),
        const SizedBox(height: 10),
        _buildInfoBox(
          title: 'GEOLOGIC EVOLUTION & SIGNIFICANCE',
          content: '${deposit.geologicContext}\n\n${deposit.scienceSignificance}',
          borderColor: deposit.categoryColor.withOpacity(0.4),
        ),
      ],
    );
  }

  Widget _buildThemisIceCard(BuildContext context, ThemisIceDeposit ice) {
    return _buildBaseCard(
      context: context,
      missionBadge: 'ODYSSEY / THEMIS THERMAL IR',
      accentColor: ice.displayColor,
      icon: Icons.ac_unit_rounded,
      title: ice.unitName,
      subtitle: 'ISRU WATER-ICE HORIZON (WEH ${ice.waterEquivalentHydrogenPct.toStringAsFixed(0)}%)',
      coordinates: ice.centroid,
      buttonText: 'SET AS ISRU DRILL SITE DESTINATION',
      onAction: onSetAsWaypoint,
      bodyContent: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                label: 'BURIAL DEPTH',
                value: '${ice.depthMinMeters.toStringAsFixed(2)} - ${ice.depthMaxMeters.toStringAsFixed(2)} m',
                color: ice.displayColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricTile(
                label: 'ESTIMATED ICE YIELD',
                value: '${ice.estimatedVolumeM3.toStringAsFixed(0)} m³',
                color: const Color(0xFF00E676),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildInfoBox(
          title: 'ISRU EXTRACTION PROTOCOL',
          content: ice.extractionViability,
          borderColor: ice.displayColor.withOpacity(0.4),
        ),
        const SizedBox(height: 10),
        _buildInfoBox(
          title: 'IN-SITU RESOURCE UTILIZATION VALUE',
          content: ice.scientificNotes,
          borderColor: Colors.white12,
        ),
      ],
    );
  }

  Widget _buildMetricTile({required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF161B26),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox({
    required String title,
    required String content,
    required Color borderColor,
    Color backgroundColor = const Color(0xFF161B26),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.6),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              fontSize: 10.5,
              color: Colors.white,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
