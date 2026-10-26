import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

/// IAU 2000 Cartographic Reference Ellipsoid Model for Mars.
///
/// Implements high-precision geodetic conversions compliant with the
/// IAU/IAG Working Group on Cartographic Coordinates and Rotational Elements (2000/2018)
/// and NASA NAIF SPICE kernel `pck00010.tpc` planetary constants.
class Iau2000MarsEllipsoid {
  /// Equatorial semi-major axis (meters)
  /// NASA NAIF SPICE / IAU 2000 standard: 3,396,190.0 m
  static const double a = 3396190.0;

  /// Polar semi-minor axis (meters)
  /// NASA NAIF SPICE / IAU 2000 standard: 3,376,200.0 m
  static const double c = 3376200.0;

  /// Mean volumetric radius (meters)
  static const double rMean = 3389500.0;

  /// Flattening: f = (a - c) / a
  static const double f = (a - c) / a; // ~0.005886007555525456

  /// First eccentricity squared: e^2 = 2f - f^2 = (a^2 - c^2) / a^2
  static const double e2 = (a * a - c * c) / (a * a); // ~0.011718049005938923

  /// Second eccentricity squared: e'^2 = (a^2 - c^2) / c^2
  static const double ePrime2 = (a * a - c * c) / (c * c); // ~0.011856950294157077

  // --------------------------------------------------------------------------
  // LATITUDE TRANSFORMATIONS: Planetocentric <-> Planetographic
  // --------------------------------------------------------------------------

  /// Converts Planetographic Latitude (degrees) to Planetocentric Latitude (degrees).
  ///
  /// Mathematical formulation:
  ///   tan(phi_c) = (1 - f)^2 * tan(phi_g) = (c^2 / a^2) * tan(phi_g)
  static double planetographicToPlanetocentric(double planetographicLatDeg) {
    if (planetographicLatDeg.abs() >= 90.0) {
      return planetographicLatDeg.sign * 90.0;
    }
    final phiG = planetographicLatDeg * (math.pi / 180.0);
    final phiC = math.atan((1.0 - e2) * math.tan(phiG));
    return phiC * (180.0 / math.pi);
  }

  /// Converts Planetocentric Latitude (degrees) to Planetographic Latitude (degrees).
  ///
  /// Mathematical formulation:
  ///   tan(phi_g) = 1 / (1 - e^2) * tan(phi_c) = (a^2 / c^2) * tan(phi_c)
  static double planetocentricToPlanetographic(double planetocentricLatDeg) {
    if (planetocentricLatDeg.abs() >= 90.0) {
      return planetocentricLatDeg.sign * 90.0;
    }
    final phiC = planetocentricLatDeg * (math.pi / 180.0);
    final phiG = math.atan(math.tan(phiC) / (1.0 - e2));
    return phiG * (180.0 / math.pi);
  }

  // --------------------------------------------------------------------------
  // RADII OF CURVATURE
  // --------------------------------------------------------------------------

  /// Prime vertical radius of curvature N(phi) in meters at planetographic latitude phi.
  ///
  ///   N(phi) = a / sqrt(1 - e^2 * sin^2(phi))
  static double primeVerticalRadius(double planetographicLatDeg) {
    final phi = planetographicLatDeg * (math.pi / 180.0);
    final sinPhi = math.sin(phi);
    return a / math.sqrt(1.0 - e2 * sinPhi * sinPhi);
  }

  /// Meridional radius of curvature M(phi) in meters at planetographic latitude phi.
  ///
  ///   M(phi) = a * (1 - e^2) / (1 - e^2 * sin^2(phi))^(3/2)
  static double meridionalRadius(double planetographicLatDeg) {
    final phi = planetographicLatDeg * (math.pi / 180.0);
    final sinPhi = math.sin(phi);
    final denom = 1.0 - e2 * sinPhi * sinPhi;
    return a * (1.0 - e2) / (denom * math.sqrt(denom));
  }

  /// Local surface radius R(phi) from planet center to surface at planetographic latitude phi.
  static double surfaceRadiusAtLatitude(double planetographicLatDeg) {
    final phi = planetographicLatDeg * (math.pi / 180.0);
    final cosPhi = math.cos(phi);
    final sinPhi = math.sin(phi);
    const a2 = a * a;
    const c2 = c * c;
    final num = (a2 * a2 * cosPhi * cosPhi) + (c2 * c2 * sinPhi * sinPhi);
    final den = (a2 * cosPhi * cosPhi) + (c2 * sinPhi * sinPhi);
    return math.sqrt(num / den);
  }

  // --------------------------------------------------------------------------
  // GEODETIC <-> CARTESIAN (XYZ)
  // --------------------------------------------------------------------------

  /// Converts Planetographic (lat, lon, height) to Body-Fixed Cartesian XYZ (meters).
  static MarsVector3 geodeticToCartesian({
    required double planetographicLatDeg,
    required double longitudeDeg,
    double heightMeters = 0.0,
  }) {
    final phi = planetographicLatDeg * (math.pi / 180.0);
    final lambda = longitudeDeg * (math.pi / 180.0);

    final n = primeVerticalRadius(planetographicLatDeg);
    final x = (n + heightMeters) * math.cos(phi) * math.cos(lambda);
    final y = (n + heightMeters) * math.cos(phi) * math.sin(lambda);
    final z = (n * (1.0 - e2) + heightMeters) * math.sin(phi);

    return MarsVector3(x, y, z);
  }

