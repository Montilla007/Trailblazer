import '../../domain/entities/geo_point.dart';

enum MapStatus { initial, tracking, stopped, error }

enum MapViewportMode { idle, followingPuck }

enum DebugAccuracyMode { unavailable, poor, fair, strong }

class MapState {
  const MapState({
    this.status = MapStatus.initial,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    this.debugAccuracyMeters,
    this.debugAccuracyMode,
    this.errorMessage,
    this.viewportMode = MapViewportMode.idle,
    this.zoom = 15,
    this.pitch = 0,
    this.trailPoints = const [],
    this.isLiveTrailVisible = true,
    this.savedTrailPoints = const [],
    this.isSavedTrailVisible = true,
    this.savedTrailLocalDay,
    this.debugMessage,
    this.debugMessageIsError = false,
  });

  final MapStatus status;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final double? debugAccuracyMeters;
  final DebugAccuracyMode? debugAccuracyMode;
  final String? errorMessage;
  final MapViewportMode viewportMode;
  final double zoom;
  final double pitch;
  final List<GeoPoint> trailPoints;
  final bool isLiveTrailVisible;
  final List<GeoPoint> savedTrailPoints;
  final bool isSavedTrailVisible;
  final String? savedTrailLocalDay;
  final String? debugMessage;
  final bool debugMessageIsError;

  double? get effectiveAccuracyMeters {
    return switch (debugAccuracyMode) {
      DebugAccuracyMode.unavailable => null,
      DebugAccuracyMode.poor ||
      DebugAccuracyMode.fair ||
      DebugAccuracyMode.strong => debugAccuracyMeters,
      null => accuracyMeters,
    };
  }

  MapState copyWith({
    MapStatus? status,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    double? debugAccuracyMeters,
    DebugAccuracyMode? debugAccuracyMode,
    String? errorMessage,
    MapViewportMode? viewportMode,
    double? zoom,
    double? pitch,
    List<GeoPoint>? trailPoints,
    bool? isLiveTrailVisible,
    List<GeoPoint>? savedTrailPoints,
    bool? isSavedTrailVisible,
    String? savedTrailLocalDay,
    String? debugMessage,
    bool debugMessageIsError = false,
    bool clearAccuracyMeters = false,
    bool clearErrorMessage = false,
    bool clearDebugMessage = false,
    bool clearSavedTrailLocalDay = false,
  }) {
    return MapState(
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyMeters: clearAccuracyMeters
          ? null
          : accuracyMeters ?? this.accuracyMeters,
      debugAccuracyMeters: debugAccuracyMeters ?? this.debugAccuracyMeters,
      debugAccuracyMode: debugAccuracyMode ?? this.debugAccuracyMode,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      viewportMode: viewportMode ?? this.viewportMode,
      zoom: zoom ?? this.zoom,
      pitch: pitch ?? this.pitch,
      trailPoints: trailPoints ?? this.trailPoints,
      isLiveTrailVisible: isLiveTrailVisible ?? this.isLiveTrailVisible,
      savedTrailPoints: savedTrailPoints ?? this.savedTrailPoints,
      isSavedTrailVisible: isSavedTrailVisible ?? this.isSavedTrailVisible,
      savedTrailLocalDay: clearSavedTrailLocalDay
          ? null
          : savedTrailLocalDay ?? this.savedTrailLocalDay,
      debugMessage: clearDebugMessage
          ? null
          : debugMessage ?? this.debugMessage,
      debugMessageIsError: clearDebugMessage
          ? false
          : debugMessage != null
          ? debugMessageIsError
          : this.debugMessageIsError,
    );
  }
}
