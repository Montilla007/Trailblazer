import '../entities/geo_point.dart';

abstract interface class LocationRepository {
  Stream<GeoPoint> watchLocation();
}