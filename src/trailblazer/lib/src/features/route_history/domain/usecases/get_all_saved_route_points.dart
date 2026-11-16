import '../entities/route_point.dart';
import '../repositories/route_history_repository.dart';

class GetAllSavedRoutePoints {
  const GetAllSavedRoutePoints(this._repository);

  final RouteHistoryRepository _repository;

  Future<List<RoutePoint>> call() {
    return _repository.getAllPoints();
  }
}
