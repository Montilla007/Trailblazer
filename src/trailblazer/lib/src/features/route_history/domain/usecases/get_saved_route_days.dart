import '../entities/route_day.dart';
import '../repositories/route_history_repository.dart';

class GetSavedRouteDays {
  const GetSavedRouteDays(this._repository);

  final RouteHistoryRepository _repository;

  Future<List<RouteDay>> call() {
    return _repository.getSavedRouteDays();
  }
}
