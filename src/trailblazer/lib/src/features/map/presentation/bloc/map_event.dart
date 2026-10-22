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
    this.accuracyMeters,
  });

  final double latitude;
  final double longitude;
  final double? accuracyMeters;
}

final class MapPermissionDenied extends MapEvent {
  const MapPermissionDenied();
}

final class MapTrackingFailed extends MapEvent {
  const MapTrackingFailed(this.message);

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