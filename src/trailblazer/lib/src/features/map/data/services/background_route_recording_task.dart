import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trailblazer/src/features/map/data/datasources/route_database.dart';
import 'package:trailblazer/src/features/map/data/datasources/route_local_data_source.dart';
import 'package:trailblazer/src/features/map/data/repositories/route_history_repository_impl.dart';
import 'package:trailblazer/src/features/map/data/datasources/device_location_data_source.dart';
import 'package:trailblazer/src/features/map/domain/entities/geo_point.dart';
import 'package:trailblazer/src/features/map/domain/services/route_point_sampling_filter.dart';
import 'package:trailblazer/src/features/map/domain/usecases/save_route_point.dart';

@pragma('vm:entry-point')
void startBackgroundRouteRecording() {
  FlutterForegroundTask.setTaskHandler(BackgroundRouteRecordingTask());
}

class BackgroundRouteRecordingTask extends TaskHandler {
  final RoutePointSamplingFilter _samplingFilter = RoutePointSamplingFilter();
  StreamSubscription<void>? _locationSubscription;
  RouteDatabase? _database;
  SaveRoutePoint? _saveRoutePoint;
  bool? _lastForegroundState;
  bool _isUpdatingNotification = false;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _database = RouteDatabase();
    final repository = RouteHistoryRepositoryImpl(
      RouteLocalDataSource(_database!),
    );
    _saveRoutePoint = SaveRoutePoint(repository);

    _locationSubscription = DeviceLocationDataSource()
        .getPositionStream()
        .asyncMap(_processPosition)
        .listen(
          (_) {},
          onError: (Object error, StackTrace stackTrace) {
            _reportFailure(error, stackTrace);
          },
        );

    await _updateNotificationForAppState();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    unawaited(_updateNotificationForAppState());
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    await _database?.close();
    _database = null;
    _saveRoutePoint = null;
  }

  Future<void> _processPosition(Position position) async {
    final point = GeoPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
      speedMetersPerSecond: position.speed,
      timestamp: position.timestamp.toUtc(),
    );
    final shouldSave = _samplingFilter.shouldSave(point);

    if (shouldSave) {
      try {
        await _saveRoutePoint!(point);
      } catch (error, stackTrace) {
        _reportWarning(error, stackTrace);
        return;
      }
    }

    FlutterForegroundTask.sendDataToMain({
      'type': 'location',
      'latitude': point.latitude,
      'longitude': point.longitude,
      'timestampMillis': point.timestamp!.millisecondsSinceEpoch,
      'accuracyMeters': point.accuracyMeters,
      'speedMetersPerSecond': point.speedMetersPerSecond,
      'persistenceHandled': true,
      'wasSaved': shouldSave,
    });
  }

  Future<void> _updateNotificationForAppState() async {
    if (_isUpdatingNotification) return;
    _isUpdatingNotification = true;

    try {
      final isForeground = await FlutterForegroundTask.isAppOnForeground;
      if (_lastForegroundState == isForeground) return;

      final result = await FlutterForegroundTask.updateService(
        notificationTitle: 'Trailblazer is recording',
        notificationText: isForeground
            ? 'The app is open.'
            : 'The app is running in the background.',
      );
      if (result case ServiceRequestFailure(:final error)) {
        _reportWarning(error, StackTrace.current);
        return;
      }
      _lastForegroundState = isForeground;
    } catch (error, stackTrace) {
      _reportWarning(error, stackTrace);
    } finally {
      _isUpdatingNotification = false;
    }
  }

  void _reportFailure(Object error, StackTrace stackTrace) {
    developer.log(
      'Background route recording failed.',
      name: 'trailblazer.recording',
      error: error,
      stackTrace: stackTrace,
    );
    FlutterForegroundTask.sendDataToMain({
      'type': 'error',
      'message': error.toString(),
    });
    unawaited(
      FlutterForegroundTask.updateService(
        notificationTitle: 'Trailblazer recording paused',
        notificationText: 'Open the app to check recording status.',
      ),
    );
  }

  void _reportWarning(Object error, StackTrace stackTrace) {
    developer.log(
      'Background route recording warning.',
      name: 'trailblazer.recording',
      error: error,
      stackTrace: stackTrace,
    );
    FlutterForegroundTask.sendDataToMain({
      'type': 'warning',
      'message': error.toString(),
    });
  }
}
