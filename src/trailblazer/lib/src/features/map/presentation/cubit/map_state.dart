import '../../domain/entities/geo_point.dart';

enum MapStatus { loadingLocation, ready, locationError }

class MapState {
  const MapState({
    this.status = MapStatus.loadingLocation,
    this.location,
    this.errorMessage,
    this.isSimulated = false,
    this.trailPoints = const <GeoPoint>[],
  });

  final MapStatus status;
  final GeoPoint? location;
  final String? errorMessage;
  final bool isSimulated;
  final List<GeoPoint> trailPoints;
}