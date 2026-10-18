import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trailblazer/src/features/map/domain/entities/geo_point.dart';
import 'package:trailblazer/src/features/map/domain/usecases/watch_location_updates.dart';

import '../../domain/usecases/get_current_location.dart';
import 'map_state.dart';

import 'package:flutter/foundation.dart';

import 'dart:async';

class MapCubit extends Cubit<MapState> {
  MapCubit(this._getCurrentLocation, this._watchLocationUpdates)
    : super(const MapState());

  final GetCurrentLocation _getCurrentLocation;
  final WatchLocationUpdates _watchLocationUpdates;

  Timer? _simulationTimer;
  StreamSubscription<GeoPoint>? _locationSubscription;
  final List<GeoPoint> _trailPoints = [];

  Future<void> startRealLocationTracking() async {
    _simulationTimer?.cancel();
    await _locationSubscription?.cancel();

    emit(
      MapState(
        status: MapStatus.loadingLocation,
        location: state.location,
        trailPoints: List.unmodifiable(_trailPoints),
      ),
    );

    try {
      final firstLocation = await _getCurrentLocation();
      _recordRealLocation(firstLocation);

      _locationSubscription = _watchLocationUpdates().listen(
        _recordRealLocation,
        onError: (Object error) {
          emit(
            MapState(
              status: MapStatus.locationError,
              location: state.location,
              errorMessage: error.toString().replaceFirst('Exception: ', ''),
              trailPoints: List.unmodifiable(_trailPoints),
            ),
          );
        },
      );
    } catch (error) {
      emit(
        MapState(
          status: MapStatus.locationError,
          location: state.location,
          errorMessage: error.toString().replaceFirst('Exception: ', ''),
          trailPoints: List.unmodifiable(_trailPoints),
        ),
      );
    }
  }

  void _recordRealLocation(GeoPoint point) {
    if (_trailPoints.isNotEmpty &&
        _trailPoints.last.latitude == point.latitude &&
        _trailPoints.last.longitude == point.longitude) {
      return;
    }
    if (kDebugMode) {
      debugPrint(
        '[GPS] lat=${point.latitude.toStringAsFixed(6)}, '
        'lon=${point.longitude.toStringAsFixed(6)}, '
        'accuracy=±${point.accuracyMeters?.toStringAsFixed(1) ?? 'unknown'} m',
      );
    }

    _trailPoints.add(point);
    emit(
      MapState(
        status: MapStatus.ready,
        location: point,
        trailPoints: List.unmodifiable(_trailPoints),
      ),
    );
  }

  // Future<void> startRealLocationTracking() async {
  //   _simulationTimer?.cancel();
  //   await _locationSubscription?.cancel();

  //   emit(
  //     MapState(
  //       status: MapStatus.loadingLocation,
  //       location: state.location,
  //       trailPoints: List.unmodifiable(_trailPoints),
  //     ),
  //   );

  //   try {
  //     final firstLocation = await _getCurrentLocation();
  //     _recordRealLocation(firstLocation);

  //     _locationSubscription = _watchLocationUpdates().listen(
  //       _recordRealLocation,
  //       onError: (Object error) {
  //         emit(
  //           MapState(
  //             status: MapStatus.locationError,
  //             location: state.location,
  //             errorMessage: error.toString().replaceFirst('Exception: ', ''),
  //             trailPoints: List.unmodifiable(_trailPoints),
  //           ),
  //         );
  //       },
  //     );
  //   } catch (error) {
  //     emit(
  //       MapState(
  //         status: MapStatus.locationError,
  //         location: state.location,
  //         errorMessage: error.toString().replaceFirst('Exception: ', ''),
  //         trailPoints: List.unmodifiable(_trailPoints),
  //       ),
  //     );
  //   }
  // }

  // void _recordRealLocation(GeoPoint point) {
  //   if (_trailPoints.isNotEmpty &&
  //       _trailPoints.last.latitude == point.latitude &&
  //       _trailPoints.last.longitude == point.longitude) {
  //     return;
  //   }

  //   _trailPoints.add(point);
  //   emit(
  //     MapState(
  //       status: MapStatus.ready,
  //       location: point,
  //       trailPoints: List.unmodifiable(_trailPoints),
  //     ),
  //   );
  // }

  static const _simulationRoute = [
    // Start
    GeoPoint(latitude: 16.019000, longitude: 120.231000),

    // North — jumps of 50 m, 150 m, 450 m
    GeoPoint(latitude: 16.019450, longitude: 120.231000),
    GeoPoint(latitude: 16.020799, longitude: 120.231000),
    GeoPoint(latitude: 16.024846, longitude: 120.231000),

    // Northeast
    GeoPoint(latitude: 16.025164, longitude: 120.231331),
    GeoPoint(latitude: 16.026117, longitude: 120.232323),
    GeoPoint(latitude: 16.028979, longitude: 120.235301),

    // East
    GeoPoint(latitude: 16.028979, longitude: 120.235768),
    GeoPoint(latitude: 16.028979, longitude: 120.237172),
    GeoPoint(latitude: 16.028979, longitude: 120.241383),

    // Southeast
    GeoPoint(latitude: 16.028661, longitude: 120.241714),
    GeoPoint(latitude: 16.027707, longitude: 120.242706),
    GeoPoint(latitude: 16.024845, longitude: 120.245683),

    // South
    GeoPoint(latitude: 16.024396, longitude: 120.245683),
    GeoPoint(latitude: 16.023047, longitude: 120.245683),
    GeoPoint(latitude: 16.019000, longitude: 120.245683),

    // Southwest
    GeoPoint(latitude: 16.018682, longitude: 120.245352),
    GeoPoint(latitude: 16.017728, longitude: 120.244360),
    GeoPoint(latitude: 16.014866, longitude: 120.241383),

    // West
    GeoPoint(latitude: 16.014866, longitude: 120.240915),
    GeoPoint(latitude: 16.014866, longitude: 120.239512),
    GeoPoint(latitude: 16.014866, longitude: 120.235301),

    // Northwest
    GeoPoint(latitude: 16.015184, longitude: 120.234970),
    GeoPoint(latitude: 16.016138, longitude: 120.233978),
    GeoPoint(latitude: 16.019000, longitude: 120.231001),
  ];

  void startSimulation() {
    _simulationTimer?.cancel();
    _locationSubscription?.cancel();
    _locationSubscription = null;

    // Start a fresh trail for the simulated route.
    _trailPoints.clear();
    var index = 0;

    void emitSimulationPoint(GeoPoint point) {
      _trailPoints.add(point);
      emit(
        MapState(
          status: MapStatus.ready,
          location: point,
          isSimulated: true,
          trailPoints: List.unmodifiable(_trailPoints),
        ),
      );
    }

    emitSimulationPoint(_simulationRoute[index]);

    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      index = (index + 1) % _simulationRoute.length;

      // Clear only when the simulated route wraps to its start.
      if (index == 0) {
        _trailPoints.clear();
      }

      emitSimulationPoint(_simulationRoute[index]);
    });
  }

  @override
  Future<void> close() async {
    _simulationTimer?.cancel();
    await _locationSubscription?.cancel();
    return super.close();
  }
}
