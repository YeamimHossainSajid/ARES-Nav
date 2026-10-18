import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/lens_state_controller.dart';
import '../observation/observation_layer.dart';

class MarsBaseMap extends StatelessWidget {
  final LensStateController controller;
  final Widget? simulationOverlay; // Injected Flame GameWidget for Lens 2

  const MarsBaseMap({
    super.key,
    required this.controller,
    this.simulationOverlay,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller.mapController,
      options: const MapOptions(
        initialCenter: LensStateController.jezeroCraterCenter,
        initialZoom: 7.5,
        minZoom: 1.5,
        maxZoom: 14.0,
        backgroundColor: Color(0xFF0D0F14), // Dark Space Slate background
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        // 1. BASE TILE LAYER: NASA Planetary Data System WMTS Tiles
        TileLayer(
          urlTemplate: controller.activeTileSource.urlTemplate,
          userAgentPackageName: 'gov.nasa.ares.mars_nav',
          minZoom: controller.activeTileSource.minZoom.toDouble(),
          maxZoom: controller.activeTileSource.maxZoom.toDouble(),
          tileProvider: NetworkTileProvider(),
          errorTileCallback: (tile, error, stackTrace) {
            // Graceful fallback logging when NASA PDS rate-limits or offline
            debugPrint('NASA WMTS Tile Error: $error at ${tile.coordinates}');
          },
        ),

        // 2. MOLA LAT/LON COORDINATE GRID LINES
        if (controller.showCoordinateGrid)
          _buildCoordinateGridOverlay(),

        // 3. LENS 1: Observation Mode Layer (Active in Science Mode)
        if (controller.isObservationMode)
          ObservationLayer(controller: controller),

        // 4. LENS 2: Simulation Mode Flame Engine Layer (Stacked in Sandbox Mode)
        if (controller.isSimulationMode && simulationOverlay != null)
          simulationOverlay!,
      ],
    );
  }

  Widget _buildCoordinateGridOverlay() {
    // Subtle coordinate lines at 10-degree increments
    final lines = <Polyline>[];
    for (double lat = -80; lat <= 80; lat += 20) {
      lines.add(
        Polyline(
          points: [LatLng(lat, -180), LatLng(lat, 180)],
          color: const Color(0x2200D8D6),
          strokeWidth: 0.8,
        ),
      );
    }
    for (double lon = -180; lon <= 180; lon += 30) {
      lines.add(
        Polyline(
          points: [LatLng(-85, lon), LatLng(85, lon)],
          color: const Color(0x2200D8D6),
          strokeWidth: 0.8,
        ),
      );
    }
    return PolylineLayer(polylines: lines);
  }
}
