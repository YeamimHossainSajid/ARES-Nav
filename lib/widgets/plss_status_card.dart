import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/navigation_route.dart';

/// ============================================================================
/// PHASE 2: PLSS (PORTABLE LIFE SUPPORT SYSTEM) CONSUMABLES & PNR HUD
/// Monitors astronaut suit reserves (O2, battery, water cooling) and
/// computes real-time Point-of-No-Return (PNR) margins.
/// ============================================================================

class PlssQuickStatusBadge extends StatelessWidget {
  final PlssConsumables plss;
  final double currentDistanceKm;
  final VoidCallback onTap;

  const PlssQuickStatusBadge({
    super.key,
    required this.plss,
    required this.currentDistanceKm,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final marginMinutes = plss.returnMarginMinutes(currentDistanceKm);
    final bool isSafe = currentDistanceKm <= plss.safeReturnRadiusKm;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xEE10141E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSafe ? const Color(0xFF00E676).withOpacity(0.5) : const Color(0xFFFF3344).withOpacity(0.6),
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
            // Pulse Beacon
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSafe ? const Color(0xFF00E676) : const Color(0xFFFF3344),
                boxShadow: [
                  BoxShadow(
                    color: isSafe ? const Color(0xFF00E676) : const Color(0xFFFF3344),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // O2 Badge
            Row(
              children: [
                const Icon(Icons.air_rounded, size: 13, color: Color(0xFF00E5FF)),
                const SizedBox(width: 3),
                Text(
                  '${plss.oxygenPct.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),

            // Battery Badge
            Row(
              children: [
                const Icon(Icons.battery_charging_full_rounded, size: 13, color: Color(0xFF00E676)),
                const SizedBox(width: 2),
                Text(
                  '${plss.batteryPct.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),

            // PNR Status Text
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSafe ? const Color(0xFF00E676).withOpacity(0.18) : const Color(0xFFFF3344).withOpacity(0.18),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isSafe ? 'PNR +${marginMinutes}m' : 'PNR ALERT',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isSafe ? const Color(0xFF00E676) : const Color(0xFFFF3344),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
/// EXPANDED PLSS LIFE SUPPORT SYSTEM TELEMETRY CONSOLE
/// ============================================================================

class PlssTelemetryModal extends StatelessWidget {
  final PlssConsumables plss;
  final double currentDistanceKm;

  const PlssTelemetryModal({
    super.key,
    required this.plss,
    required this.currentDistanceKm,
  });

  @override
  Widget build(BuildContext context) {
    final marginMinutes = plss.returnMarginMinutes(currentDistanceKm);
    final bool isSafe = currentDistanceKm <= plss.safeReturnRadiusKm;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: const Color(0xF210141F),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSafe ? const Color(0xFF00E676).withOpacity(0.5) : const Color(0xFFFF3344).withOpacity(0.6),
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
                          color: const Color(0xFF00E676).withOpacity(0.14),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF00E676).withOpacity(0.4),
                          ),
                        ),
                        child: const Icon(Icons.health_and_safety_rounded, color: Color(0xFF00E676), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PLSS SPACESUIT LIFE SUPPORT',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.6,
                              ),
                            ),
                            Text(
                              'Astronaut EVA-1 Consumables & Point-of-No-Return Telemetry',
                              style: TextStyle(
                                fontSize: 9.5,
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
                  const SizedBox(height: 14),
                  Divider(color: Colors.white.withOpacity(0.08), height: 1),
                  const SizedBox(height: 14),

                  // Consumables Progress Bars
                  _buildConsumableBar(
                    label: 'O2 PRIMARY RESERVE',
                    percentage: plss.oxygenPct,
                    remainingText: '${plss.oxygenRemainingHours.toStringAsFixed(1)} hours remaining',
                    color: const Color(0xFF00E5FF),
                    icon: Icons.air_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildConsumableBar(
                    label: 'SUIT BATTERY POWER',
                    percentage: plss.batteryPct,
                    remainingText: '${plss.batteryRemainingHours.toStringAsFixed(1)} hours remaining',
                    color: const Color(0xFF00E676),
                    icon: Icons.battery_charging_full_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildConsumableBar(
                    label: 'SUBLIMATION COOLING WATER',
                    percentage: plss.coolingWaterPct,
                    remainingText: 'Thermal loop operational',
                    color: const Color(0xFF64B5F6),
                    icon: Icons.water_drop_rounded,
                  ),
                  const SizedBox(height: 16),

                  // PNR Dynamics Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B26),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSafe ? const Color(0xFF00E676).withOpacity(0.3) : const Color(0xFFFF3344).withOpacity(0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'POINT-OF-NO-RETURN (PNR) METRICS',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSafe ? const Color(0xFF00E676).withOpacity(0.2) : const Color(0xFFFF3344).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isSafe ? 'SAFE MARGIN' : 'CRITICAL MARGIN',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  color: isSafe ? const Color(0xFF00E676) : const Color(0xFFFF3344),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricItem(
                                'SAFE RETURN RADIUS',
                                '${plss.safeReturnRadiusKm.toStringAsFixed(1)} km',
                                '25% Reserve Limit',
                                const Color(0xFF00E676),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMetricItem(
                                'ABSOLUTE PNR RADIUS',
                                '${plss.absolutePnrRadiusKm.toStringAsFixed(1)} km',
                                '0% Depletion Horizon',
                                const Color(0xFFFF3344),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricItem(
                                'CURRENT DISTANCE',
                                '${currentDistanceKm.toStringAsFixed(1)} km',
                                'From EVA-1 Base',
                                Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMetricItem(
                                'RETURN TIME MARGIN',
                                '$marginMinutes min',
                                'Buffer before PNR',
                                isSafe ? const Color(0xFF00E676) : const Color(0xFFFF3344),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Metabolic stats
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF141924),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.favorite_rounded, size: 16, color: Color(0xFFFF3344)),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'HEART RATE',
                                    style: TextStyle(fontSize: 8, color: Colors.white.withOpacity(0.5)),
                                  ),
                                  Text(
                                    '${plss.heartRateBpm} BPM',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF141924),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFFFB300)),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'WORKLOAD',
                                    style: TextStyle(fontSize: 8, color: Colors.white.withOpacity(0.5)),
                                  ),
                                  Text(
                                    '${plss.metabolicRateWatts} Watts',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConsumableBar({
    required String label,
    required double percentage,
    required String remainingText,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: (percentage / 100.0).clamp(0.0, 1.0),
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          remainingText,
          style: TextStyle(
            fontSize: 8.5,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String title, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF11151F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 7.5,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 7.5,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
