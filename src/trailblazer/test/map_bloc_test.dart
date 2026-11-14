import 'package:flutter_test/flutter_test.dart';
import 'package:trailblazer/src/features/map/domain/entities/geo_point.dart';
import 'package:trailblazer/src/features/map/domain/entities/route_day.dart';
import 'package:trailblazer/src/features/map/domain/entities/route_point.dart';
import 'package:trailblazer/src/features/map/domain/repositories/location_repository.dart';
import 'package:trailblazer/src/features/map/domain/repositories/route_history_repository.dart';
import 'package:trailblazer/src/features/map/domain/services/location_movement_filter.dart';
import 'package:trailblazer/src/features/map/domain/usecases/delete_all_saved_routes.dart';
import 'package:trailblazer/src/features/map/domain/usecases/get_all_saved_route_points.dart';
import 'package:trailblazer/src/features/map/domain/usecases/get_route_for_day.dart';
import 'package:trailblazer/src/features/map/domain/usecases/save_route_point.dart';
import 'package:trailblazer/src/features/map/domain/usecases/watch_location_updates.dart';
import 'package:trailblazer/src/features/map/presentation/bloc/map_bloc.dart';
import 'package:trailblazer/src/features/map/presentation/bloc/map_event.dart';
import 'package:trailblazer/src/features/map/presentation/bloc/map_state.dart';

void main() {
  test('zoom request increases the map zoom', () async {
    final bloc = _createMapBloc(_FakeRouteHistoryRepository());
    addTearDown(() async => bloc.close());

    final stateFuture = bloc.stream.first;
    bloc.add(const MapZoomInRequested());

    expect((await stateFuture).zoom, 16);
  });

  test('pitch request switches to 3D', () async {
    final bloc = _createMapBloc(_FakeRouteHistoryRepository());
    addTearDown(() async => bloc.close());

    final stateFuture = bloc.stream.first;
    bloc.add(const MapPitchToggled());

    expect((await stateFuture).pitch, 45);
  });

  test(
    'Geolocator update saves the route point without driving the puck trail',
    () async {
      final repository = _FakeRouteHistoryRepository();
      final bloc = _createMapBloc(repository);
      addTearDown(() async => bloc.close());
      final sampledAt = DateTime.utc(2026, 11, 4);

      final stateFuture = bloc.stream.firstWhere(
        (state) => state.savedTrailPoints.isNotEmpty,
      );
      bloc.add(
        MapLocationReceived(
          latitude: 1,
          longitude: 2,
          timestamp: sampledAt,
          accuracyMeters: 3,
        ),
      );

      final state = await stateFuture;
      expect(state.trailPoints, isEmpty);
      expect(repository.savedPoints, hasLength(1));
      expect(repository.savedPoints.single.timestamp, sampledAt);
    },
  );

  test('temporary puck trail anchors to its nearest saved coordinate', () async {
    final repository = _FakeRouteHistoryRepository()
      ..routePoints.addAll([
        RoutePoint(
          id: 1,
          routeDayId: 1,
          sequence: 1,
          latitude: 47,
          longitude: -122,
          recordedAtUtc: DateTime.utc(2026, 11, 5),
        ),
        RoutePoint(
          id: 2,
          routeDayId: 1,
          sequence: 2,
          latitude: 47.001,
          longitude: -122,
          recordedAtUtc: DateTime.utc(2026, 11, 5, 0, 1),
        ),
      ]);
    final bloc = _createMapBloc(repository);
    addTearDown(() async => bloc.close());

    final trailFuture = bloc.stream.firstWhere(
      (state) => state.trailPoints.length == 2,
    );
    bloc.add(
      MapPuckPositionReceived(
        latitude: 47.00101,
        longitude: -122,
        timestamp: DateTime.utc(2026, 11, 6),
      ),
    );

    final state = await trailFuture;
    expect(state.trailPoints.first.latitude, 47.001);
    expect(state.trailPoints.first.longitude, -122);
    expect(state.trailPoints.last.latitude, 47.00101);
    expect(repository.savedPoints, isEmpty);

    final extensionFuture = bloc.stream.firstWhere(
      (nextState) => nextState.trailPoints.length == 3,
    );
    bloc.add(
      MapPuckPositionReceived(
        latitude: 47.00103,
        longitude: -122,
        timestamp: DateTime.utc(2026, 11, 6, 0, 0, 1),
      ),
    );
    final extendedState = await extensionFuture;

    expect(extendedState.trailPoints.first.latitude, 47.001);
    expect(extendedState.trailPoints.length, 3);
    expect(repository.savedPoints, isEmpty);
  });

  test('puck trail filter rejects movement under its minimum distance', () {
    final filter = LocationMovementFilter(minimumMovementMeters: 1);
    final timestamp = DateTime.utc(2026, 11, 4);

    expect(
      filter.shouldAccept(
        GeoPoint(latitude: 1, longitude: 2, timestamp: timestamp),
      ),
      isTrue,
    );
    expect(
      filter.shouldAccept(
        GeoPoint(
          latitude: 1.000001,
          longitude: 2,
          timestamp: timestamp.add(const Duration(seconds: 1)),
        ),
      ),
      isFalse,
    );
  });

  test('showing the saved trail loads today from the repository', () async {
    final repository = _FakeRouteHistoryRepository()
      ..routePoints.add(
        RoutePoint(
          id: 1,
          routeDayId: 1,
          sequence: 1,
          latitude: 47,
          longitude: -122,
          recordedAtUtc: DateTime.utc(2026, 11, 6),
        ),
      );
    final bloc = _createMapBloc(repository);
    addTearDown(() async => bloc.close());

    final hiddenFuture = bloc.stream.first;
    bloc.add(const MapSavedTrailVisibilityToggled());
    expect((await hiddenFuture).isSavedTrailVisible, isFalse);

    final loadedFuture = bloc.stream.firstWhere(
      (state) => state.savedTrailPoints.isNotEmpty,
    );
    bloc.add(const MapSavedTrailVisibilityToggled());
    final loadedState = await loadedFuture;

    expect(loadedState.isSavedTrailVisible, isTrue);
    expect(loadedState.savedTrailPoints, hasLength(1));
    expect(loadedState.savedTrailPoints.single.latitude, 47);
    expect(loadedState.savedTrailPoints.single.longitude, -122);
  });

  test('unavailable debug accuracy is saved as unavailable', () async {
    final repository = _FakeRouteHistoryRepository();
    final bloc = _createMapBloc(repository);
    addTearDown(() async => bloc.close());

    final modeFuture = bloc.stream.firstWhere(
      (state) => state.debugAccuracyMode == DebugAccuracyMode.unavailable,
    );
    bloc.add(const MapDebugAccuracyModeSelected(DebugAccuracyMode.unavailable));
    await modeFuture;

    final stateFuture = bloc.stream.firstWhere(
      (state) => state.savedTrailPoints.isNotEmpty,
    );
    bloc.add(
      MapLocationReceived(
        latitude: 47,
        longitude: -122,
        timestamp: DateTime.utc(2026, 11, 6),
        accuracyMeters: 3,
      ),
    );
    await stateFuture;

    expect(repository.savedPoints.single.accuracyMeters, isNull);
  });

  test('selected debug accuracy is saved with the route point', () async {
    final repository = _FakeRouteHistoryRepository();
    final bloc = _createMapBloc(repository);
    addTearDown(() async => bloc.close());

    final modeFuture = bloc.stream.firstWhere(
      (state) => state.debugAccuracyMode == DebugAccuracyMode.poor,
    );
    bloc.add(const MapDebugAccuracyModeSelected(DebugAccuracyMode.poor));
    final modeState = await modeFuture;

    final trailFuture = bloc.stream.firstWhere(
      (state) => state.savedTrailPoints.isNotEmpty,
    );
    bloc.add(
      MapLocationReceived(
        latitude: 47,
        longitude: -122,
        timestamp: DateTime.utc(2026, 11, 6),
        accuracyMeters: 3,
      ),
    );
    final trailState = await trailFuture;

    expect(modeState.effectiveAccuracyMeters, inInclusiveRange(20, 50));
    expect(
      repository.savedPoints.single.accuracyMeters,
      modeState.effectiveAccuracyMeters,
    );
    expect(trailState.trailPoints, isEmpty);
  });
}

