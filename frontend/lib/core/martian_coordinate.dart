import 'package:latlong2/latlong.dart';

/// Representation of a spatial coordinate on Mars referenced to the
/// IAU-2000 Mars Reference Ellipsoid and MOLA datum.
class MartianCoordinate {
  final double latitude; // -90.0 to +90.0 degrees North/South
  final double longitude; // -180.0 to +180.0 degrees East (or 0 to 360)
  final double elevationMeters; // Relative to MOLA datum (-2,500m to -2,600m in Jezero)

  const MartianCoordinate({
    required this.latitude,
    required this.longitude,
    required this.elevationMeters,
  });

  /// Convert to latlong2 LatLng for flutter_map consumption
  LatLng toLatLng() => LatLng(latitude, longitude);

  static MartianCoordinate fromLatLng(LatLng latLng, {double elevation = -2540.0}) {
    return MartianCoordinate(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
      elevationMeters: elevation,
    );
  }

  String get formattedLat => '${latitude >= 0 ? latitude.toStringAsFixed(4) : (-latitude).toStringAsFixed(4)}° ${latitude >= 0 ? 'N' : 'S'}';
  String get formattedLon => '${longitude >= 0 ? longitude.toStringAsFixed(4) : (-longitude).toStringAsFixed(4)}° ${longitude >= 0 ? 'E' : 'W'}';
  String get formattedElevation => '${elevationMeters >= 0 ? '+' : ''}${elevationMeters.toStringAsFixed(0)} m (MOLA)';

  @override
  String toString() => '$formattedLat, $formattedLon [$formattedElevation]';
}
