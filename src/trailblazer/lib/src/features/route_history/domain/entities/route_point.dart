class RoutePoint {
  const RoutePoint({
    required this.id,
    required this.routeDayId,
    required this.sequence,
    required this.latitude,
    required this.longitude,
    required this.recordedAtUtc,
    this.accuracyMeters,
  });

  final int id;
  final int routeDayId;
  final int sequence;
  final double latitude;
  final double longitude;
  final DateTime recordedAtUtc;
  final double? accuracyMeters;
}
