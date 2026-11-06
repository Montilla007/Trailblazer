# Trailblazer Project Journal

**Last updated:** November 4, 2026
**Project:** Trailblazer  
**Platform:** Android, minimum Android 13 (API 33)
**App stack:** Flutter and Dart, Mapbox Maps Flutter, Geolocator, BLoC, Drift/SQLite

This journal records the current project intent, architecture, implemented work, and unresolved items. It is a handoff/reference document, not a claim that every planned feature is complete.

## 1. Product summary

Trailblazer is a local-first personal travel journal. Its planned Map, Album, and History sections will combine movement routes, photos associated with locations, and daily summaries. Route and photo records are intended to remain on the device. There is no backend or cloud sync in the current scope.

- **Map:** current location, route display, future photo markers, map controls.
- **Album:** future local collection of referenced photos, newest first, with time filters.
- **History:** future daily movement summaries and places visited.

Album and History remain placeholders. Photo capture/import, photo associations, background recording, offline map downloads, and cloud sync are not implemented.

## 2. Current technology and architecture

- Flutter builds the app and Dart is the application language.
- Clean Architecture separates presentation, domain rules/contracts, and data/device integration.
- BLoC is used for the Map feature; Cubits remain in use for simpler navigation and appearance state.
- Mapbox Maps Flutter is the selected map SDK. Current Map page code uses Mapbox APIs.
- Geolocator provides the phone location stream used for location state and GPS accuracy.
- Drift provides the typed SQLite layer for local route history.
- Current package versions are recorded in the nested Flutter project's pubspec.yaml. Mapbox Maps Flutter is the map SDK dependency; the unused MapLibre package was removed after checking that no code or platform configuration relied on it.

Keep plugin types out of the domain layer. Presentation coordinates UI/map SDK behavior and dispatches app events. Domain owns entities, sampling rules, use-case contracts, and repository contracts. Data implements repositories and owns Drift and device adapters.

## 3. Location and route flows

### Phone location and map puck

Phone location services
  → Geolocator data source
  → LocationRepository
  → WatchLocationUpdates
  → MapBloc / MapState
  → GPS accuracy UI

The Map page also displays Mapbox's location puck. It samples the Mapbox location-indicator layer on a timer and dispatches MapPuckPositionSampled events. The map trail is built from puck coordinates so its displayed path follows the puck.

### Live trail and persisted route points

Mapbox puck sample
  → MapPuckPositionSampled
  → live trail in MapBloc state
  → GeoJSON source/layer on the map

Mapbox puck sample
  → RoutePointSamplingFilter
  → SaveRoutePoint use case
  → RouteHistoryRepository
  → RouteLocalDataSource
  → Drift / SQLite

The live trail is currently held in MapBloc memory and rendered as a Mapbox GeoJSON line. Persistence is a separate, filtered stream; not every 50 ms puck sample should be written to SQLite.

Current RoutePointSamplingFilter defaults in code are:
- Save at about 5 meters of movement or 5 seconds elapsed.
- Require at least 2 meters movement to reduce stationary drift saves.
- Compare direction using 3-meter heading segments and a 30-degree turn threshold.

These are implementation starting values and may need field testing. The current filter returns a bool from shouldSave(point), so it saves the triggering sample. It does not preserve a buffered point at the exact bend. Saved routes render as a blue line only; a single saved point is not drawn as a circle.

## 4. Local route database

Issue #18 covers saving filtered route coordinates locally by day. The current database model is:

### route_days

- id: generated integer primary key.
- localDay: unique local calendar date in YYYY-MM-DD format.
- timezoneOffsetMinutes: offset recorded for that local route day.

### route_points

- id: generated integer primary key.
- routeDayId: foreign key to route_days.
- sequence: increasing order within that day.
- latitude and longitude: decimal coordinates.
- recordedAtUtc: timestamp stored as UTC.
- accuracyMeters: nullable accuracy value.

The Drift database is RouteDatabase. Table definitions are in data/datasources/route_database.dart; generated route_database.g.dart is tooling output and must not be edited manually. build.yaml configures Drift DateTime storage as text. RouteLocalDataSource creates/finds a day row, assigns the next sequence, saves a point, and reads a day's points ordered by sequence. RouteHistoryRepositoryImpl implements the domain contract. TrailblazerApp provides and closes the database and provides the route repository.

SaveRoutePoint derives the local day and timezone offset from the puck sample timestamp before delegating to the repository. RoutePointSamplingFilter gates persistence in MapBloc. The database, repository read methods, and route-read use cases are present. In debug builds, the Map panel loads all saved points at startup, draws them as one connected blue line in timestamp order, and refreshes the line after each successful save. It can also load a selected day and delete all saved route rows after confirmation.

