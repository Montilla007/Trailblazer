import '../repositories/location_repository.dart';

class StopLocationTracking {
  const StopLocationTracking(this._repository);

  final LocationRepository _repository;

  Future<void> call() => _repository.stopTracking();
}
