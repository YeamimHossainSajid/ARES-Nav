import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/navigation_route.dart';

/// ============================================================================
/// PHASE 2: MOLA 2D CROSS-SECTIONAL ELEVATION PROFILE DRAWER
/// Interactive mission-control telemetry drawer plotting Martian surface topography,
/// slope angles, and hazard zones along the active Marswalk traversal path.
/// ============================================================================

class ElevationProfileDrawer extends StatefulWidget {
  final MarswalkRoute route;
  final bool isAvoidHazardsActive;
  final ValueChanged<bool> onToggleHazardAvoidance;
  final ValueChanged<ElevationSample?> onSampleScrubbed;
  final ValueChanged<MarsWaypoint> onWaypointSelected;
  final VoidCallback onClose;

  const ElevationProfileDrawer({
    super.key,
    required this.route,
    required this.isAvoidHazardsActive,
    required this.onToggleHazardAvoidance,
    required this.onSampleScrubbed,
    required this.onWaypointSelected,
    required this.onClose,
  });

  @override
  State<ElevationProfileDrawer> createState() => _ElevationProfileDrawerState();
}

class _ElevationProfileDrawerState extends State<ElevationProfileDrawer> {
  ElevationSample? _selectedSample;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final route = widget.route;

    return Container(
      constraints: const BoxConstraints(maxWidth: 620),
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xF210141F),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: widget.isAvoidHazardsActive
              ? const Color(0xFF00E676).withOpacity(0.55)
              : const Color(0xFFFFB300).withOpacity(0.55),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 28,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ==============================================================
              // HEADER BAR
              // ==============================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: widget.isAvoidHazardsActive
                            ? const Color(0xFF00E676).withOpacity(0.14)
                            : const Color(0xFFFFB300).withOpacity(0.14),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: widget.isAvoidHazardsActive
                              ? const Color(0xFF00E676).withOpacity(0.4)
                              : const Color(0xFFFFB300).withOpacity(0.4),
                        ),
                      ),
                      child: Icon(
                        Icons.show_chart_rounded,
                        color: widget.isAvoidHazardsActive
                            ? const Color(0xFF00E676)
                            : const Color(0xFFFFB300),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'MOLA ELEVATION PROFILE',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: widget.isAvoidHazardsActive
                                      ? const Color(0xFF00E676).withOpacity(0.2)
                                      : const Color(0xFFFF3344).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: widget.isAvoidHazardsActive
                                        ? const Color(0xFF00E676).withOpacity(0.5)
                                        : const Color(0xFFFF3344).withOpacity(0.5),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  widget.isAvoidHazardsActive ? 'SAFE CORRIDOR' : 'HAZARD VECTOR',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: widget.isAvoidHazardsActive
                                        ? const Color(0xFF00E676)
                                        : const Color(0xFFFF3344),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${route.totalDistanceKm.toStringAsFixed(1)} km  •  Gain +${route.totalElevationGainM} m  •  Max Slope ${route.maxSlopeDeg.toStringAsFixed(1)}°',
                            style: TextStyle(
                              fontSize: 9.5,
                              color: Colors.white.withOpacity(0.65),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Expand / Collapse toggle button
                    IconButton(
                      icon: Icon(
                        _isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
                        color: Colors.white70,
                        size: 22,
                      ),
                      onPressed: () => setState(() => _isExpanded = !_isExpanded),
                      tooltip: _isExpanded ? 'Collapse graph' : 'Expand graph',
                      splashRadius: 18,
                    ),
                    // Close button
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white60, size: 18),
                      onPressed: widget.onClose,
                      splashRadius: 18,
                    ),
                  ],
                ),
              ),

              // ==============================================================
              // ROUTE TYPE TOGGLE BAR
              // ==============================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => widget.onToggleHazardAvoidance(true),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.isAvoidHazardsActive
                                ? const Color(0xFF00E676).withOpacity(0.18)
                                : const Color(0xFF151922),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: widget.isAvoidHazardsActive
                                  ? const Color(0xFF00E676).withOpacity(0.6)
                                  : Colors.white10,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shield_rounded, size: 13, color: Color(0xFF00E676)),
                              SizedBox(width: 6),
                              Text(
                                'HAZARD BYPASS ROUTE (<10°)',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () => widget.onToggleHazardAvoidance(false),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: !widget.isAvoidHazardsActive
                                ? const Color(0xFFFF3344).withOpacity(0.18)
                                : const Color(0xFF151922),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: !widget.isAvoidHazardsActive
                                  ? const Color(0xFFFF3344).withOpacity(0.6)
                                  : Colors.white10,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning_amber_rounded, size: 13, color: Color(0xFFFF3344)),
                              SizedBox(width: 6),
                              Text(
                                'DIRECT VECTOR (>24° SCARP)',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ==============================================================
              // 2D ELEVATION PROFILE CHART
              // ==============================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: SizedBox(
                  height: _isExpanded ? 160 : 100,
                  width: double.infinity,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          _handleScrub(details.localPosition.dx, constraints.maxWidth);
                        },
                        onTapDown: (details) {
                          _handleScrub(details.localPosition.dx, constraints.maxWidth);
                        },
                        child: CustomPaint(
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: ElevationProfileChartPainter(
                            samples: route.elevationSamples,
                            selectedSample: _selectedSample,
                            minElevation: route.minElevationM,
                            maxElevation: route.maxElevationM,
                            totalDistanceKm: route.totalDistanceKm,
                            isHazardBypassed: widget.isAvoidHazardsActive,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // ==============================================================
              // SCRUBBER TELEMETRY READOUT
              // ==============================================================
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF141924),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildReadoutItem(
                      'DISTANCE',
                      _selectedSample != null
                          ? '${_selectedSample!.distanceKm.toStringAsFixed(1)} km'
                          : '${route.totalDistanceKm.toStringAsFixed(1)} km',
                      const Color(0xFF00E5FF),
                    ),
                    _buildReadoutItem(
                      'DATUM ELEV',
                      _selectedSample != null
                          ? '${_selectedSample!.elevationM} m'
                          : '${route.elevationSamples.last.elevationM} m',
                      Colors.white,
                    ),
                    _buildReadoutItem(
                      'LOCAL INCLINE',
                      _selectedSample != null
                          ? '${_selectedSample!.slopeDeg.toStringAsFixed(1)}°'
                          : '${route.maxSlopeDeg.toStringAsFixed(1)}° MAX',
                      _selectedSample != null ? _selectedSample!.slopeColor : const Color(0xFF00E676),
                    ),
                    _buildReadoutItem(
                      'EST. DURATION',
                      '${(route.estimatedWalkMinutes / 60).toStringAsFixed(1)}h EVA',
                      const Color(0xFFFFB300),
                    ),
                  ],
                ),
              ),

              // ==============================================================
              // WAYPOINTS HORIZONTAL LIST
              // ==============================================================
              if (_isExpanded && route.waypoints.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'TRAVERSAL WAYPOINTS (${route.waypoints.length}):',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.5),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: route.waypoints.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final wp = route.waypoints[index];
                      return InkWell(
                        onTap: () => widget.onWaypointSelected(wp),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: wp.isHazardBypass
                                ? const Color(0xFF00E676).withOpacity(0.12)
                                : const Color(0xFF161B26),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: wp.isHazardBypass
                                  ? const Color(0xFF00E676).withOpacity(0.4)
                                  : Colors.white12,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                wp.isHazardBypass ? Icons.check_circle_outline_rounded : Icons.place_rounded,
                                size: 12,
                                color: wp.isHazardBypass ? const Color(0xFF00E676) : const Color(0xFF00E5FF),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                wp.name,
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${wp.distanceFromStartKm.toStringAsFixed(1)}km',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  color: Colors.white.withOpacity(0.5),
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleScrub(double localX, double totalWidth) {
    if (widget.route.elevationSamples.isEmpty || totalWidth <= 0) return;
    final ratio = (localX / totalWidth).clamp(0.0, 1.0);
    final index = (ratio * (widget.route.elevationSamples.length - 1)).round();
    final sample = widget.route.elevationSamples[index];

    setState(() {
      _selectedSample = sample;
    });

    widget.onSampleScrubbed(sample);
  }

  Widget _buildReadoutItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 7.5,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

/// ============================================================================
/// CUSTOM PAINTER FOR MOLA 2D ELEVATION CURVE
/// ============================================================================

class ElevationProfileChartPainter extends CustomPainter {
  final List<ElevationSample> samples;
  final ElevationSample? selectedSample;
  final int minElevation;
  final int maxElevation;
  final double totalDistanceKm;
  final bool isHazardBypassed;

  ElevationProfileChartPainter({
    required this.samples,
    required this.selectedSample,
    required this.minElevation,
    required this.maxElevation,
    required this.totalDistanceKm,
    required this.isHazardBypassed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.length < 2) return;

    final double w = size.width;
    final double h = size.height;

    // Draw background grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 0.8;

    for (int i = 1; i <= 3; i++) {
      final y = h * (i / 4.0);
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Normalization range with 10% padding
    final elevSpan = (maxElevation - minElevation).abs();
    final effectiveSpan = elevSpan == 0 ? 100.0 : elevSpan * 1.15;
    final baseElev = minElevation - (effectiveSpan * 0.05);

    final path = ui.Path();
    final fillPath = ui.Path();

    for (int i = 0; i < samples.length; i++) {
      final s = samples[i];
      final x = (s.distanceKm / totalDistanceKm).clamp(0.0, 1.0) * w;
      final normY = ((s.elevationM - baseElev) / effectiveSpan).clamp(0.0, 1.0);
      final y = h - (normY * h);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, h);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(w, h);
    fillPath.close();

    // 1. Fill gradient under the curve
    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, h),
        [
          (isHazardBypassed ? const Color(0xFF00E676) : const Color(0xFFFF3344)).withOpacity(0.35),
          const Color(0xFF00E5FF).withOpacity(0.08),
          Colors.transparent,
        ],
      );
    canvas.drawPath(fillPath, fillPaint);

    // 2. Stroke line over the terrain
    final strokePaint = Paint()
      ..color = isHazardBypassed ? const Color(0xFF00E676) : const Color(0xFFFF5252)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    // 3. Highlight steep slope hazard segments in direct route
    if (!isHazardBypassed) {
      final hazardStroke = Paint()
        ..color = const Color(0xFFFF1744)
        ..strokeWidth = 3.6
        ..style = PaintingStyle.stroke;

      final hazardPath = ui.Path();
      bool inHazard = false;

      for (int i = 0; i < samples.length; i++) {
        final s = samples[i];
        final x = (s.distanceKm / totalDistanceKm).clamp(0.0, 1.0) * w;
        final normY = ((s.elevationM - baseElev) / effectiveSpan).clamp(0.0, 1.0);
        final y = h - (normY * h);

        if (s.slopeDeg > 18.0) {
          if (!inHazard) {
            hazardPath.moveTo(x, y);
            inHazard = true;
          } else {
            hazardPath.lineTo(x, y);
          }
        } else {
          inHazard = false;
        }
      }
      canvas.drawPath(hazardPath, hazardStroke);
    }

    // 4. Scrubber cursor if scrubbing
    if (selectedSample != null) {
      final scrubX = (selectedSample!.distanceKm / totalDistanceKm).clamp(0.0, 1.0) * w;
      final scrubNormY = ((selectedSample!.elevationM - baseElev) / effectiveSpan).clamp(0.0, 1.0);
      final scrubY = h - (scrubNormY * h);

      // Vertical guide line
      final cursorLinePaint = Paint()
        ..color = const Color(0xFF00E5FF).withOpacity(0.8)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(scrubX, 0), Offset(scrubX, h), cursorLinePaint);

      // Dot on curve
      final dotPaint = Paint()..color = selectedSample!.slopeColor;
      canvas.drawCircle(Offset(scrubX, scrubY), 4.5, dotPaint);

      final outerDotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(scrubX, scrubY), 4.5, outerDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ElevationProfileChartPainter oldDelegate) {
    return oldDelegate.selectedSample != selectedSample ||
        oldDelegate.isHazardBypassed != isHazardBypassed ||
        oldDelegate.samples != samples;
  }
}
