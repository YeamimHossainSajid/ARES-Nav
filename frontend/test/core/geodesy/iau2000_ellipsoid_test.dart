import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:ares_nav_frontend/core/geodesy/iau2000_ellipsoid.dart';

void main() {
  group('Issue #001: IAU 2000 Mars Ellipsoid Geodetic Engine Tests', () {
    test('Ellipsoid physical constants conform to NASA SPICE pck00010.tpc', () {
      expect(Iau2000MarsEllipsoid.a, equals(3396190.0));
      expect(Iau2000MarsEllipsoid.c, equals(3376200.0));
      expect(Iau2000MarsEllipsoid.f, closeTo(0.005886007, 1e-6));
      expect(Iau2000MarsEllipsoid.e2, closeTo(0.01173737, 1e-6));
    });

    test('Planetocentric <-> Planetographic latitude bijection roundtrips precisely', () {
      final testLatitudes = [-85.0, -45.0, -18.38, 0.0, 18.38, 45.0, 85.0];

      for (final latG in testLatitudes) {
        final latC = Iau2000MarsEllipsoid.planetographicToPlanetocentric(latG);
        final restoredLatG = Iau2000MarsEllipsoid.planetocentricToPlanetographic(latC);

        expect(restoredLatG, closeTo(latG, 1e-10),
            reason: 'Failed roundtrip for planetographic latitude $latG');
      }
    });

    test('Planetographic is slightly greater in magnitude than planetocentric away from equator/poles', () {
      // At 45 degrees, the normal to the ellipsoid points further toward the pole
      const latG = 45.0;
      final latC = Iau2000MarsEllipsoid.planetographicToPlanetocentric(latG);
      expect(latC, lessThan(latG));
      expect(latG - latC, closeTo(0.337, 0.05)); // ~0.337 degree deviation on Mars
    });

    test('Cartesian XYZ <-> Geodetic roundtrips with sub-meter tolerance (< 0.05m)', () {
      // Test at Jezero Crater (18.3842° N, 77.5819° E, elevation -2540m)
      const lat = 18.3842;
      const lon = 77.5819;
      const h = -2540.0;

      final cartesian = Iau2000MarsEllipsoid.geodeticToCartesian(
        planetographicLatDeg: lat,
        longitudeDeg: lon,
        heightMeters: h,
      );

      final recovered = Iau2000MarsEllipsoid.cartesianToGeodetic(cartesian);

      expect(recovered.planetographicLatDeg, closeTo(lat, 1e-7));
      expect(recovered.longitudeDeg, closeTo(lon, 1e-7));
      expect(recovered.heightMeters, closeTo(h, 0.01),
          reason: 'Height must match within 0.01 meters (< 0.05m acceptance threshold)');
    });

    test('Vincenty inverse geodesic distance on Mars ellipsoid calculates accurate distance', () {
      // Jezero Crater (18.3842° N, 77.5819° E) to Chryse Planitia (22.42° N, -18.85° E -> 341.15° E)
      const jezero = LatLng(18.3842, 77.5819);
      const chryse = LatLng(22.4200, -18.8500);

      final distanceMeters = Iau2000MarsEllipsoid.geodesicDistance(jezero, chryse);

      // Total distance across planetary arc is approximately 5,600 - 5,800 km
      expect(distanceMeters, greaterThan(5000000.0));
      expect(distanceMeters, lessThan(6000000.0));

      // Local 1-degree equatorial distance should be ~59.27 km (2*pi*a / 360)
      const ptA = LatLng(0.0, 0.0);
      const ptB = LatLng(0.0, 1.0);
      final oneDegreeEquator = Iau2000MarsEllipsoid.geodesicDistance(ptA, ptB);
      expect(oneDegreeEquator, closeTo(59275.0, 10.0));
    });
  });
}
