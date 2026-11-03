import 'package:flutter_test/flutter_test.dart';
import 'package:trailblazer/src/features/map/domain/entities/geo_point.dart';
import 'package:trailblazer/src/features/map/domain/entities/route_point.dart';
import 'package:trailblazer/src/features/map/domain/repositories/location_repository.dart';
import 'package:trailblazer/src/features/map/domain/repositories/route_history_repository.dart';
import 'package:trailblazer/src/features/map/domain/usecases/save_route_point.dart';
import 'package:trailblazer/src/features/map/domain/usecases/watch_location_updates.dart';
import 'package:trailblazer/src/features/map/presentation/bloc/map_bloc.dart';
import 'package:trailblazer/src/features/map/presentation/bloc/map_event.dart';

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

      final stateFuture = bloc.stream.first;
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
}

MapBloc _createMapBloc(RouteHistoryRepository repository) {
  return MapBloc(
    const WatchLocationUpdates(_FakeLocationRepository()),
    SaveRoutePoint(repository),
  );
}

class _FakeLocationRepository implements LocationRepository {
  const _FakeLocationRepository();

  @override
  Stream<GeoPoint> watchLocation() => const Stream.empty();
}

class _FakeRouteHistoryRepository implements RouteHistoryRepository {
  final List<GeoPoint> savedPoints = [];

  @override
  Future<List<RoutePoint>> getPointsForDay({required String localDay}) async {
    return const [];
  }

  @override
  Future<void> savePoint({
    required String localDay,
    required int timezoneOffsetMinutes,
    required GeoPoint point,
  }) async {
    savedPoints.add(point);
  }
}
