import 'dart:math' as math;

import '../entities/geo_point.dart';

class RoutePointSamplingFilter {
  RoutePointSamplingFilter({
    this.minimumDistanceMeters = 5,
    this.maximumInterval = const Duration(seconds: 5),
    this.minimumMovementMeters = 2,
    this.headingSegmentMeters = 3,
    this.minimumTurnDegrees = 30,
  });

  final double minimumDistanceMeters;
  final Duration maximumInterval;
  final double minimumMovementMeters;
  final double headingSegmentMeters;
  final double minimumTurnDegrees;

  GeoPoint? _lastSavedPoint;
  GeoPoint? _headingAnchor;
  double? _previousBearingDegrees;

  bool shouldSave(GeoPoint point) {
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

    final lastSaved = _lastSavedPoint;

    // Keep the route's first point.
    if (lastSaved == null) {
      _markSaved(point);
      return true;
    }

    final lastSavedTime = lastSaved.timestamp;
    if (lastSavedTime == null || !timestamp.isAfter(lastSavedTime)) {
      return false;
    }

    final distanceFromLastSaved = _distanceMeters(lastSaved, point);
    final turned = _hasTurned(point);

    // Require some movement, even when the timer or turn condition fires,
    // to avoid saving stationary GPS drift.
    if (distanceFromLastSaved < minimumMovementMeters) {
      return false;
    }

    final timePassed = timestamp.difference(lastSavedTime);

    final shouldSave =
        distanceFromLastSaved >= minimumDistanceMeters ||
        timePassed >= maximumInterval ||
        turned;

    if (shouldSave) {
      _markSaved(point);
    }

    return shouldSave;
  }

  void reset() {
    _lastSavedPoint = null;
    _headingAnchor = null;
    _previousBearingDegrees = null;
  }

  void _markSaved(GeoPoint point) {
    _lastSavedPoint = point;
    _headingAnchor ??= point;
  }

  bool _hasTurned(GeoPoint point) {
    final anchor = _headingAnchor;

    if (anchor == null ||
        _distanceMeters(anchor, point) < headingSegmentMeters) {
      return false;
    }

    final heading = _bearingDegrees(anchor, point);
    final previousBearing = _previousBearingDegrees;

    _headingAnchor = point;
    _previousBearingDegrees = heading;

    if (previousBearing == null) {
      return false;
    }

    return _angleDifferenceDegrees(previousBearing, heading) >=
        minimumTurnDegrees;
  }

  double _distanceMeters(GeoPoint a, GeoPoint b) {
    const earthRadiusMeters = 6371000.0;

    final lat1 = _toRadians(a.latitude);
    final lat2 = _toRadians(b.latitude);
    final deltaLat = _toRadians(b.latitude - a.latitude);
    final deltaLon = _toRadians(b.longitude - a.longitude);

    final h =
        math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(deltaLon / 2) *
            math.sin(deltaLon / 2);

    return 2 * earthRadiusMeters * math.asin(math.sqrt(h));
  }

  double _bearingDegrees(GeoPoint from, GeoPoint to) {
    final lat1 = _toRadians(from.latitude);
    final lat2 = _toRadians(to.latitude);
    final deltaLon = _toRadians(to.longitude - from.longitude);

    final y = math.sin(deltaLon) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(deltaLon);

    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  double _angleDifferenceDegrees(double a, double b) {
    final difference = (a - b).abs() % 360;
    return difference > 180 ? 360 - difference : difference;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;
}
