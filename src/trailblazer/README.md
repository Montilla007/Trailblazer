# Trailblazer

Trailblazer is an Android-first, local-first travel journal built with Flutter
and Dart. It is intended to record routes and associate photos with places
without a backend or cloud sync.

## Requirements

- Flutter SDK compatible with the Dart constraint in `pubspec.yaml`
- Android device or emulator (Android 13 / API 33 or newer is the supported
  minimum)
- A Mapbox access token for map rendering

## Setup and run

Run commands from this Flutter project directory (`src/trailblazer`):

```shell
flutter pub get
flutter run
```

Before launching, create a local `.env` file in this directory with your
Mapbox token:

```text
MAPBOX_ACCESS_TOKEN=your_mapbox_access_token
```

The `.env` file is ignored by Git; do not commit access tokens. The app also
accepts the token through `--dart-define=ACCESS_TOKEN=...`. `lib/main.dart`
still loads `.env` during startup, so keep the local file present when using
that alternative.

## Current implementation

- Mapbox map with location puck, follow/recenter, zoom, and pitch controls.
- Device location updates and GPS accuracy display.
- Android route recording runs in an independent location foreground service.
  Its ongoing notification reports whether Trailblazer is open or running in
  the background and is not dismissible while recording. The service is
  configured to continue when the app is removed from Recents. Recording still
  starts automatically when the Map screen opens; an in-app Stop control and
  reboot resumption are not implemented. The app requests notification and
  location permissions when recording starts. Emulator checks confirmed the
  notification state changes in the foreground and background; Recents-swipe
  survival and physical-device behavior still need verification. Android
  system controls and device battery-management policies can still stop or
  restrict the service.
- Live Trail rendering from Mapbox's puck callback, anchored to the nearest
  saved route coordinate from today or yesterday (device-local dates captured
  when the map session opens and held until it closes). In
  non-debug builds, each saved day and the temporary puck segment render as
  separate line features; the temporary segment remains in memory only.
  The Android foreground service's Geolocator stream writes sampled route
  points to Drift/SQLite; a debug-only layer query compares puck callback and
  queried positions.
- Debug-build-only Map panel and Saved Trail overlay for inspecting live and
  saved routes, showing Geolocator update and SQLite save counts, loading an
  individual date, and deleting all saved route history after confirmation.
- Album and History screens are placeholders.

Photo capture/import and associations, notification actions such as an in-app
Stop control, reboot resumption, offline map downloads, and cloud sync are not
implemented.
Background continuation has not been verified on a physical device.

## Code organization

Application code is under `lib/src/`, grouped by responsibility:

- `app/` — app setup, dependency providers, and main navigation shell.
- `core/` — app-wide configuration and theme.
- `features/map/` — map presentation, location and route domain logic, and
  device/database integrations.
- `features/navigation/` and `features/settings/` — navigation and appearance
  state.
- `shared/` — reusable widgets.

`lib/main.dart` is retained as Flutter's entry point. The project journal and
implementation constraints are documented in `PROJECT-JOURNAL.md` and the
repository-level `PROJECT-RULES.md`.
