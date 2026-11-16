import 'package:trailblazer/src/features/location_tracking/domain/entities/geo_point.dart';
import 'package:trailblazer/src/features/route_history/data/datasources/route_local_data_source.dart';
import 'package:trailblazer/src/features/route_history/domain/entities/route_day.dart';
import 'package:trailblazer/src/features/route_history/domain/entities/route_point.dart';
import 'package:trailblazer/src/features/route_history/domain/repositories/route_history_repository.dart';

class RouteHistoryRepositoryImpl implements RouteHistoryRepository {
  RouteHistoryRepositoryImpl(this._localDataSource);

  final RouteLocalDataSource _localDataSource;

  @override
  Future<List<RouteDay>> getSavedRouteDays() {
    return _localDataSource.getSavedRouteDays();
  }

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
