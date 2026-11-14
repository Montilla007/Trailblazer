import 'dart:convert';

import 'package:trailblazer/src/features/map/domain/entities/geo_point.dart';

class MapTrailGeoJson {
  const MapTrailGeoJson._();

  static const emptyFeatureCollection =
      '{"type":"FeatureCollection","features":[]}';

  static String live({
    required List<GeoPoint> savedPoints,
    required List<GeoPoint> temporaryPoints,
    required bool includeSavedTrail,
  }) {
    final lines = <List<GeoPoint>>[];
    if (includeSavedTrail && savedPoints.length >= 2) {
      lines.add(savedPoints);
    }
    if (temporaryPoints.length >= 2) {
      lines.add(temporaryPoints);
    }

    return _lineFeatureCollection(lines);
  }

  static String singleLine(List<GeoPoint> points) {
    if (points.length < 2) return emptyFeatureCollection;
    return _lineFeatureCollection([points]);
  }

  static String _lineFeatureCollection(List<List<GeoPoint>> lines) {
    if (lines.isEmpty) return emptyFeatureCollection;

    return jsonEncode({
      'type': 'FeatureCollection',
      'features': [
        for (final points in lines)
          {
            'type': 'Feature',
            'geometry': {
              'type': 'LineString',
              'coordinates': [
                for (final point in points) [point.longitude, point.latitude],
              ],
            },
            'properties': <String, Object?>{},
          },
      ],
    });
  }
}
