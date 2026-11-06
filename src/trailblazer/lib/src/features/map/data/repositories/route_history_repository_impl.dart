import 'package:trailblazer/src/features/map/data/datasources/route_local_data_source.dart';
import 'package:trailblazer/src/features/map/domain/entities/route_point.dart';
import 'package:trailblazer/src/features/map/domain/repositories/route_history_repository.dart';
import 'package:trailblazer/src/features/map/domain/entities/geo_point.dart';

class RouteHistoryRepositoryImpl implements RouteHistoryRepository {
  RouteHistoryRepositoryImpl(this._localDataSource);

  final RouteLocalDataSource _localDataSource;

  @override
  Future<void> savePoint({
    required String localDay,
    required int timezoneOffsetMinutes,
    required GeoPoint point,
  }) {
    return _localDataSource.savePoint(
      localDay: localDay,
      timezoneOffsetMinutes: timezoneOffsetMinutes,
      point: point,
    );
  }

  @override
  Future<List<RoutePoint>> getPointsForDay({required String localDay}) {
    return _localDataSource.getPointsForDay(localDay: localDay);
  }

  @override
  Future<List<RoutePoint>> getAllPoints() {
    return _localDataSource.getAllPoints();
  }

  @override
  Future<void> deleteAllRoutes() {
    return _localDataSource.deleteAllRoutes();
  }
}
