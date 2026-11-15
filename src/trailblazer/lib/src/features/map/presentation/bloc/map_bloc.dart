import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trailblazer/src/features/map/domain/services/location_movement_filter.dart';
import 'package:trailblazer/src/features/map/domain/services/route_point_sampling_filter.dart';
import 'package:trailblazer/src/features/map/domain/entities/route_point.dart';
import 'package:trailblazer/src/features/map/domain/usecases/delete_all_saved_routes.dart';
import 'package:trailblazer/src/features/map/domain/usecases/get_all_saved_route_points.dart';
import 'package:trailblazer/src/features/map/domain/usecases/get_route_for_day.dart';
import 'package:trailblazer/src/features/map/domain/usecases/save_route_point.dart';

import '../../domain/entities/geo_point.dart';
import '../../domain/usecases/watch_location_updates.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc(
    this._watchLocationUpdates,
    this._saveRoutePoint,
    this._getRoutePointsForDay,
    this._getAllSavedRoutePoints,
    this._deleteAllSavedRoutes, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       super(const MapState()) {
    final localNow = _clock().toLocal();
    final today = DateTime(localNow.year, localNow.month, localNow.day);
    _recentSavedTrailToday = _formatLocalDay(today);
    _recentSavedTrailYesterday = _formatLocalDay(
      DateTime(today.year, today.month, today.day - 1),
    );

    on<MapTrackingRequested>((event, emit) async {
      await _locationSubscription?.cancel();

      // MapTrackingRequested
      emit(
        state.copyWith(
          status: MapStatus.tracking,
          clearAccuracyMeters: true,
          clearErrorMessage: true,
        ),
      );

      _locationSubscription = _watchLocationUpdates().listen(
        (point) {
          add(
            MapLocationReceived(
              latitude: point.latitude,
              longitude: point.longitude,
              timestamp: point.timestamp ?? DateTime.now().toUtc(),
              accuracyMeters: point.accuracyMeters,
            ),
          );
        },
        onError: (Object error) {
          add(MapTrackingFailed(error.toString()));
        },
      );
    });

    on<MapLocationReceived>(_onLocationReceived);
    on<MapPuckPositionReceived>(
      _onPuckPositionReceived,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
    on<MapPuckLocationFailed>((event, emit) {
      emit(
        state.copyWith(
          debugMessage: 'Mapbox puck location unavailable: ${event.message}',
          debugMessageIsError: true,
        ),
      );
    });
    on<MapTrackingStopped>((event, emit) async {
      await _locationSubscription?.cancel();
      _locationSubscription = null;
      emit(const MapState(status: MapStatus.stopped));
    });

    on<MapTrackingFailed>((event, emit) async {
      await _locationSubscription?.cancel();
      _locationSubscription = null;
      emit(MapState(status: MapStatus.error, errorMessage: event.message));
    });

    on<MapViewportFollowRequested>((event, emit) {
      emit(state.copyWith(viewportMode: MapViewportMode.followingPuck));
    });

    on<MapViewportFollowPaused>((event, emit) {
      emit(state.copyWith(viewportMode: MapViewportMode.idle));
    });

    on<MapZoomInRequested>((event, emit) {
      emit(state.copyWith(zoom: (state.zoom + 1).clamp(3.0, 20.0).toDouble()));
    });

    on<MapZoomOutRequested>((event, emit) {
      emit(state.copyWith(zoom: (state.zoom - 1).clamp(3.0, 20.0).toDouble()));
    });

    on<MapPitchToggled>((event, emit) {
      emit(state.copyWith(pitch: state.pitch == 0 ? 45 : 0));
    });
    on<MapDebugAccuracyModeSelected>(_onDebugAccuracyModeSelected);
    on<MapLiveTrailVisibilityToggled>((event, emit) {
      emit(state.copyWith(isLiveTrailVisible: !state.isLiveTrailVisible));
    });
    on<MapSavedTrailVisibilityToggled>(_onSavedTrailVisibilityToggled);
    on<MapSavedTrailLoadRequested>(_onSavedTrailLoadRequested);
    on<MapAllSavedTrailLoadRequested>(_onAllSavedTrailLoadRequested);
    on<MapRecentSavedTrailLoadRequested>(_onRecentSavedTrailLoadRequested);
    on<MapAllSavedRoutesDeleteRequested>(_onAllSavedRoutesDeleteRequested);
  }

  final WatchLocationUpdates _watchLocationUpdates;
  final GetRoutePointsForDay _getRoutePointsForDay;
  final GetAllSavedRoutePoints _getAllSavedRoutePoints;
  final DeleteAllSavedRoutes _deleteAllSavedRoutes;
  final DateTime Function() _clock;
  StreamSubscription<GeoPoint>? _locationSubscription;
  final List<GeoPoint> _trailPoints = [];
  final LocationMovementFilter _puckTrailFilter = LocationMovementFilter(
    minimumMovementMeters: 1,
  );
  Future<List<GeoPoint>>? _allSavedTrailPointsLoad;
  Future<Map<String, List<GeoPoint>>>? _recentSavedTrailPointsLoad;
  late final String _recentSavedTrailToday;
  late final String _recentSavedTrailYesterday;
  bool _puckTrailStarted = false;

  final SaveRoutePoint _saveRoutePoint;
  final RoutePointSamplingFilter _samplingFilter = RoutePointSamplingFilter();
  final Random _random = Random();

  Future<void> _onLocationReceived(
    MapLocationReceived event,
    Emitter<MapState> emit,
  ) async {
    final accuracyMeters = state.debugAccuracyMode == null
        ? event.accuracyMeters
        : state.effectiveAccuracyMeters;

    emit(
      state.copyWith(
        status: MapStatus.tracking,
        latitude: event.latitude,
        longitude: event.longitude,
        accuracyMeters: accuracyMeters,
        clearAccuracyMeters: accuracyMeters == null,
        clearErrorMessage: true,
      ),
    );

    final point = GeoPoint(
      latitude: event.latitude,
      longitude: event.longitude,
      accuracyMeters: accuracyMeters,
      timestamp: event.timestamp,
    );

    final saveReasons = _samplingFilter.saveReasonsFor(point);
    if (saveReasons == null) return;

    await _saveRoutePoint(point);
    if (!kDebugMode) return;

    final reasonDescription = saveReasons
        .map(_describeRoutePointSaveReason)
        .join(', ');
    final movementGate = saveReasons.contains(RoutePointSaveReason.firstPoint)
        ? ''
        : '; movement gate >= ${_samplingFilter.minimumMovementMeters} m passed';
    developer.log(
      '[Saved Cord] Saved route point to SQLite '
      '(trigger(s): $reasonDescription$movementGate).',
      name: 'trailblazer.map',
    );

    final localDay = _formatLocalDay(point.timestamp!.toLocal());
    if (!state.isSavedTrailVisible) return;

    try {
      emit(
        state.copyWith(
          savedTrailPoints: state.savedTrailLocalDay == null
              ? await _getAllSavedTrailPoints()
              : state.savedTrailLocalDay == localDay
              ? await _getSavedTrailPoints(localDay)
              : state.savedTrailPoints,
        ),
      );
    } on Exception catch (error, stackTrace) {
      developer.log(
        '[Saved Trail] Could not refresh the SQLite trail.',
        name: 'trailblazer.map',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          debugMessage: 'Could not refresh the saved trail: $error',
          debugMessageIsError: true,
        ),
      );
    }
  }

  String _describeRoutePointSaveReason(RoutePointSaveReason reason) {
    return switch (reason) {
      RoutePointSaveReason.firstPoint => 'first valid point',
      RoutePointSaveReason.minimumDistance =>
        'distance >= ${_samplingFilter.minimumDistanceMeters} m',
      RoutePointSaveReason.maximumInterval =>
        'elapsed time >= ${_samplingFilter.maximumInterval.inMilliseconds} ms',
      RoutePointSaveReason.turn =>
        'turn >= ${_samplingFilter.minimumTurnDegrees} degrees '
            'after a ${_samplingFilter.headingSegmentMeters} m heading segment',
    };
  }

  Future<void> _onPuckPositionReceived(
    MapPuckPositionReceived event,
    Emitter<MapState> emit,
  ) async {
    final point = GeoPoint(
      latitude: event.latitude,
      longitude: event.longitude,
      timestamp: event.timestamp,
    );

    if (!_puckTrailFilter.shouldAccept(point)) return;

    if (!_puckTrailStarted) {
      var savedTrailsByDay = state.liveSavedTrailPointsByDay;
      try {
        savedTrailsByDay = await _loadRecentSavedTrailPointsByDay();
        emit(state.copyWith(liveSavedTrailPointsByDay: savedTrailsByDay));
        if (state.savedTrailLocalDay == null && !kDebugMode) {
          emit(
            state.copyWith(
              savedTrailPoints: _flattenSavedTrailPoints(savedTrailsByDay),
              isSavedTrailVisible: true,
            ),
          );
        }
      } on Exception catch (error, stackTrace) {
        developer.log(
          'Could not load saved points to anchor the temporary puck trail.',
          name: 'trailblazer.map',
          error: error,
          stackTrace: stackTrace,
        );
        emit(
          state.copyWith(
            debugMessage: 'Could not load saved trail for anchoring: $error',
            debugMessageIsError: true,
          ),
        );
      }

      final anchor = _nearestPoint(
        point,
        _flattenSavedTrailPoints(savedTrailsByDay),
      );
      if (anchor != null) {
        _trailPoints.add(anchor);
      }
      _puckTrailStarted = true;
    }

    final lastPoint = _trailPoints.isEmpty ? null : _trailPoints.last;
    if (lastPoint == null || _distanceMeters(lastPoint, point) >= 0.1) {
      _trailPoints.add(point);
      emit(state.copyWith(trailPoints: List.unmodifiable(_trailPoints)));
    }
  }

  void _onDebugAccuracyModeSelected(
    MapDebugAccuracyModeSelected event,
    Emitter<MapState> emit,
  ) {
    if (!kDebugMode) return;

    if (event.mode == DebugAccuracyMode.unavailable) {
      emit(state.copyWith(debugAccuracyMode: event.mode));
      return;
    }

    final range = switch (event.mode) {
      DebugAccuracyMode.strong => (3.0, 9.9),
      DebugAccuracyMode.fair => (10.0, 19.9),
      DebugAccuracyMode.poor => (20.0, 50.0),
      DebugAccuracyMode.unavailable => null,
    };
    if (range == null) return;

    final (minimum, maximum) = range;
    final accuracyMeters = minimum + _random.nextDouble() * (maximum - minimum);

    emit(
      state.copyWith(
        debugAccuracyMode: event.mode,
        debugAccuracyMeters: accuracyMeters,
      ),
    );
  }

  Future<void> _onSavedTrailLoadRequested(
    MapSavedTrailLoadRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(clearDebugMessage: true));

    try {
      final savedTrailPoints = await _getSavedTrailPoints(event.localDay);

      emit(
        state.copyWith(
          savedTrailPoints: savedTrailPoints,
          isSavedTrailVisible: true,
          savedTrailLocalDay: event.localDay,
          viewportMode: savedTrailPoints.isEmpty
              ? state.viewportMode
              : MapViewportMode.idle,
          debugMessage: savedTrailPoints.isEmpty
              ? 'No saved route found for ${event.localDay}.'
              : 'Loaded ${savedTrailPoints.length} points for ${event.localDay}.',
        ),
      );
    } on Exception catch (error) {
      emit(
        state.copyWith(
          debugMessage: 'Could not load saved route: $error',
          debugMessageIsError: true,
        ),
      );
    }
  }

  Future<void> _onAllSavedTrailLoadRequested(
    MapAllSavedTrailLoadRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(clearDebugMessage: true));

    try {
      _allSavedTrailPointsLoad = null;
      final savedTrailPoints = await _loadAllSavedTrailPoints();
      emit(
        state.copyWith(
          savedTrailPoints: savedTrailPoints,
          isSavedTrailVisible: true,
          clearSavedTrailLocalDay: true,
          debugMessage: savedTrailPoints.isEmpty
              ? 'No saved route points found.'
              : 'Loaded ${savedTrailPoints.length} saved points across all dates.',
        ),
      );
    } on Exception catch (error) {
      emit(
        state.copyWith(
          debugMessage: 'Could not load saved routes: $error',
          debugMessageIsError: true,
        ),
      );
    }
  }

  Future<void> _onRecentSavedTrailLoadRequested(
    MapRecentSavedTrailLoadRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(clearDebugMessage: true));

    try {
      _recentSavedTrailPointsLoad = null;
      final savedTrailsByDay = await _loadRecentSavedTrailPointsByDay();
      final savedTrailPoints = _flattenSavedTrailPoints(savedTrailsByDay);
      emit(
        state.copyWith(
          savedTrailPoints: savedTrailPoints,
          liveSavedTrailPointsByDay: savedTrailsByDay,
          isSavedTrailVisible: true,
          clearSavedTrailLocalDay: true,
          debugMessage: savedTrailPoints.isEmpty
              ? 'No saved routes for today or yesterday.'
              : 'Loaded ${savedTrailPoints.length} saved points from today and yesterday.',
        ),
      );
    } on Exception catch (error) {
      emit(
        state.copyWith(
          debugMessage: 'Could not load recent saved routes: $error',
          debugMessageIsError: true,
        ),
      );
    }
  }

  Future<void> _onSavedTrailVisibilityToggled(
    MapSavedTrailVisibilityToggled event,
    Emitter<MapState> emit,
  ) async {
    if (state.isSavedTrailVisible) {
      emit(state.copyWith(isSavedTrailVisible: false));
      return;
    }

    emit(state.copyWith(isSavedTrailVisible: true, clearDebugMessage: true));
    if (state.savedTrailPoints.isNotEmpty) return;

    try {
      final localDay = state.savedTrailLocalDay;
      final savedTrailPoints = localDay == null
          ? await _getAllSavedTrailPoints()
          : await _getSavedTrailPoints(localDay);

      emit(
        state.copyWith(
          savedTrailPoints: savedTrailPoints,
          viewportMode: savedTrailPoints.isEmpty
              ? state.viewportMode
              : MapViewportMode.idle,
          debugMessage: savedTrailPoints.isEmpty
              ? localDay == null
                    ? 'No saved route points found.'
                    : 'No saved route found for $localDay.'
              : localDay == null
              ? 'Loaded ${savedTrailPoints.length} saved points across all dates.'
              : 'Loaded ${savedTrailPoints.length} saved points for $localDay.',
        ),
      );
    } on Exception catch (error) {
      emit(
        state.copyWith(
          isSavedTrailVisible: false,
          debugMessage: 'Could not load saved route: $error',
          debugMessageIsError: true,
        ),
      );
    }
  }

  Future<void> _onAllSavedRoutesDeleteRequested(
    MapAllSavedRoutesDeleteRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(clearDebugMessage: true));

    try {
      await _deleteAllSavedRoutes();
      emit(
        state.copyWith(
          savedTrailPoints: const [],
          liveSavedTrailPointsByDay: const {},
          clearSavedTrailLocalDay: true,
          debugMessage: 'Deleted all saved route history.',
        ),
      );
      _allSavedTrailPointsLoad = null;
      _recentSavedTrailPointsLoad = null;
    } on Exception catch (error) {
      emit(
        state.copyWith(
          debugMessage: 'Could not delete saved routes: $error',
          debugMessageIsError: true,
        ),
      );
    }
  }

  Future<List<GeoPoint>> _getSavedTrailPoints(String localDay) async {
    final points = await _getRoutePointsForDay(localDay: localDay);
    return _toGeoPoints(points);
  }

  Future<List<GeoPoint>> _getAllSavedTrailPoints() async {
    final points = await _getAllSavedRoutePoints();
    return _toGeoPoints(points);
  }

  Future<List<GeoPoint>> _loadAllSavedTrailPoints() async {
    final load = _allSavedTrailPointsLoad ??= _getAllSavedTrailPoints();
    try {
      return await load;
    } on Exception {
      _allSavedTrailPointsLoad = null;
      rethrow;
    }
  }

  Future<Map<String, List<GeoPoint>>> _loadRecentSavedTrailPointsByDay() async {
    final load = _recentSavedTrailPointsLoad ??= () async {
      final pointsByDay = await Future.wait([
        _getSavedTrailPoints(_recentSavedTrailToday),
        _getSavedTrailPoints(_recentSavedTrailYesterday),
      ]);
      return {
        _recentSavedTrailToday: pointsByDay[0],
        _recentSavedTrailYesterday: pointsByDay[1],
      };
    }();

    try {
      return await load;
    } on Exception {
      _recentSavedTrailPointsLoad = null;
      rethrow;
    }
  }

  List<GeoPoint> _flattenSavedTrailPoints(
    Map<String, List<GeoPoint>> pointsByDay,
  ) {
    return [for (final points in pointsByDay.values) ...points];
  }

  GeoPoint? _nearestPoint(GeoPoint position, List<GeoPoint> savedPoints) {
    GeoPoint? nearest;
    var nearestDistance = double.infinity;

    for (final savedPoint in savedPoints) {
      final distance = _distanceMeters(position, savedPoint);
      if (distance < nearestDistance) {
        nearest = savedPoint;
        nearestDistance = distance;
      }
    }

    return nearest;
  }

  double _distanceMeters(GeoPoint a, GeoPoint b) {
    const earthRadiusMeters = 6371000.0;
    final latitudeA = a.latitude * pi / 180;
    final latitudeB = b.latitude * pi / 180;
    final deltaLatitude = (b.latitude - a.latitude) * pi / 180;
    final deltaLongitude = (b.longitude - a.longitude) * pi / 180;
    final sinHalfLatitude = sin(deltaLatitude / 2);
    final sinHalfLongitude = sin(deltaLongitude / 2);
    final haversine =
        sinHalfLatitude * sinHalfLatitude +
        cos(latitudeA) * cos(latitudeB) * sinHalfLongitude * sinHalfLongitude;

    return 2 * earthRadiusMeters * asin(sqrt(haversine.clamp(0.0, 1.0)));
  }

  List<GeoPoint> _toGeoPoints(Iterable<RoutePoint> points) {
    return points
        .map(
          (point) => GeoPoint(
            latitude: point.latitude,
            longitude: point.longitude,
            accuracyMeters: point.accuracyMeters,
            timestamp: point.recordedAtUtc,
          ),
        )
        .toList(growable: false);
  }

  String _formatLocalDay(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  @override
  Future<void> close() async {
    await _locationSubscription?.cancel();
    await super.close();
  }
}
