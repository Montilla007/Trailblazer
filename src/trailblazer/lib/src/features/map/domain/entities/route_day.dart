class RouteDay {
  const RouteDay({
    required this.id,
    required this.localDay,
    required this.timezoneOffsetMinutes,
  });

  final int id;
  final String localDay; // "2026-11-02"
  final int timezoneOffsetMinutes; // UTC+8 is 480
}