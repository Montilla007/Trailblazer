import 'package:flutter/widgets.dart';
import 'package:trailblazer/src/app/trailblazer_app.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  MapboxOptions.setAccessToken(const String.fromEnvironment('ACCESS_TOKEN'));
  MapboxOptions.accessToken;

  runApp(const TrailblazerApp());
}
