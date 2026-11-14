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
- Live Trail rendering from Mapbox's puck callback, anchored to the nearest
  saved route coordinate. In non-debug builds, the saved history and temporary
  puck segment render together as separate line features sharing the anchor;
  the temporary segment remains in memory only. Geolocator positions continue
  to drive sampled route-point persistence using Drift/SQLite. A debug-only
  layer query compares puck callback and queried positions.
- Debug-build-only Map panel and Saved Trail overlay for inspecting live and
  saved routes, loading an individual date, and deleting all saved route
  history after confirmation.
- Album and History screens are placeholders.

Photo capture/import and associations, background recording, offline map
downloads, and cloud sync are not implemented.

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
