import 'dart:math' as math;

import 'package:trailblazer/src/features/location_tracking/domain/entities/geo_point.dart';

class LocationMovementFilter {
  LocationMovementFilter({this.minimumMovementMeters = 5});

  final double minimumMovementMeters;
  GeoPoint? _lastAcceptedPoint;

  bool shouldAccept(GeoPoint point) {
    final timestamp = point.timestamp;
    if (timestamp == null ||
        !point.latitude.isFinite ||
        !point.longitude.isFinite ||
        point.latitude < -90 ||
        point.latitude > 90 ||
        point.longitude < -180 ||
        point.longitude > 180) {
      return false;
    }

    final lastPoint = _lastAcceptedPoint;
    if (lastPoint == null) {
      _lastAcceptedPoint = point;
      return true;
    }

    final lastTimestamp = lastPoint.timestamp;
    if (lastTimestamp == null || !timestamp.isAfter(lastTimestamp)) {
      return false;
    }

    if (_distanceMeters(lastPoint, point) < minimumMovementMeters) {
      return false;
    }

    _lastAcceptedPoint = point;
    return true;
  }

  void reset() {
    _lastAcceptedPoint = null;
  }

  double _distanceMeters(GeoPoint a, GeoPoint b) {
    const earthRadiusMeters = 6371000.0;

    final lat1 = _toRadians(a.latitude);
    final lat2 = _toRadians(b.latitude);
    final deltaLat = _toRadians(b.latitude - a.latitude);
    final deltaLon = _toRadians(b.longitude - a.longitude);
    final sinHalfLat = math.sin(deltaLat / 2);
    final sinHalfLon = math.sin(deltaLon / 2);
    final h =
        sinHalfLat * sinHalfLat +
        math.cos(lat1) * math.cos(lat2) * sinHalfLon * sinHalfLon;

    return 2 * earthRadiusMeters * math.asin(math.sqrt(h.clamp(0.0, 1.0)));
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;
}
