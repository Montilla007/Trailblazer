import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class DeviceLocationDataSource {
  Stream<Position> getPositionStream() async* {
    await _ensureLocationPermission();

    final locationSettings = defaultTargetPlatform == TargetPlatform.android
        ? AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
            intervalDuration: Duration(seconds: 5),
          )
        : const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
          );

    yield* Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  Future<void> _ensureLocationPermission() async {
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
}
