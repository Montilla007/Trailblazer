import '../entities/location_update.dart';
import '../repositories/location_repository.dart';

class WatchLocationUpdates {
  const WatchLocationUpdates(this._repository);

  final LocationRepository _repository;

  Stream<LocationUpdate> call() {
    return _repository.watchLocation();
  }
}
