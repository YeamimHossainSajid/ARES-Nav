import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../map/mars_tile_sources.dart';
import '../observation/science_models.dart';

enum MarsLensMode {
  observation, // Scientific Observation: Read-only NASA PDS WMTS, InSight seismic, Rover telemetry
  simulation,  // In-Situ Simulation: Flame game engine overlay, base deployment, rover dispatch
}

class LensStateController extends ChangeNotifier {
  // Current Active Lens
  MarsLensMode _currentLens = MarsLensMode.observation;
  MarsLensMode get currentLens => _currentLens;
  bool get isObservationMode => _currentLens == MarsLensMode.observation;
  bool get isSimulationMode => _currentLens == MarsLensMode.simulation;

  // Unified Map Controller for flutter_map
  final MapController mapController = MapController();

  // Active NASA Planetary Tile Source
  MarsTileSource _activeTileSource = MarsTileSource.molaColorElevation;
  MarsTileSource get activeTileSource => _activeTileSource;

  // Scientific Observation Layer Visibility Flags
  bool _showMarsquakes = true;
  bool get showMarsquakes => _showMarsquakes;

  bool _showRoverTrack = true;
  bool get showRoverTrack => _showRoverTrack;

  bool _showCoordinateGrid = true;
  bool get showCoordinateGrid => _showCoordinateGrid;

  // Selected Inspect Item for Bottom Detail Sheet
  MarsquakeEvent? _selectedMarsquake;
  MarsquakeEvent? get selectedMarsquake => _selectedMarsquake;

  RoverScienceTrack? _selectedRover;
  RoverScienceTrack get roverTrack => RoverScienceTrack.perseveranceJezero;
  bool get hasSelectedRover => _selectedRover != null;

  // Jezero Crater Default Center (Mars 2020 landing ellipse)
  static const LatLng jezeroCraterCenter = LatLng(18.3842, 77.5819);

  // Switch between Observation (Science) and Simulation (Game Sandbox)
  void setLens(MarsLensMode mode) {
    if (_currentLens == mode) return;
    _currentLens = mode;
    // Clear selection popups on mode switch
    _selectedMarsquake = null;
    _selectedRover = null;
    notifyListeners();
  }

  void setTileSource(MarsTileSource source) {
    if (_activeTileSource == source) return;
    _activeTileSource = source;
    notifyListeners();
  }

  void toggleMarsquakes() {
    _showMarsquakes = !_showMarsquakes;
    notifyListeners();
  }

  void toggleRoverTrack() {
    _showRoverTrack = !_showRoverTrack;
    notifyListeners();
  }

  void toggleGrid() {
    _showCoordinateGrid = !_showCoordinateGrid;
    notifyListeners();
  }

  void selectMarsquake(MarsquakeEvent? event) {
    _selectedMarsquake = event;
    _selectedRover = null;
    notifyListeners();
  }

  void selectRover(RoverScienceTrack? rover) {
    _selectedRover = rover;
    _selectedMarsquake = null;
    notifyListeners();
  }

  void clearSelection() {
    _selectedMarsquake = null;
    _selectedRover = null;
    notifyListeners();
  }

  void recenterJezero() {
    mapController.move(jezeroCraterCenter, 7.5);
    notifyListeners();
  }

  void recenterGlobal() {
    mapController.move(const LatLng(0, 0), 2.5);
    notifyListeners();
  }
}
