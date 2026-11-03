import '../entities/geo_point.dart';
import '../repositories/route_history_repository.dart';

class SaveRoutePoint {
  const SaveRoutePoint(this._repository);

  final RouteHistoryRepository _repository;

  Future<void> call(GeoPoint point) async {
    final sampledAt = point.timestamp;

    if (sampledAt == null) {
      throw ArgumentError('A route point must have a sample timestamp.');
    }

    final localTime = sampledAt.toLocal();
    final localDay = _formatLocalDay(localTime);

    await _repository.savePoint(
      localDay: localDay,
      timezoneOffsetMinutes: localTime.timeZoneOffset.inMinutes,
      point: point,
    );
  }

  String _formatLocalDay(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}