**Status:** storage code is present but still needs end-to-end verification. Do not treat issue #18 as finished until writes and reads have been checked on the running app.

## 5. Current source layout

The Flutter project root is:

D:\chatgpt\programming\trailblazer\src\trailblazer

Open this folder in VS Code when working on the app.

lib/
  main.dart
  src/
    app/
      trailblazer_app.dart
      app_shell.dart
    core/theme/
      app_theme.dart
    features/
      map/
        data/datasources/
          device_location_data_source.dart
          route_database.dart
          route_database.g.dart
          route_local_data_source.dart
        data/repositories/
          location_repository_impl.dart
          route_history_repository_impl.dart
        domain/entities/
          geo_point.dart
          route_point.dart
        domain/repositories/
          location_repository.dart
          route_history_repository.dart
        domain/services/
          route_point_sampling_filter.dart
        domain/usecases/
          get_current_location.dart
          save_route_point.dart
          watch_location_updates.dart
        presentation/bloc/
          map_bloc.dart
          map_event.dart
          map_state.dart
        presentation/pages/map_page.dart
        presentation/widgets/map_canvas.dart
      navigation/presentation/cubit/navigation_cubit.dart
      settings/presentation/cubit/appearance_cubit.dart
    shared/widgets/gps_accuracy_indicator.dart

Other important files:
- main.dart loads the Mapbox access token from local .env configuration.
- trailblazer_app.dart provides LocationRepository, RouteDatabase, and RouteHistoryRepository, plus NavigationCubit and AppearanceCubit.
- app_shell.dart provides the app bar, hamburger menu, and Map/Album/History navigation.
- app_theme.dart holds shared light/dark theme definitions.
- map_page.dart owns the Map screen layout and controls; map_canvas.dart owns Mapbox widget lifecycle, camera/gesture integration, trail rendering, and puck sampling.
- test/widget_test.dart is still the default counter smoke test and does not cover Trailblazer behavior.

## 6. Current feature status

### Map

Implemented in the current code:
- Mapbox map display and location puck.
- Puck heading and accuracy ring settings.
- Follow-puck camera mode; a pan gesture pauses following, and the recenter control requests follow again.
- Zoom and 2D/3D pitch controls.
- GPS accuracy indicator driven by MapBloc location state.
- Live trail drawn as a GeoJSON line, currently using green #28664A.
- Puck samples sent to MapBloc, with filtered samples routed to local persistence.
- Debug-only expandable panel for toggling live-trail visibility, displaying all saved route points as one connected line as SQLite writes arrive, loading a saved route by local date, and confirmed deletion of all persisted route history.
- Live and loaded saved trails use separate map sources and layers.

Needs verification or review:
- The latest reported `flutter analyze` completed with no issues.
- Verify a filtered point is written to SQLite, then verify getPointsForDay returns it after an app restart.
- Bound long-running live-trail memory growth. Filtering database writes does not bound the in-memory trail list.

### Album and History

Both remain placeholders. Album sorting/filtering and History daily summaries are design plans, not implemented features.

## 7. Recent discussion and deferred work

- The user chose Mapbox instead of MapLibre. App code, project rules, README, and package dependencies now consistently use Mapbox.
- Drift/SQLite was selected for local route storage. Routes are grouped by local day; each point stores UTC time and an increasing sequence.
- A three-mode control for Live trail / Saved trail / Both was proposed. The proposal was to keep green for the live trail, use a contrasting saved-trail color, and show both with 50% opacity. The user deferred this work; no mode state, UI control, saved layer, or load use case has been added.
- Route filtering and storage are being developed incrementally. Preserve that workflow and explain each step before adding another feature.
- The user edits code in VS Code and prefers code guidance in chat. Do not directly edit app source unless the user asks.

## 8. Known boundaries and next steps

1. Continue issue #18 by validating the current route-point save/read path; do not add the deferred Live/Saved/Both control yet.
2. Verify local day grouping and point sequence on the device/emulator.
3. Bound long-running live-trail memory growth; database sampling does not bound the in-memory trail list.
4. Keep offline map downloads, background startup, photos, Album, History, and cloud sync outside the current route-storage work unless the user changes scope.

## 9. Resuming work

Start in VS Code at D:\chatgpt\programming\trailblazer\src\trailblazer. Read this journal and PROJECT-RULES.md first. For issue #18, inspect the current MapBloc and route data files, then verify saving and reading a route day. Keep the deferred trail display-mode idea parked until requested again.
