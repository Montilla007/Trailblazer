import '../../domain/entities/geo_point.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/device_location_data_source.dart';

class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl(this._dataSource);

  final DeviceLocationDataSource _dataSource;

  @override
  Future<GeoPoint> getCurrentLocation() {
    return _dataSource.getCurrentLocation();
  }

  @override
  Stream<GeoPoint> getLocationUpdates() {
    return _dataSource.getLocationUpdates();
  }
}
