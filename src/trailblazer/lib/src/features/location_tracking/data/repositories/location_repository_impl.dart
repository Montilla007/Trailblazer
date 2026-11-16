import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/geo_point.dart';
import '../../domain/entities/location_update.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/device_location_data_source.dart';
import '../datasources/foreground_recording_data_source.dart';

class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl(
    this._dataSource,
    this._foregroundRecordingDataSource,
  );

  final DeviceLocationDataSource _dataSource;
  final ForegroundRecordingDataSource _foregroundRecordingDataSource;

  @override
  Future<void> startTracking() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _foregroundRecordingDataSource.start();
    }
  }

  @override
  Future<void> stopTracking() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _foregroundRecordingDataSource.stop();
    }
  }

  @override
  Stream<LocationUpdate> watchLocation() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _foregroundRecordingDataSource.updates;
    }

    return _dataSource.getPositionStream().map(
      (position) => LocationUpdate(point: _toGeoPoint(position)),
    );
  }

  GeoPoint _toGeoPoint(Position position) {
    return GeoPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
      speedMetersPerSecond: position.speed,
      timestamp: position.timestamp,
    );
  }
}
