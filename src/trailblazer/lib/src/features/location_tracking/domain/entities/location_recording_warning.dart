class LocationRecordingWarning implements Exception {
  const LocationRecordingWarning(this.message);

  final String message;

  @override
  String toString() => message;
}
