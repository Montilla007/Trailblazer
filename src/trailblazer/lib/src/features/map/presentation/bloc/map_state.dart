import '../../domain/entities/geo_point.dart';

enum MapStatus { initial, tracking, stopped, error }

enum MapViewportMode { idle, followingPuck }

class MapState {
  const MapState({
    this.status = MapStatus.initial,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    this.errorMessage,
    this.viewportMode = MapViewportMode.idle,
    this.zoom = 15,
    this.pitch = 0,
    this.trailPoints = const [],
  });

  final MapStatus status;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final String? errorMessage;
  final MapViewportMode viewportMode;
  final double zoom;
  final double pitch;
  final List<GeoPoint> trailPoints;
  MapState copyWith({
    MapStatus? status,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    String? errorMessage,
    MapViewportMode? viewportMode,
    double? zoom,
    double? pitch,
    List<GeoPoint>? trailPoints,
    bool clearAccuracyMeters = false,
    bool clearErrorMessage = false,
  }) {
    return MapState(
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyMeters: clearAccuracyMeters
          ? null
          : accuracyMeters ?? this.accuracyMeters,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      viewportMode: viewportMode ?? this.viewportMode,
      zoom: zoom ?? this.zoom,
      pitch: pitch ?? this.pitch,
      trailPoints: trailPoints ?? this.trailPoints,
    );
  }
}
