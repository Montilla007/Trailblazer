import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:trailblazer/src/features/location_tracking/domain/entities/geo_point.dart';
import 'package:trailblazer/src/features/map/presentation/services/map_trail_geojson.dart';

void main() {
  test('live trail returns separate day and temporary line features', () {
    final todayPoints = [
      GeoPoint(latitude: 10, longitude: 20),
      GeoPoint(latitude: 11, longitude: 21),
    ];
    final yesterdayPoints = [
      GeoPoint(latitude: 8, longitude: 18),
      GeoPoint(latitude: 9, longitude: 19),
    ];
    final temporaryPoints = [
      todayPoints.last,
      GeoPoint(latitude: 12, longitude: 22),
    ];
    final collection = jsonDecode(
      MapTrailGeoJson.live(
        savedTrailsByDay: {
          '2026-11-16': todayPoints,
          '2026-11-15': yesterdayPoints,
        },
        temporaryPoints: temporaryPoints,
        includeSavedTrail: true,
      ),
    ) as Map<String, dynamic>;
    final features = collection['features'] as List<dynamic>;

    expect(features, hasLength(3));
    final todayFeature = features[0] as Map<String, dynamic>;
    final yesterdayFeature = features[1] as Map<String, dynamic>;
    final temporaryFeature = features[2] as Map<String, dynamic>;
    final todayCoordinates =
        ((todayFeature['geometry'] as Map<String, dynamic>)['coordinates']
            as List<dynamic>);
    final yesterdayCoordinates =
        ((yesterdayFeature['geometry'] as Map<String, dynamic>)['coordinates']
            as List<dynamic>);
    final temporaryCoordinates =
        ((temporaryFeature['geometry'] as Map<String, dynamic>)['coordinates']
            as List<dynamic>);

    expect(
      (todayFeature['properties'] as Map<String, dynamic>)['localDay'],
      '2026-11-16',
    );
    expect(
      (yesterdayFeature['properties'] as Map<String, dynamic>)['localDay'],
      '2026-11-15',
    );
    expect(
      (temporaryFeature['properties'] as Map<String, dynamic>)['trailType'],
      'temporary',
    );
    expect(todayCoordinates.last, [21, 11]);
    expect(yesterdayCoordinates.first, [18, 8]);
    expect(temporaryCoordinates.first, [21, 11]);
    expect(temporaryCoordinates.last, [22, 12]);
  });

  test('live trail can omit the saved line for debug rendering', () {
    final collection = jsonDecode(
      MapTrailGeoJson.live(
        savedTrailsByDay: {
          '2026-11-16': [
            GeoPoint(latitude: 10, longitude: 20),
            GeoPoint(latitude: 11, longitude: 21),
          ],
        },
        temporaryPoints: [
          GeoPoint(latitude: 11, longitude: 21),
          GeoPoint(latitude: 12, longitude: 22),
        ],
        includeSavedTrail: false,
      ),
    ) as Map<String, dynamic>;

    expect(collection['features'], hasLength(1));
  });
}
