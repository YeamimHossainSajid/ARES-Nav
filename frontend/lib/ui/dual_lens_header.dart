import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/lens_state_controller.dart';
import '../map/mars_tile_sources.dart';

class DualLensHeader extends StatelessWidget {
  final LensStateController controller;

  const DualLensHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isObs = controller.isObservationMode;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xDD131822),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isObs ? const Color(0xFF00D8D6) : const Color(0xFFFF9100),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Row 1: Dual-Lens Mode Switcher + NASA Badge
                Row(
                  children: [
                    // System Identifier
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC1440E).withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFC1440E)),
                          ),
                          child: const Icon(Icons.public, size: 16, color: Color(0xFFD9531E)),
                        ),
                        const SizedBox(width: 8),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ARES NAV // DUAL-LENS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                                color: Colors.white,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              'NASA SPACE APPS 2026',
                              style: TextStyle(
                                fontSize: 8,
                                color: Color(0xFF00D8D6),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),

                    // DUAL-LENS MODE SWITCHER PILL
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0D12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLensTab(
                            title: 'OBSERVATION',
                            icon: Icons.biotech,
                            isActive: isObs,
                            activeColor: const Color(0xFF00D8D6),
                            onTap: () => controller.setLens(MarsLensMode.observation),
                          ),
                          _buildLensTab(
                            title: 'SIMULATION',
                            icon: Icons.gamepad,
                            isActive: !isObs,
                            activeColor: const Color(0xFFFF9100),
                            onTap: () => controller.setLens(MarsLensMode.simulation),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Row 2: NASA WMTS Tile Source Selector & Quick Layer Toggles
                Row(
                  children: [
                    // Active NASA Tile Dropdown Menu
                    _buildTileSourceDropdown(context),
                    const Spacer(),

                    // Layer Toggles
                    _buildIconButton(
                      icon: Icons.waves,
                      tooltip: 'Toggle InSight Marsquake Events',
                      isActive: controller.showMarsquakes,
                      activeColor: const Color(0xFFFF3344),
                      onPressed: () => controller.toggleMarsquakes(),
                    ),
                    const SizedBox(width: 6),
                    _buildIconButton(
                      icon: Icons.directions_car,
                      tooltip: 'Toggle Perseverance Rover Track',
                      isActive: controller.showRoverTrack,
                      activeColor: const Color(0xFF00E676),
                      onPressed: () => controller.toggleRoverTrack(),
                    ),
                    const SizedBox(width: 6),
                    _buildIconButton(
                      icon: Icons.grid_4x4,
                      tooltip: 'Toggle Coordinate Grid',
                      isActive: controller.showCoordinateGrid,
                      activeColor: const Color(0xFF00D8D6),
                      onPressed: () => controller.toggleGrid(),
                    ),
                    const SizedBox(width: 6),
                    _buildIconButton(
                      icon: Icons.my_location,
                      tooltip: 'Center on Jezero Crater Delta',
                      isActive: true,
                      activeColor: Colors.white,
                      onPressed: () => controller.recenterJezero(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLensTab({
    required String title,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? activeColor : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isActive ? activeColor : Colors.white60),
            const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                color: isActive ? Colors.white : Colors.white60,
                letterSpacing: 0.8,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTileSourceDropdown(BuildContext context) {
    return PopupMenuButton<MarsTileSource>(
      initialValue: controller.activeTileSource,
      tooltip: 'Select NASA WMTS Orbital Tile Layer',
      color: const Color(0xFF131822),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF00D8D6), width: 1.0),
      ),
      onSelected: (source) => controller.setTileSource(source),
      itemBuilder: (context) => MarsTileSource.allSources.map((source) {
        final isSelected = controller.activeTileSource.type == source.type;
        return PopupMenuItem<MarsTileSource>(
          value: source,
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_off,
                size: 16,
                color: isSelected ? const Color(0xFF00D8D6) : Colors.white38,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    source.badgeText,
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white.withValues(alpha: 0.6),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF161C28),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0x3300D8D6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.layers, size: 14, color: Color(0xFF00D8D6)),
            const SizedBox(width: 6),
            Text(
              controller.activeTileSource.badgeText,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFF00D8D6)),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? activeColor.withValues(alpha: 0.20) : const Color(0xFF161C28),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? activeColor : Colors.white24,
              width: 1.0,
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isActive ? activeColor : Colors.white60,
          ),
        ),
      ),
    );
  }
}
