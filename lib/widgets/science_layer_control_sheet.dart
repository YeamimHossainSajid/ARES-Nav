import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// ============================================================================
/// NASA MULTI-MISSION SCIENCE LAYERS CONTROL PANEL
/// Allows astronauts and mission controllers to independently toggle and inspect:
/// 1. MGS MOLA Slope Hazards
/// 2. MRO CRISM Hydrated Minerals
/// 3. Mars Odyssey THEMIS Subsurface Water Ice
/// 4. Environmental Weather HUD
/// ============================================================================

class ScienceLayerControlSheet extends StatelessWidget {
  final bool showMolaHazards;
  final bool showCrismMinerals;
  final bool showThemisIce;
  final bool showWeatherHud;
  final ValueChanged<bool> onToggleMola;
  final ValueChanged<bool> onToggleCrism;
  final ValueChanged<bool> onToggleThemis;
  final ValueChanged<bool> onToggleWeather;

  const ScienceLayerControlSheet({
    super.key,
    required this.showMolaHazards,
    required this.showCrismMinerals,
    required this.showThemisIce,
    required this.showWeatherHud,
    required this.onToggleMola,
    required this.onToggleCrism,
    required this.onToggleThemis,
    required this.onToggleWeather,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      decoration: BoxDecoration(
        color: const Color(0xF410141F),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: const Color(0xFF00E5FF).withOpacity(0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF00E5FF).withOpacity(0.4),
                            ),
                          ),
                          child: const Icon(Icons.science_rounded, color: Color(0xFF00E5FF), size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NASA SCIENCE MISSION OVERLAYS',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.6,
                              ),
                            ),
                            Text(
                              'Multi-Sensor Surface & Subsurface Intelligence',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white60, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      splashRadius: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Toggle 1: MGS MOLA Slope Hazards
                _buildLayerTile(
                  title: 'MGS MOLA SLOPE HAZARD MODEL',
                  subtitle: 'Laser Altimeter terrain incline: >20° red hazards & 12°-20° caution scree',
                  missionBadge: 'MGS / MOLA',
                  badgeColor: const Color(0xFFFF3344),
                  icon: Icons.warning_amber_rounded,
                  value: showMolaHazards,
                  onChanged: onToggleMola,
                ),
                const SizedBox(height: 10),

                // Toggle 2: MRO CRISM Hydrated Minerals
                _buildLayerTile(
                  title: 'MRO CRISM HYDRATED MINERALOGY',
                  subtitle: 'IR Spectrometer: Fe/Mg smectite clays, sulfates, and ancient lacustrine carbonates',
                  missionBadge: 'MRO / CRISM',
                  badgeColor: const Color(0xFF00E5FF),
                  icon: Icons.biotech_rounded,
                  value: showCrismMinerals,
                  onChanged: onToggleCrism,
                ),
                const SizedBox(height: 10),

                // Toggle 3: Mars Odyssey THEMIS Subsurface Ice
                _buildLayerTile(
                  title: 'ODYSSEY THEMIS SUBSURFACE WATER ICE',
                  subtitle: 'Thermal IR & Epithermal Neutron detector: 0-1m depth ISRU water deposits',
                  missionBadge: 'ODYSSEY / THEMIS',
                  badgeColor: const Color(0xFF40C4FF),
                  icon: Icons.ac_unit_rounded,
                  value: showThemisIce,
                  onChanged: onToggleThemis,
                ),
                const SizedBox(height: 10),

                // Toggle 4: Weather HUD
                _buildLayerTile(
                  title: 'PERSEVERANCE MEDA WEATHER HUD',
                  subtitle: 'Real-time Sol environmental telemetry: temperature, wind vector, atmospheric dust tau',
                  missionBadge: 'M2020 / MEDA',
                  badgeColor: const Color(0xFF00E676),
                  icon: Icons.air_rounded,
                  value: showWeatherHud,
                  onChanged: onToggleWeather,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayerTile({
    required String title,
    required String subtitle,
    required String missionBadge,
    required Color badgeColor,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: value ? badgeColor.withOpacity(0.08) : const Color(0xFF151922),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value ? badgeColor.withOpacity(0.5) : Colors.white10,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: badgeColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: badgeColor.withOpacity(0.5), width: 0.8),
                      ),
                      child: Text(
                        missionBadge,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: Colors.white.withOpacity(0.6),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            activeColor: badgeColor,
            activeTrackColor: badgeColor.withOpacity(0.4),
            inactiveThumbColor: Colors.white38,
            inactiveTrackColor: Colors.white10,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
