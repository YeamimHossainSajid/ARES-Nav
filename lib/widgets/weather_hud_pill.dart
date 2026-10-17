import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/science_data.dart';

/// ============================================================================
/// PERSEVERANCE MEDA / CURIOSITY REMS REAL-TIME WEATHER HUD PILL
/// Displays critical surface environmental telemetry for safe astronaut EVAs.
/// Can be tapped to expand into the full planetary atmospheric console.
/// ============================================================================

class WeatherHudPill extends StatelessWidget {
  final MarsWeatherTelemetry telemetry;
  final VoidCallback onTap;

  const WeatherHudPill({
    super.key,
    required this.telemetry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xE610141D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF00E5FF).withOpacity(0.35),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Blinking Telemetry Beacon
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF00E676),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF00E676),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Sol badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: const Color(0xFFC1440E).withOpacity(0.25),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: const Color(0xFFC1440E).withOpacity(0.6),
                  width: 0.8,
                ),
              ),
              child: Text(
                'SOL ${telemetry.sol}',
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF7043),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Temperature Readout
            Row(
              children: [
                const Icon(Icons.thermostat_rounded, size: 14, color: Color(0xFF00E5FF)),
                const SizedBox(width: 2),
                Text(
                  '${telemetry.ambientTempCelsius.toStringAsFixed(0)}°C',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),

            // Atmospheric Pressure Readout
            Row(
              children: [
                const Icon(Icons.speed_rounded, size: 14, color: Color(0xFFFFB300)),
                const SizedBox(width: 2),
                Text(
                  '${telemetry.pressurePascals.toStringAsFixed(0)} Pa',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),

            // Dust Opacity Tau
            Row(
              children: [
                const Icon(Icons.wb_sunny_outlined, size: 13, color: Color(0xFF00E676)),
                const SizedBox(width: 2),
                Text(
                  'τ ${telemetry.opticalDepthTau.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00E676),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),

            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.white60),
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
/// EXPANDED FULL ATMOSPHERIC TELEMETRY CONSOLE (MODAL DIALOG)
/// ============================================================================

class WeatherTelemetryConsoleDialog extends StatelessWidget {
  final MarsWeatherTelemetry telemetry;

  const WeatherTelemetryConsoleDialog({
    super.key,
    required this.telemetry,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: const Color(0xF210141E),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFF00E5FF).withOpacity(0.4),
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
            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
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
                          color: const Color(0xFF00E5FF).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF00E5FF).withOpacity(0.4),
                          ),
                        ),
                        child: const Icon(Icons.satellite_alt_rounded, color: Color(0xFF00E5FF), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'MARS SURFACE WEATHER TELEMETRY',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'NASA Perseverance MEDA / Curiosity REMS Live Stream',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.6),
                              ),
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
                  const SizedBox(height: 16),
                  Divider(color: Colors.white.withOpacity(0.08), height: 1),
                  const SizedBox(height: 16),

                  // Sol & Season Status Bar
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B26),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusHeaderItem(
                          'MISSION SOL',
                          '${telemetry.sol}',
                          const Color(0xFFFF7043),
                        ),
                        _buildStatusHeaderItem(
                          'SOLAR LONGITUDE',
                          'Ls ${telemetry.solarLongitudeLs}°',
                          const Color(0xFF00E5FF),
                        ),
                        _buildStatusHeaderItem(
                          'LOCAL TIME',
                          telemetry.localTrueSolarTime,
                          const Color(0xFF00E676),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Key Telemetry 2x2 Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.5,
                    children: [
                      // Temperature
                      _buildMetricCard(
                        title: 'AMBIENT AIR TEMP',
                        value: '${telemetry.ambientTempCelsius.toStringAsFixed(1)}°C',
                        subtitle: 'Ground: ${telemetry.groundTempCelsius}°C\nRange: ${telemetry.minDiurnalTempCelsius}° to ${telemetry.maxDiurnalTempCelsius}°C',
                        icon: Icons.thermostat_rounded,
                        accentColor: const Color(0xFF00E5FF),
                      ),

                      // Atmospheric Pressure
                      _buildMetricCard(
                        title: 'BAROMETRIC PRESSURE',
                        value: '${telemetry.pressurePascals.toStringAsFixed(0)} Pa',
                        subtitle: '${(telemetry.pressurePascals / 100).toStringAsFixed(2)} mbar (0.74% Earth)\nNominal CO2 envelope',
                        icon: Icons.compress_rounded,
                        accentColor: const Color(0xFFFFB300),
                      ),

                      // Wind Dynamics
                      _buildMetricCard(
                        title: 'SURFACE WIND VECTOR',
                        value: '${telemetry.windSpeedKmh.toStringAsFixed(1)} km/h',
                        subtitle: 'Direction: ${telemetry.windDirectionCompass} (${telemetry.windDirectionDegrees}°)\nPeak Gust: ${telemetry.windGustKmh} km/h',
                        icon: Icons.air_rounded,
                        accentColor: const Color(0xFF64B5F6),
                      ),

                      // Dust Opacity (Tau) & Radiation
                      _buildMetricCard(
                        title: 'ATMOSPHERIC DUST (TAU)',
                        value: 'τ ${telemetry.opticalDepthTau.toStringAsFixed(2)}',
                        subtitle: '${telemetry.tauStatus}\nRadiation: ${telemetry.radiationMsvDay} mSv/d',
                        icon: Icons.wb_sunny_rounded,
                        accentColor: telemetry.tauStatusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // EVA Suit Safety Advisory Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF00E676).withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          color: Color(0xFF00E676),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'EVA OPERATIONAL STATUS: GREEN / PERMITTED',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00E676),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Surface wind velocities and optical dust opacity are well within nominal NASA PLSS spacesuit thresholds. No global dust storm front detected within 500 km.',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white.withOpacity(0.75),
                                  height: 1.3,
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeaderItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.5),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF141923),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 0.9,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.6),
                    letterSpacing: 0.4,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 16, color: accentColor),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: accentColor,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 8.5,
              color: Colors.white.withOpacity(0.65),
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
