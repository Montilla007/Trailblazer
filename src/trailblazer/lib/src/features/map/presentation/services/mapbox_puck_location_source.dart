import 'package:flutter/services.dart';
import 'package:trailblazer/src/features/map/domain/entities/geo_point.dart';

class MapboxPuckLocationSource {
  const MapboxPuckLocationSource();

  static const EventChannel _channel = EventChannel(
    'trailblazer/mapbox_puck_location',
  );

  Stream<GeoPoint> get updates {
    return _channel.receiveBroadcastStream().map((event) {
      if (event is! Map<dynamic, dynamic>) {
        throw const FormatException('Invalid Mapbox puck location event.');
      }

      final latitude = event['latitude'];
      final longitude = event['longitude'];
      if (latitude is! num || longitude is! num) {
        throw const FormatException('Mapbox puck event has no coordinates.');
      }

      return GeoPoint(
        latitude: latitude.toDouble(),
        longitude: longitude.toDouble(),
        timestamp: DateTime.now().toUtc(),
      );
    });
  }
}
