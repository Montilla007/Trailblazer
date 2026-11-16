import '../entities/route_point.dart';
import '../repositories/route_history_repository.dart';

class GetRoutePointsForDay {
  const GetRoutePointsForDay(this._repository);

  final RouteHistoryRepository _repository;

  Future<List<RoutePoint>> call({required String localDay}) {
    return _repository.getPointsForDay(localDay: localDay);
  }
}