import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:trailblazer/src/features/location_tracking/domain/entities/geo_point.dart';

class MapboxPuckQueryComparator {
  MapboxPuckQueryComparator(this._map);

  final MapboxMap _map;

  Timer? _timer;
  GeoPoint? _lastCallbackPoint;
  bool _queryInFlight = false;
  int _sampleCount = 0;
  double _totalDistanceMeters = 0;
  double _maximumDistanceMeters = 0;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => unawaited(_comparePosition()),
    );
  }

  void updateCallbackPosition(GeoPoint point) {
    _lastCallbackPoint = point;
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _comparePosition() async {
    if (_queryInFlight) return;

    final callbackPoint = _lastCallbackPoint;
    if (callbackPoint == null) return;

    _queryInFlight = true;
    try {
      final layer = await _map.getLayer('mapbox-location-indicator-layer');
      if (layer is! LocationIndicatorLayer) return;

      final coordinates = layer.location;
      if (coordinates == null || coordinates.length < 2) return;

      final latitude = coordinates[0];
      final longitude = coordinates[1];
      if (latitude == null || longitude == null) return;

      final distanceMeters = _distanceMeters(
        callbackPoint.latitude,
        callbackPoint.longitude,
        latitude,
        longitude,
      );
      _sampleCount++;
      _totalDistanceMeters += distanceMeters;
      _maximumDistanceMeters = math.max(_maximumDistanceMeters, distanceMeters);

      if (_sampleCount % 10 == 0) {
        developer.log(
          'Mapbox puck callback/query separation over $_sampleCount samples: '
          'mean ${(_totalDistanceMeters / _sampleCount).toStringAsFixed(2)} m, '
          'max ${_maximumDistanceMeters.toStringAsFixed(2)} m.',
          name: 'trailblazer.map',
        );
      }
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Could not compare Mapbox puck callback with layer lookup.',
        name: 'trailblazer.map',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _queryInFlight = false;
    }
  }

  double _distanceMeters(
    double latitudeA,
    double longitudeA,
    double latitudeB,
    double longitudeB,
  ) {
    const earthRadiusMeters = 6371000.0;
    final lat1 = _toRadians(latitudeA);
    final lat2 = _toRadians(latitudeB);
    final deltaLat = _toRadians(latitudeB - latitudeA);
    final deltaLon = _toRadians(longitudeB - longitudeA);
    final sinHalfLat = math.sin(deltaLat / 2);
    final sinHalfLon = math.sin(deltaLon / 2);
    final h =
        sinHalfLat * sinHalfLat +
        math.cos(lat1) * math.cos(lat2) * sinHalfLon * sinHalfLon;

    return 2 * earthRadiusMeters * math.asin(math.sqrt(h.clamp(0.0, 1.0)));
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;
}
