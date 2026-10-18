import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../core/lens_state_controller.dart';
import 'science_models.dart';

class ObservationLayer extends StatelessWidget {
  final LensStateController controller;

  const ObservationLayer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Perseverance Rover Traverse Polyline (Safe EVA Route)
        if (controller.showRoverTrack)
          PolylineLayer(
            polylines: [
              // Outer neon glow
              Polyline(
                points: controller.roverTrack.traversedWaypoints,
                strokeWidth: 5.0,
                color: const Color(0xFF00E676).withValues(alpha: 0.35),
              ),
              // Inner sharp green track
              Polyline(
                points: controller.roverTrack.traversedWaypoints,
                strokeWidth: 2.2,
                color: const Color(0xFF00E676),
                pattern: StrokePattern.dashed(segments: const [6, 4]),
              ),
            ],
          ),

        // 2. Interactive Markers: Marsquakes & Rovers
        MarkerLayer(
          markers: [
            // Perseverance Rover Marker
            if (controller.showRoverTrack)
              _buildRoverMarker(controller.roverTrack),

            // InSight Marsquake SEIS Event Markers
            if (controller.showMarsquakes)
              ...MarsquakeEvent.mockInSightCatalog.map(
                (quake) => _buildMarsquakeMarker(quake),
              ),
          ],
        ),
      ],
    );
  }

  Marker _buildRoverMarker(RoverScienceTrack rover) {
    return Marker(
      point: rover.currentPosition,
      width: 72,
      height: 72,
      child: GestureDetector(
        onTap: () => controller.selectRover(rover),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xCC0D0F14),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF00E676), width: 1.0),
              ),
              child: const Text(
                'M2020 PERCY',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00E676),
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF131822),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00E676), width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E676).withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.directions_car_filled,
                size: 18,
                color: Color(0xFF00E676),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Marker _buildMarsquakeMarker(MarsquakeEvent quake) {
    final isSelected = controller.selectedMarsquake?.id == quake.id;
    final color = quake.magnitude >= 4.0
        ? const Color(0xFFFF3344) // Alert Red for major quakes (>M4.0)
        : const Color(0xFFFF9100); // Warning Amber for moderate quakes

    return Marker(
      point: quake.location,
      width: 64,
      height: 64,
      child: GestureDetector(
        onTap: () => controller.selectMarsquake(quake),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
              decoration: BoxDecoration(
                color: const Color(0xDD0D0F14),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color, width: 1.0),
              ),
              child: Text(
                'M${quake.magnitude.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: color,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: isSelected ? 30 : 24,
              height: isSelected ? 30 : 24,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.25),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: isSelected ? 2.2 : 1.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: isSelected ? 12 : 6,
                  ),
                ],
              ),
              child: Icon(
                Icons.waves,
                size: isSelected ? 16 : 13,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