  /// Converts Body-Fixed Cartesian XYZ (meters) to Planetographic (lat, lon, height).
  /// Implements Bowring's closed-form algorithm adapted for Mars ellipsoid.
  static MarsGeodeticCoordinate cartesianToGeodetic(MarsVector3 xyz) {
    final p = math.sqrt(xyz.x * xyz.x + xyz.y * xyz.y);
    final theta = math.atan2(xyz.z * a, p * c);

    final sinTheta = math.sin(theta);
    final cosTheta = math.cos(theta);

    final phi = math.atan2(
      xyz.z + ePrime2 * c * sinTheta * sinTheta * sinTheta,
      p - e2 * a * cosTheta * cosTheta * cosTheta,
    );

    final lambda = math.atan2(xyz.y, xyz.x);

    final sinPhi = math.sin(phi);
    final n = a / math.sqrt(1.0 - e2 * sinPhi * sinPhi);
    final h = (p / math.cos(phi)) - n;

    return MarsGeodeticCoordinate(
      planetographicLatDeg: phi * (180.0 / math.pi),
      longitudeDeg: lambda * (180.0 / math.pi),
      heightMeters: h,
    );
  }

  // --------------------------------------------------------------------------
  // GEODESIC DISTANCE: Vincenty's Inverse Method on Mars Ellipsoid
  // --------------------------------------------------------------------------

  /// Computes the great-ellipsoidal distance in meters between two planetographic coordinates.
  /// Accurate to < 0.01 meters over thousands of kilometers on Mars.
  static double geodesicDistance(LatLng point1, LatLng point2) {
    final phi1 = point1.latitude * (math.pi / 180.0);
    final lambda1 = point1.longitude * (math.pi / 180.0);
    final phi2 = point2.latitude * (math.pi / 180.0);
    final lambda2 = point2.longitude * (math.pi / 180.0);

    final l = lambda2 - lambda1;
    const b = c; // semi-minor

    final u1 = math.atan((1.0 - f) * math.tan(phi1));
    final u2 = math.atan((1.0 - f) * math.tan(phi2));
    final sinU1 = math.sin(u1);
    final cosU1 = math.cos(u1);
    final sinU2 = math.sin(u2);
    final cosU2 = math.cos(u2);

    double lambda = l;
    double lambdaP = 2 * math.pi;
    int iterLimit = 100;

    double sinSigma = 0;
    double cosSigma = 0;
    double sigma = 0;
    double sinAlpha = 0;
    double cosSqAlpha = 0;
    double cos2SigmaM = 0;

    while ((lambda - lambdaP).abs() > 1e-12 && --iterLimit > 0) {
      final sinLambda = math.sin(lambda);
      final cosLambda = math.cos(lambda);

      sinSigma = math.sqrt(
        (cosU2 * sinLambda) * (cosU2 * sinLambda) +
        (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda) * (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda),
      );

      if (sinSigma == 0) return 0.0; // Co-incident points

      cosSigma = sinU1 * sinU2 + cosU1 * cosU2 * cosLambda;
      sigma = math.atan2(sinSigma, cosSigma);
      sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma;
      cosSqAlpha = 1.0 - sinAlpha * sinAlpha;

      cos2SigmaM = cosSqAlpha != 0 ? cosSigma - 2 * sinU1 * sinU2 / cosSqAlpha : 0.0;

      final cVal = f / 16 * cosSqAlpha * (4 + f * (4 - 3 * cosSqAlpha));
      lambdaP = lambda;
      lambda = l + (1 - cVal) * f * sinAlpha * (
        sigma + cVal * sinSigma * (cos2SigmaM + cVal * cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM))
      );
    }

    if (iterLimit == 0) {
      // Fallback to spherical law of cosines if Vincenty fails to converge on antipodal points
      return rMean * (math.acos(
        math.sin(phi1) * math.sin(phi2) + math.cos(phi1) * math.cos(phi2) * math.cos(l)
      ));
    }

    final uSq = cosSqAlpha * (a * a - b * b) / (b * b);
    final capA = 1 + uSq / 16384 * (4096 + uSq * (-768 + uSq * (320 - 175 * uSq)));
    final capB = uSq / 1024 * (256 + uSq * (-128 + uSq * (74 - 47 * uSq)));
    final deltaSigma = capB * sinSigma * (
      cos2SigmaM + capB / 4 * (
        cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM) -
        capB / 6 * cos2SigmaM * (-3 + 4 * sinSigma * sinSigma) * (-3 + 4 * cos2SigmaM * cos2SigmaM)
      )
    );

    return b * capA * (sigma - deltaSigma);
  }
}

class MarsVector3 {
  final double x;
  final double y;
  final double z;

  const MarsVector3(this.x, this.y, this.z);

  double get length => math.sqrt(x * x + y * y + z * z);

  @override
  String toString() => 'MarsVector3(x: ${x.toStringAsFixed(1)}, y: ${y.toStringAsFixed(1)}, z: ${z.toStringAsFixed(1)})';
}

class MarsGeodeticCoordinate {
  final double planetographicLatDeg;
  final double longitudeDeg;
  final double heightMeters;

  const MarsGeodeticCoordinate({
    required this.planetographicLatDeg,
    required this.longitudeDeg,
    required this.heightMeters,
  });

  @override
  String toString() => 'MarsGeodetic(${planetographicLatDeg.toStringAsFixed(4)}°, ${longitudeDeg.toStringAsFixed(4)}°, ${heightMeters.toStringAsFixed(1)}m)';
}
