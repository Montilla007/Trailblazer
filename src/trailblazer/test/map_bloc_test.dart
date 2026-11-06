import 'package:flutter_test/flutter_test.dart';
import 'package:trailblazer/src/features/map/domain/entities/geo_point.dart';
import 'package:trailblazer/src/features/map/domain/entities/route_point.dart';
import 'package:trailblazer/src/features/map/domain/repositories/location_repository.dart';
import 'package:trailblazer/src/features/map/domain/repositories/route_history_repository.dart';
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
    'puck sample updates the live trail and saves the route point',
    () async {
      final repository = _FakeRouteHistoryRepository();
      final bloc = _createMapBloc(repository);
      addTearDown(() async => bloc.close());
      final sampledAt = DateTime.utc(2026, 11, 4);

      final stateFuture = bloc.stream.firstWhere(
        (state) => state.trailPoints.isNotEmpty,
      );
      bloc.add(
        MapPuckPositionSampled(
          latitude: 1,
          longitude: 2,
          sampledAt: sampledAt,
          accuracyMeters: 3,
        ),
      );

      final state = await stateFuture;
      expect(state.trailPoints, hasLength(1));
      expect(state.trailPoints.single.latitude, 1);
      expect(state.trailPoints.single.longitude, 2);
      expect(repository.savedPoints, hasLength(1));
      expect(repository.savedPoints.single.timestamp, sampledAt);
    },
  );

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
      (state) => state.trailPoints.isNotEmpty,
    );
    bloc.add(
      MapPuckPositionSampled(
        latitude: 47,
        longitude: -122,
        sampledAt: DateTime.utc(2026, 11, 6),
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
      (state) => state.trailPoints.isNotEmpty,
    );
    bloc.add(
      MapPuckPositionSampled(
        latitude: 47,
        longitude: -122,
        sampledAt: DateTime.utc(2026, 11, 6),
        accuracyMeters: 3,
      ),
    );
    final trailState = await trailFuture;

    expect(modeState.effectiveAccuracyMeters, inInclusiveRange(20, 50));
    expect(
      repository.savedPoints.single.accuracyMeters,
      modeState.effectiveAccuracyMeters,
    );
    expect(
      trailState.trailPoints.single.accuracyMeters,
      modeState.effectiveAccuracyMeters,
    );
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
  Future<List<RoutePoint>> getPointsForDay({required String localDay}) async {
    return routePoints;
  }

  @override
  Future<List<RoutePoint>> getAllPoints() async {
    return routePoints;
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
