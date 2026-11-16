import 'geo_point.dart';

class LocationUpdate {
  const LocationUpdate({
    required this.point,
    this.persistenceHandledByService = false,
    this.wasSaved = false,
  });

  final GeoPoint point;
  final bool persistenceHandledByService;
  final bool wasSaved;
}
