import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    this._deleteAllSavedRoutes,
  ) : super(const MapState()) {
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
              accuracyMeters: point.accuracyMeters,
            ),
          );
        },
        onError: (Object error) {
          add(MapTrackingFailed(error.toString()));
        },
      );
    });

    on<MapLocationReceived>((event, emit) {
      emit(
        state.copyWith(
          status: MapStatus.tracking,
          latitude: event.latitude,
          longitude: event.longitude,
          accuracyMeters: event.accuracyMeters,
          clearAccuracyMeters: event.accuracyMeters == null,
          clearErrorMessage: true,
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
    on<MapPuckPositionSampled>(_onPuckPositionSampled);
    on<MapLiveTrailVisibilityToggled>((event, emit) {
      emit(state.copyWith(isLiveTrailVisible: !state.isLiveTrailVisible));
    });
    on<MapSavedTrailVisibilityToggled>(_onSavedTrailVisibilityToggled);
    on<MapSavedTrailLoadRequested>(_onSavedTrailLoadRequested);
    on<MapAllSavedTrailLoadRequested>(_onAllSavedTrailLoadRequested);
    on<MapAllSavedRoutesDeleteRequested>(_onAllSavedRoutesDeleteRequested);
  }

  final WatchLocationUpdates _watchLocationUpdates;
  final GetRoutePointsForDay _getRoutePointsForDay;
  final GetAllSavedRoutePoints _getAllSavedRoutePoints;
  final DeleteAllSavedRoutes _deleteAllSavedRoutes;
  StreamSubscription<GeoPoint>? _locationSubscription;
  final List<GeoPoint> _trailPoints = [];

  final SaveRoutePoint _saveRoutePoint;
  final RoutePointSamplingFilter _samplingFilter = RoutePointSamplingFilter();
  final Random _random = Random();

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

  Future<void> _onPuckPositionSampled(
    MapPuckPositionSampled event,
    Emitter<MapState> emit,
  ) async {
    final sampledPoint = GeoPoint(
      latitude: event.latitude,
      longitude: event.longitude,
      accuracyMeters: state.debugAccuracyMode == null
          ? event.accuracyMeters
          : state.effectiveAccuracyMeters,
      timestamp: event.sampledAt,
    );

    // The filter decides whether this sample is worth saving.
    if (_samplingFilter.shouldSave(sampledPoint)) {
      await _saveRoutePoint(sampledPoint);
      if (kDebugMode) {
        developer.log(
          '[Saved Cord] Saved route point to SQLite '
          '(approx lat: ${sampledPoint.latitude.toStringAsFixed(2)}, '
          'lon: ${sampledPoint.longitude.toStringAsFixed(2)}).',
          name: 'trailblazer.map',
        );

        final localDay = _formatLocalDay(sampledPoint.timestamp!.toLocal());
        if (state.isSavedTrailVisible) {
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
      }
    }

    _trailPoints.add(sampledPoint);
    emit(state.copyWith(trailPoints: List.unmodifiable(_trailPoints)));
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
      final savedTrailPoints = await _getAllSavedTrailPoints();
      emit(
        state.copyWith(
          savedTrailPoints: savedTrailPoints,
          isSavedTrailVisible: true,
          clearSavedTrailLocalDay: true,
          viewportMode: savedTrailPoints.isEmpty
              ? state.viewportMode
              : MapViewportMode.idle,
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
          clearSavedTrailLocalDay: true,
          debugMessage: 'Deleted all saved route history.',
        ),
      );
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
