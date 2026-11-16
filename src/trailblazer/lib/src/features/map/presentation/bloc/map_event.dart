import 'map_state.dart';

sealed class MapEvent {
  const MapEvent();
}

final class MapTrackingRequested extends MapEvent {
  const MapTrackingRequested();
}

final class MapLocationReceived extends MapEvent {
  const MapLocationReceived({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracyMeters,
    this.persistenceHandledByService = false,
    this.wasSaved = false,
  });

  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? accuracyMeters;
  final bool persistenceHandledByService;
  final bool wasSaved;
}

final class MapPuckPositionReceived extends MapEvent {
  const MapPuckPositionReceived({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  final double latitude;
  final double longitude;
  final DateTime timestamp;
}

final class MapPuckLocationFailed extends MapEvent {
  const MapPuckLocationFailed(this.message);

  final String message;
}

final class MapPermissionDenied extends MapEvent {
  const MapPermissionDenied();
}

final class MapTrackingFailed extends MapEvent {
  const MapTrackingFailed(this.message);

  final String message;
}

final class MapRecordingWarning extends MapEvent {
  const MapRecordingWarning(this.message);

  final String message;
}

final class MapTrackingStopped extends MapEvent {
  const MapTrackingStopped();
}

final class MapViewportFollowRequested extends MapEvent {
  const MapViewportFollowRequested();
}

final class MapViewportFollowPaused extends MapEvent {
  const MapViewportFollowPaused();
}

final class MapZoomInRequested extends MapEvent {
  const MapZoomInRequested();
}

final class MapZoomOutRequested extends MapEvent {
  const MapZoomOutRequested();
}

final class MapPitchToggled extends MapEvent {
  const MapPitchToggled();
}

final class MapDebugAccuracyModeSelected extends MapEvent {
  const MapDebugAccuracyModeSelected(this.mode);

  final DebugAccuracyMode mode;
}

final class MapLiveTrailVisibilityToggled extends MapEvent {
  const MapLiveTrailVisibilityToggled();
}

final class MapSavedTrailVisibilityToggled extends MapEvent {
  const MapSavedTrailVisibilityToggled();
}

final class MapSavedTrailLoadRequested extends MapEvent {
  const MapSavedTrailLoadRequested({required this.localDay});

  final String localDay;
}

final class MapAllSavedTrailLoadRequested extends MapEvent {
  const MapAllSavedTrailLoadRequested();
}

final class MapRecentSavedTrailLoadRequested extends MapEvent {
  const MapRecentSavedTrailLoadRequested();
}

final class MapAllSavedRoutesDeleteRequested extends MapEvent {
  const MapAllSavedRoutesDeleteRequested();
}
