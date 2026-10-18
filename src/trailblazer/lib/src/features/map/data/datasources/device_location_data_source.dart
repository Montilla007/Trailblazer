import 'package:geolocator/geolocator.dart';

import '../../domain/entities/geo_point.dart';

class DeviceLocationDataSource {
  Future<GeoPoint> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Turn on Location services, then tap Retry.');
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission was denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location access is blocked. Allow it in Android app settings.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );

    return GeoPoint(latitude: position.latitude, longitude: position.longitude);
  }

  Future<void> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Turn on Location services, then tap Retry.');
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission was denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location access is blocked. Allow it in Android app settings.',
      );
    }
  }

  Stream<GeoPoint> getLocationUpdates() async* {
    await _ensureLocationPermission();

    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).map(
      (position) =>
          GeoPoint(latitude: position.latitude, longitude: position.longitude, accuracyMeters: position.accuracy),
    );
  }
}
