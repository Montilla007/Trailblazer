import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trailblazer/src/features/map/domain/entities/geo_point.dart';
import 'package:trailblazer/src/features/map/domain/entities/location_recording_warning.dart';
import 'package:trailblazer/src/features/map/domain/entities/location_update.dart';

import '../services/background_route_recording_task.dart';
import 'device_location_data_source.dart';

class ForegroundRecordingDataSource {
  ForegroundRecordingDataSource() {
    if (_isAndroid) {
      FlutterForegroundTask.addTaskDataCallback(_onTaskData);
    }
  }

  static const _serviceId = 1717;
  static const _notificationTitle = 'Trailblazer is recording';

  final StreamController<LocationUpdate> _updates =
      StreamController<LocationUpdate>.broadcast();
  final DeviceLocationDataSource _deviceLocationDataSource =
      DeviceLocationDataSource();

  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  static void initializeService() {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'trailblazer_recording',
        channelName: 'Trail recording',
        channelDescription:
            'Shows when Trailblazer is recording a route in the background.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        allowWakeLock: true,
        allowAutoRestart: true,
        stopWithTask: false,
      ),
    );
  }

  Stream<LocationUpdate> get updates {
    if (_isAndroid) return _updates.stream;

    return _deviceLocationDataSource.getPositionStream().map(
      (position) => LocationUpdate(
        point: GeoPoint(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracyMeters: position.accuracy,
          speedMetersPerSecond: position.speed,
          timestamp: position.timestamp,
        ),
      ),
    );
  }

  Future<void> start() async {
    if (!_isAndroid) return;

    await _ensurePermissions();
    if (await FlutterForegroundTask.isRunningService) return;

    final result = await FlutterForegroundTask.startService(
      serviceId: _serviceId,
      serviceTypes: const [ForegroundServiceTypes.location],
      notificationTitle: _notificationTitle,
      notificationText: 'Trailblazer is open.',
      callback: startBackgroundRouteRecording,
    );

    if (result case ServiceRequestFailure(:final error)) {
      throw StateError('Could not start background route recording: $error');
    }
  }

  Future<void> stop() async {
    if (!_isAndroid || !await FlutterForegroundTask.isRunningService) return;

    final result = await FlutterForegroundTask.stopService();
    if (result case ServiceRequestFailure(:final error)) {
      throw StateError('Could not stop background route recording: $error');
    }
  }

  Future<void> _ensurePermissions() async {
    final notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      final requestedPermission =
          await FlutterForegroundTask.requestNotificationPermission();
      if (requestedPermission != NotificationPermission.granted) {
        throw StateError(
          'Allow Trailblazer notifications to show route recording status.',
        );
      }
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw StateError('Location services are turned off.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw StateError('Location permission was not granted.');
    }
  }

  void _onTaskData(Object data) {
    if (data is! Map<dynamic, dynamic>) {
      _updates.addError(
        const FormatException('Invalid background recording event.'),
      );
      return;
    }

    switch (data['type']) {
      case 'location':
        final latitude = data['latitude'];
        final longitude = data['longitude'];
        final timestampMillis = data['timestampMillis'];
        final accuracyMeters = data['accuracyMeters'];
        final speedMetersPerSecond = data['speedMetersPerSecond'];
        final persistenceHandled = data['persistenceHandled'];
        final wasSaved = data['wasSaved'];

        if (latitude is! num ||
            longitude is! num ||
            timestampMillis is! int ||
            (accuracyMeters != null && accuracyMeters is! num) ||
            (speedMetersPerSecond != null && speedMetersPerSecond is! num) ||
            persistenceHandled is! bool ||
            wasSaved is! bool) {
          _updates.addError(
            const FormatException('Invalid background location update.'),
          );
          return;
        }

        _updates.add(
          LocationUpdate(
            point: GeoPoint(
              latitude: latitude.toDouble(),
              longitude: longitude.toDouble(),
              accuracyMeters: accuracyMeters?.toDouble(),
              speedMetersPerSecond: speedMetersPerSecond?.toDouble(),
              timestamp: DateTime.fromMillisecondsSinceEpoch(
                timestampMillis,
                isUtc: true,
              ),
            ),
            persistenceHandledByService: persistenceHandled,
            wasSaved: wasSaved,
          ),
        );
      case 'error':
        _updates.addError(
          StateError(
            data['message']?.toString() ?? 'Background recording failed.',
          ),
        );
      case 'warning':
        _updates.addError(
          LocationRecordingWarning(
            data['message']?.toString() ??
                'Background recording encountered a recoverable problem.',
          ),
        );
      default:
        _updates.addError(
          const FormatException('Unknown background recording event.'),
        );
    }
  }

  Future<void> dispose() async {
    if (_isAndroid) {
      FlutterForegroundTask.removeTaskDataCallback(_onTaskData);
    }
    await _updates.close();
  }
}
