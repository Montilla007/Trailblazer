import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'route_database.g.dart';

class RouteDays extends Table {
  IntColumn get id => integer().autoIncrement()();

  // One row for each local calendar day, for example "2026-11-02".
  TextColumn get localDay => text().unique()();

  // Example: UTC+8 is 480 minutes.
  IntColumn get timezoneOffsetMinutes => integer()();
}

class RoutePoints extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Each point belongs to one RouteDays row.
  IntColumn get routeDayId =>
      integer().references(RouteDays, #id, onDelete: KeyAction.cascade)();

  // The order of this point within the day's route.
  IntColumn get sequence => integer()();

  // Decimal GPS coordinates.
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();

  // Stored as ISO-8601 text by the build.yaml setting below.
  DateTimeColumn get recordedAtUtc => dateTime()();

  // GPS accuracy might not be available for every sampled point.
  RealColumn get accuracyMeters => real().nullable()();

  // Prevents two points in the same route from having the same sequence.
  @override
  List<Set<Column>> get uniqueKeys => [
        {routeDayId, sequence},
      ];
}

@DriftDatabase(tables: [RouteDays, RoutePoints])
class RouteDatabase extends _$RouteDatabase {
  RouteDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'trailblazer_routes',
      native: DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }

  // SQLite foreign-key checks need to be enabled for the routeDayId
  // relationship and onDelete cascade behavior to be enforced.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}