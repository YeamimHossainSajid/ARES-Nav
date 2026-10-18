import 'package:flutter/material.dart';
import 'core/lens_state_controller.dart';
import 'map/mars_base_map.dart';
import 'ui/dual_lens_header.dart';
import 'ui/observation_detail_sheet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AresNavApp());
}

/// ============================================================================
/// ARES Nav (Astronaut Real-Time Exploration & Safety System)
/// NASA Space Apps Challenge — "Dual-Lens" Martian Map Application
/// ============================================================================
class AresNavApp extends StatelessWidget {
  const AresNavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARES Nav — Dual-Lens Mars Map',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0F14), // Dark Space Slate
        primaryColor: const Color(0xFFC1440E), // Crater Rust
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFC1440E),
          secondary: Color(0xFF00D8D6), // Telemetry Cyan
          surface: Color(0xFF131822),
          error: Color(0xFFFF3344), // Alert Crimson
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.white,
        ),
        fontFamily: 'monospace',
      ),
      home: const DualLensMainScreen(),
    );
  }
}

class DualLensMainScreen extends StatefulWidget {
  const DualLensMainScreen({super.key});

  @override
  State<DualLensMainScreen> createState() => _DualLensMainScreenState();
}

class _DualLensMainScreenState extends State<DualLensMainScreen> {
  late final LensStateController _lensController;

  @override
  void initState() {
    super.initState();
    _lensController = LensStateController();
  }

  @override
  void dispose() {
    _lensController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lensController,
      builder: (context, _) {
        final isSimulation = _lensController.isSimulationMode;

        return Scaffold(
          body: Stack(
            children: [
              // 1. BASE GEODETIC TILE MAP (NASA Planetary Data System WMTS)
              //    Persists across both modes with zero rebuild overhead
              Positioned.fill(
                child: MarsBaseMap(
                  controller: _lensController,
                ),
              ),

              // 2. SIMULATION MODE HUD BANNER (Active when in Lens 2 Sandbox)
              if (isSimulation)
                Positioned(
                  top: 135,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xDD261506),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFF9100), width: 1.2),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.gamepad, color: Color(0xFFFF9100), size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'SIMULATION LENS ACTIVE // FLAME GAME LOOP READY // TERRAIN VALIDATION ONLINE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF9100),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 3. TOP DUAL-LENS HUD (Mode Switcher, NASA Tile Selector, Toggles)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DualLensHeader(controller: _lensController),
                  ),
                ),
              ),

              // 4. SCIENTIFIC OBSERVATION DETAIL SHEET (Marsquakes / Rover Telemetry)
              if (_lensController.isObservationMode)
                ObservationDetailSheet(controller: _lensController),
            ],
          ),
        );
      },
    );
  }
}
