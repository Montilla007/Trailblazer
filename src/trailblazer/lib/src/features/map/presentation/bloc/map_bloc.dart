import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/geo_point.dart';
import '../../domain/usecases/watch_location_updates.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc(this._watchLocationUpdates) : super(const MapState()) {
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
    on<MapPuckPositionSampled>((event, emit) {
      final point = GeoPoint(
        latitude: event.latitude,
        longitude: event.longitude,
        timestamp: DateTime.now(),
      );

      _trailPoints.add(point);

      emit(state.copyWith(trailPoints: List.unmodifiable(_trailPoints)));
    });
  }

  final WatchLocationUpdates _watchLocationUpdates;
  StreamSubscription<GeoPoint>? _locationSubscription;
  final List<GeoPoint> _trailPoints = [];

  @override
  Future<void> close() async {
    await _locationSubscription?.cancel();
    await super.close();
  }
}
