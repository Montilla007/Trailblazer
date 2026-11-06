import '../entities/geo_point.dart';
import '../entities/route_point.dart';

abstract interface class RouteHistoryRepository {
  Future<void> savePoint({
    required String localDay,
    required int timezoneOffsetMinutes,
    required GeoPoint point,
  });

  Future<List<RoutePoint>> getPointsForDay({required String localDay});

  Future<List<RoutePoint>> getAllPoints();

  Future<void> deleteAllRoutes();
}
