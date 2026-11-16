import '../entities/location_update.dart';

abstract interface class LocationRepository {
  Future<void> startTracking();

  Future<void> stopTracking();

  Stream<LocationUpdate> watchLocation();
}
