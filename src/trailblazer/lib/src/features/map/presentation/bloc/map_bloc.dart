import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trailblazer/src/features/map/domain/services/route_point_sampling_filter.dart';
import 'package:trailblazer/src/features/map/domain/usecases/save_route_point.dart';

import '../../domain/entities/geo_point.dart';
import '../../domain/usecases/watch_location_updates.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc(this._watchLocationUpdates, this._saveRoutePoint)
    : super(const MapState()) {
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
    on<MapPuckPositionSampled>(_onPuckPositionSampled);
  }

  final WatchLocationUpdates _watchLocationUpdates;
  StreamSubscription<GeoPoint>? _locationSubscription;
  final List<GeoPoint> _trailPoints = [];

  final SaveRoutePoint _saveRoutePoint;
  final RoutePointSamplingFilter _samplingFilter = RoutePointSamplingFilter();

  Future<void> _onPuckPositionSampled(
    MapPuckPositionSampled event,
    Emitter<MapState> emit,
  ) async {
    final sampledPoint = GeoPoint(
      latitude: event.latitude,
      longitude: event.longitude,
      accuracyMeters: event.accuracyMeters,
      timestamp: event.sampledAt,
    );

    // The filter decides whether this sample is worth saving.
    if (_samplingFilter.shouldSave(sampledPoint)) {
      await _saveRoutePoint(sampledPoint);
    }

    // Keep your existing live-trail update here.
    // For example, if you currently add every puck sample to _trailPoints:
    _trailPoints.add(sampledPoint);
    emit(state.copyWith(trailPoints: List.unmodifiable(_trailPoints)));
  }

  @override
  Future<void> close() async {
    await _locationSubscription?.cancel();
    await super.close();
  }
}
