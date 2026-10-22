import '../entities/geo_point.dart';
import '../repositories/location_repository.dart';

class WatchLocationUpdates {
  const WatchLocationUpdates(this._repository);

  final LocationRepository _repository;

  Stream<GeoPoint> call() {
    return _repository.watchLocation();
  }
}