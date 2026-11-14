import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:trailblazer/src/features/map/domain/entities/geo_point.dart';
import 'package:trailblazer/src/features/map/presentation/services/map_trail_geojson.dart';

void main() {
  final savedPoints = [
    GeoPoint(latitude: 10, longitude: 20),
    GeoPoint(latitude: 11, longitude: 21),
  ];
  final temporaryPoints = [
    savedPoints.last,
    GeoPoint(latitude: 12, longitude: 22),
  ];

  test('live trail returns saved and temporary lines sharing the anchor', () {
    final collection = jsonDecode(
      MapTrailGeoJson.live(
        savedPoints: savedPoints,
        temporaryPoints: temporaryPoints,
        includeSavedTrail: true,
      ),
    ) as Map<String, dynamic>;
    final features = collection['features'] as List<dynamic>;

    expect(features, hasLength(2));
    final savedCoordinates =
        ((features[0] as Map<String, dynamic>)['geometry']
                as Map<String, dynamic>)['coordinates']
            as List<dynamic>;
    final temporaryCoordinates =
        ((features[1] as Map<String, dynamic>)['geometry']
                as Map<String, dynamic>)['coordinates']
            as List<dynamic>;
    expect(savedCoordinates.last, [21, 11]);
    expect(temporaryCoordinates.first, [21, 11]);
    expect(temporaryCoordinates.last, [22, 12]);
  });

  test('live trail can omit the saved line for debug rendering', () {
    final collection = jsonDecode(
      MapTrailGeoJson.live(
        savedPoints: savedPoints,
        temporaryPoints: temporaryPoints,
        includeSavedTrail: false,
      ),
    ) as Map<String, dynamic>;

    expect(collection['features'], hasLength(1));
  });
}
