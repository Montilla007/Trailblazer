import '../repositories/location_repository.dart';

class StartLocationTracking {
  const StartLocationTracking(this._repository);

  final LocationRepository _repository;

  Future<void> call() => _repository.startTracking();
}
