import 'package:drift/drift.dart';
import 'package:trailblazer/src/features/map/data/datasources/route_database.dart';
import 'package:trailblazer/src/features/map/domain/entities/geo_point.dart';
import 'package:trailblazer/src/features/map/domain/entities/route_point.dart'
    as domain;

class RouteLocalDataSource {
  RouteLocalDataSource(this._database);

  final RouteDatabase _database;

  Future<void> savePoint({
    required String localDay,
    required int timezoneOffsetMinutes,
    required GeoPoint point,
  }) {
    return _database.transaction(() async {
      // Find this day's route, or create it.
      var routeDay = await (_database.select(
        _database.routeDays,
      )..where((day) => day.localDay.equals(localDay))).getSingleOrNull();

      if (routeDay == null) {
        final routeDayId = await _database
            .into(_database.routeDays)
            .insert(
              RouteDaysCompanion.insert(
                localDay: localDay,
                timezoneOffsetMinutes: timezoneOffsetMinutes,
              ),
            );

        routeDay = await (_database.select(
          _database.routeDays,
        )..where((day) => day.id.equals(routeDayId))).getSingle();
      }

      // Sequence numbers preserve the order of points within this day.
      final lastPoint =
          await (_database.select(_database.routePoints)
                ..where((row) => row.routeDayId.equals(routeDay!.id))
                ..orderBy([(row) => OrderingTerm.desc(row.sequence)])
                ..limit(1))
              .getSingleOrNull();

      final nextSequence = (lastPoint?.sequence ?? 0) + 1;

      await _database
          .into(_database.routePoints)
          .insert(
            RoutePointsCompanion.insert(
              routeDayId: routeDay.id,
              sequence: nextSequence,
              latitude: point.latitude,
              longitude: point.longitude,
              recordedAtUtc: (point.timestamp ?? DateTime.now()).toUtc(),
              accuracyMeters: Value(point.accuracyMeters),
            ),
          );
    });
  }

  Future<List<domain.RoutePoint>> getPointsForDay({
    required String localDay,
  }) async {
    final routeDay = await (_database.select(
      _database.routeDays,
    )..where((day) => day.localDay.equals(localDay))).getSingleOrNull();

    if (routeDay == null) return const [];

    final rows =
        await (_database.select(_database.routePoints)
              ..where((point) => point.routeDayId.equals(routeDay.id))
              ..orderBy([(point) => OrderingTerm.asc(point.sequence)]))
            .get();

    return rows
        .map(
          (row) => domain.RoutePoint(
            id: row.id,
            routeDayId: row.routeDayId,
            sequence: row.sequence,
            latitude: row.latitude,
            longitude: row.longitude,
            recordedAtUtc: row.recordedAtUtc,
            accuracyMeters: row.accuracyMeters,
          ),
        )
        .toList(growable: false);
  }
}