MapBloc _createMapBloc(RouteHistoryRepository repository) {
  return MapBloc(
    const WatchLocationUpdates(_FakeLocationRepository()),
    SaveRoutePoint(repository),
    GetRoutePointsForDay(repository),
    GetAllSavedRoutePoints(repository),
    DeleteAllSavedRoutes(repository),
  );
}

class _FakeLocationRepository implements LocationRepository {
  const _FakeLocationRepository();

  @override
  Stream<GeoPoint> watchLocation() => const Stream.empty();
}

class _FakeRouteHistoryRepository implements RouteHistoryRepository {
  final List<GeoPoint> savedPoints = [];
  final List<RoutePoint> routePoints = [];

  @override
  Future<List<RouteDay>> getSavedRouteDays() async => const [];

  @override
  Future<List<RoutePoint>> getPointsForDay({required String localDay}) async {
    return routePoints;
  }

  @override
  Future<List<RoutePoint>> getAllPoints() async {
    if (savedPoints.isEmpty) return routePoints;

    return [
      ...routePoints,
      for (var index = 0; index < savedPoints.length; index++)
        RoutePoint(
          id: index + 1,
          routeDayId: 1,
          sequence: index + 1,
          latitude: savedPoints[index].latitude,
          longitude: savedPoints[index].longitude,
          recordedAtUtc: savedPoints[index].timestamp!,
          accuracyMeters: savedPoints[index].accuracyMeters,
        ),
    ];
  }

  @override
  Future<void> savePoint({
    required String localDay,
    required int timezoneOffsetMinutes,
    required GeoPoint point,
  }) async {
    savedPoints.add(point);
  }

  @override
  Future<void> deleteAllRoutes() async {}
}
