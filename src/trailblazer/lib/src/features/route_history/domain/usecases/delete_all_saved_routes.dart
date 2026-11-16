import '../repositories/route_history_repository.dart';

class DeleteAllSavedRoutes {
  const DeleteAllSavedRoutes(this._repository);

  final RouteHistoryRepository _repository;

  Future<void> call() {
    return _repository.deleteAllRoutes();
  }
}
