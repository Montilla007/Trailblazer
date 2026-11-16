import 'dart:convert';

import 'package:trailblazer/src/features/location_tracking/domain/entities/geo_point.dart';

class MapTrailGeoJson {
  const MapTrailGeoJson._();

  static const emptyFeatureCollection =
      '{"type":"FeatureCollection","features":[]}';

  static String live({
    required Map<String, List<GeoPoint>> savedTrailsByDay,
    required List<GeoPoint> temporaryPoints,
    required bool includeSavedTrail,
  }) {
    final features = <Map<String, Object?>>[];
    if (includeSavedTrail) {
      for (final entry in savedTrailsByDay.entries) {
        if (entry.value.length >= 2) {
          features.add(
            _lineFeature(
              entry.value,
              properties: {'localDay': entry.key, 'trailType': 'saved'},
            ),
          );
        }
      }
    }
    if (temporaryPoints.length >= 2) {
      features.add(
        _lineFeature(temporaryPoints, properties: {'trailType': 'temporary'}),
      );
    }

    return _featureCollection(features);
  }

  static String singleLine(List<GeoPoint> points) {
    if (points.length < 2) return emptyFeatureCollection;
    return _featureCollection([_lineFeature(points, properties: const {})]);
  }

  static Map<String, Object?> _lineFeature(
    List<GeoPoint> points, {
    required Map<String, Object?> properties,
  }) {
    return {
      'type': 'Feature',
      'geometry': {
        'type': 'LineString',
        'coordinates': [
          for (final point in points) [point.longitude, point.latitude],
        ],
      },
      'properties': properties,
    };
  }

  static String _featureCollection(List<Map<String, Object?>> features) {
    if (features.isEmpty) return emptyFeatureCollection;
    return jsonEncode({'type': 'FeatureCollection', 'features': features});
  }
}
