import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import './src/app/trailblazer_app.dart'; // Adjust to your actual app import.

void main() {
  runZonedGuarded(
    () async {
      // TODO: #9 Fix the Access Token issue. For now, we are using the .env file to load the token.
      WidgetsFlutterBinding.ensureInitialized();
      await dotenv.load(fileName: '.env');

      // Catch Flutter framework errors.
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);

        debugPrint('Flutter error: ${details.exceptionAsString()}');
        debugPrintStack(stackTrace: details.stack);
      };

      const definedAccessToken = String.fromEnvironment('ACCESS_TOKEN');
      final accessToken = definedAccessToken.isNotEmpty
          ? definedAccessToken
          : dotenv.env['MAPBOX_ACCESS_TOKEN'];

      if (accessToken == null || accessToken.isEmpty) {
        throw StateError(
          'Mapbox access token is missing. Set MAPBOX_ACCESS_TOKEN in '
          '.env, or pass --dart-define=ACCESS_TOKEN.',
        );
      }

      MapboxOptions.setAccessToken(accessToken);

      // Catch uncaught asynchronous errors handled by the current zone.
      runApp(const TrailblazerApp());
    },
    (Object error, StackTrace stackTrace) {
      debugPrint('Uncaught application error: $error');
      debugPrintStack(stackTrace: stackTrace);
    },
  );
}
