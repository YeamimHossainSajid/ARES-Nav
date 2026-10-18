import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/lens_state_controller.dart';
import '../observation/science_models.dart';

class ObservationDetailSheet extends StatelessWidget {
  final LensStateController controller;

  const ObservationDetailSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final quake = controller.selectedMarsquake;
    final isRoverSelected = controller.hasSelectedRover;

    if (quake == null && !isRoverSelected) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xF211151E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: quake != null ? const Color(0xFFFF3344) : const Color(0xFF00E676),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: quake != null
                  ? _buildMarsquakeContent(context, quake)
                  : _buildRoverContent(context, controller.roverTrack),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarsquakeContent(BuildContext context, MarsquakeEvent quake) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3344).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.waves, size: 20, color: Color(0xFFFF3344)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'SEISMIC EVENT // ${quake.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF3344),
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3344).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFFF3344), width: 0.8),
                        ),
                        child: Text(
                          'CLASS ${quake.qualityClass}',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF3344),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${quake.seismicRegion} • Sol ${quake.sol}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white60, size: 20),
              onPressed: () => controller.clearSelection(),
            ),
          ],
        ),
        const Divider(color: Color(0x33FFFFFF), height: 20),

        // Metrics Grid
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMetricItem('MAGNITUDE', 'M ${quake.magnitude.toStringAsFixed(1)}', const Color(0xFFFF3344)),
            _buildMetricItem('FOCAL DEPTH', '${quake.depthKm.toStringAsFixed(0)} km', const Color(0xFF00D8D6)),
            _buildMetricItem('LOCATION', '${quake.location.latitude.toStringAsFixed(1)}°N, ${quake.location.longitude.toStringAsFixed(1)}°E', Colors.white),
            _buildMetricItem('SOURCE', 'InSight SEIS', const Color(0xFF00E676)),
          ],
        ),
        const SizedBox(height: 10),

        // Description
        Text(
          quake.description,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.8),
            fontStyle: FontStyle.italic,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildRoverContent(BuildContext context, RoverScienceTrack rover) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.directions_car, size: 20, color: Color(0xFF00E676)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rover.callsign.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00E676),
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    'Sol ${rover.sol} • Odometer: ${rover.totalOdometerKm} km • ${rover.samplesCollected} Cored Samples',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white60, size: 20),
              onPressed: () => controller.clearSelection(),
            ),
          ],
        ),
        const Divider(color: Color(0x33FFFFFF), height: 20),

        Text(
          'CURRENT OBJECTIVE: ${rover.currentActivity}',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00D8D6),
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 6),

        // Instruments Telemetry
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: rover.instrumentTelemetry.entries.map((entry) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF161C28),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0x3300D8D6)),
              ),
              child: Text(
                '${entry.key}: ${entry.value}',
                style: const TextStyle(fontSize: 9, color: Colors.white70, fontFamily: 'monospace'),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 8, color: Colors.white.withValues(alpha: 0.5), fontFamily: 'monospace'),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color, fontFamily: 'monospace'),
        ),
      ],
    );
  }
}
