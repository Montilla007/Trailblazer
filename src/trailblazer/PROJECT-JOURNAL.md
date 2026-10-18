# Trailblazer Project Journal

**Last updated:** October 12, 2026  
**Project:** Trailblazer  
**Technology:** Flutter and Dart, with BLoC/Cubit state management

This journal is the detailed handoff for understanding the project: what the app is meant to do, how its code is organized, how the current location flow works, what is already implemented, and what remains to be built. Update this file as the project changes.

## 1. What Trailblazer is

Trailblazer is a personal travel and movement journal. The planned app brings together a live map, a recorded route, photos attached to places, an album of those photos, and a history of daily movement. The design aims to keep route and photo information on the phone.

The main navigation has three sections:

- **Map:** the live map and, later, the current trail and photo markers.
- **Album:** the photo collection, ordered from newest to oldest, with time filters.
- **History:** daily movement summaries and places passed through.

The current implementation is still at the foundation stage. The Map screen can request the device's current location and display an interactive MapLibre map. Album and History are placeholders. Route recording and photo features are not implemented yet.

## 2. Technology and architecture

- **Flutter** builds the app UI; **Dart** is the programming language.
- **BLoC/Cubit** manages changing app state. Cubit is used where the feature only needs straightforward state updates.
- **Clean Architecture** separates the user interface, app rules/contracts, and device/plugin details.
- **MapLibre** displays and controls the map. The current style is OpenFreeMap Liberty, loaded from the internet.
- **Geolocator** checks location services and permissions and obtains a location from the device.

The intended dependency direction is from outer layers toward inner layers: presentation can use domain abstractions, and data implements domain contracts. Domain code should not depend on Flutter widgets, Geolocator, or MapLibre.

## 3. How the current location flow works

```text
Android phone GPS
       ↓
DeviceLocationDataSource
       ↓
LocationRepositoryImpl
       ↓
LocationRepository contract
       ↓
GetCurrentLocation use case
       ↓
MapCubit → MapState
       ↓
MapPage displays the location and positions the map camera
```

1. `TrailblazerApp` creates a `LocationRepository` provider. Its concrete implementation uses `DeviceLocationDataSource`.
2. When `MapPage` is built, it creates `MapCubit` and gives it `GetCurrentLocation`, which receives the repository. The cubit immediately calls `loadCurrentLocation()`.
3. `MapCubit` emits a loading state, then calls the use case. The use case delegates the request to the repository contract.
4. `LocationRepositoryImpl` forwards it to `DeviceLocationDataSource`. That class checks that location services are on, requests permission if needed, and asks Geolocator for the current position.
5. The result is converted into the app-owned `GeoPoint` type and returned up the chain. It is not saved persistently; the cubit stores the result in its current in-memory `MapState`.
6. `MapPage` listens to `MapState`. Once a location is available, it creates the MapLibre map centered on that latitude and longitude. If retrieval fails, it shows an error and Retry button.

The separation gives each part one job: the data source knows the device/plugin API, the repository fulfills the app-facing contract, the use case names the requested operation, the cubit manages loading/success/error UI state, and the page renders it.

## 4. Source code structure, explained

All hand-written Flutter app code is under `lib/`. `main.dart` is the Dart entry point; the actual application code lives under `lib/src/`.

```text
lib/
├── main.dart
└── src/
    ├── app/
    │   ├── trailblazer_app.dart
    │   └── app_shell.dart
    ├── core/
    │   └── theme/
    │       └── app_theme.dart
    ├── features/
    │   ├── map/
    │   │   ├── data/
    │   │   │   ├── datasources/
    │   │   │   │   └── device_location_data_source.dart
    │   │   │   └── repositories/
    │   │   │       └── location_repository_impl.dart
    │   │   ├── domain/
    │   │   │   ├── entities/
    │   │   │   │   └── geo_point.dart
    │   │   │   ├── repositories/
    │   │   │   │   └── location_repository.dart
    │   │   │   └── usecases/
    │   │   │       └── get_current_location.dart
    │   │   └── presentation/
    │   │       ├── cubit/
    │   │       │   ├── map_cubit.dart
    │   │       │   └── map_state.dart
    │   │       └── pages/
    │   │           └── map_page.dart
    │   ├── navigation/
    │   │   └── presentation/cubit/navigation_cubit.dart
    │   └── settings/
    │       └── presentation/cubit/appearance_cubit.dart
    └── shared/
        └── widgets/placeholder_page.dart
```

### App startup and shared app setup

- **`lib/main.dart`** — starts Flutter and runs `TrailblazerApp`. It should stay very small; app-wide setup belongs in the app layer.
- **`lib/src/app/trailblazer_app.dart`** — configures app-wide dependency providers and Cubits, creates `MaterialApp`, selects light/dark themes, and opens `AppShell`.
- **`lib/src/app/app_shell.dart`** — provides the shared screen frame: app bar, hamburger sheet, bottom navigation, and the currently selected page. It connects navigation and appearance controls to their Cubits.
- **`lib/src/core/theme/app_theme.dart`** — central place for the light/dark color schemes, shared text styles, and app-wide Material component defaults. A style belongs here when it should stay consistent across the app or be changed globally (for example, a future text-size preference). A one-off layout choice belongs in its specific widget.

### Feature layers

Each major app capability gets its own folder under `features/`. The Map feature currently has all three Clean Architecture layers:

- **`data/`** — implementation details and plugin/device integrations. This layer translates external APIs into app types.
- **`domain/`** — app concepts and contracts. Keep it independent from Flutter UI and device packages.
- **`presentation/`** — screens and state management. It turns state into UI and user actions into Cubit calls.

#### Map data layer

- **`map/data/datasources/device_location_data_source.dart`** — uses Geolocator to check the GPS service, request/check permission, and retrieve the current position. This is the only current location file that needs to know Geolocator details.
- **`map/data/repositories/location_repository_impl.dart`** — implements the domain repository contract by calling the device data source. If later we use a mock source or cached location, the presentation layer should not need to know which implementation is active.

#### Map domain layer

- **`map/domain/entities/geo_point.dart`** — a small app-owned value containing latitude and longitude. It avoids passing Geolocator's plugin-specific `Position` object through the app.
- **`map/domain/repositories/location_repository.dart`** — abstract contract describing the location capability the app needs. It says *what* is available without specifying the plugin or device mechanism.
- **`map/domain/usecases/get_current_location.dart`** — represents the app operation “get current location” and delegates it to the repository. More decision rules can live here if the operation grows; currently it is intentionally a thin call-through.

#### Map presentation layer

- **`map/presentation/cubit/map_cubit.dart`** — loads the location and emits loading, ready, or error state. It coordinates the use case; it should not contain map widget layout or call Geolocator directly.
- **`map/presentation/cubit/map_state.dart`** — defines the state consumed by the UI: status, optional `GeoPoint`, and optional error message.
- **`map/presentation/pages/map_page.dart`** — builds the Map screen, listens to `MapState`, displays the MapLibre canvas, GPS status indicator, zoom buttons, the Your Trail introduction, and Add a photo placeholder. MapLibre camera/rendering interaction is UI integration and is currently kept here. Future route-recording rules and sensor/location stream processing should be moved into suitable Cubit/use-case/data-source responsibilities rather than accumulating in the page.

#### Other current features

- **`navigation/presentation/cubit/navigation_cubit.dart`** — stores the selected bottom-navigation index and validates tab changes.
- **`settings/presentation/cubit/appearance_cubit.dart`** — stores the current `ThemeMode` and changes between light and dark. At present this is in-memory only; it resets when the app restarts.
- **`shared/widgets/placeholder_page.dart`** — reusable generic placeholder used by sections that are not implemented yet. Feature-specific screens should eventually live in their own feature folders.

## 5. Project-root files and generated/platform folders

The project root is `src/trailblazer/` (the Flutter project nested under the larger Trailblazer workspace). Open this folder in VS Code when working on the Flutter app.

- **`pubspec.yaml`** — app name, Dart SDK constraint, Flutter packages, and asset/font declarations. Current important packages include `flutter_bloc`, `maplibre_gl`, and `geolocator`.
- **`pubspec.lock`** — exact resolved package versions for repeatable dependency installs. Keep this in version control for the app.
- **`analysis_options.yaml`** — Dart analyzer/lint rules.
- **`test/`** — Flutter/Dart tests. `widget_test.dart` is the template test until replaced with project-specific tests.
- **`README.md`** — currently Flutter's starter README; it can later become a short project overview and run instructions. This journal carries the detailed architecture/handoff notes.
- **`Progress-2026-10-12.md`** — short dated progress snapshot created earlier. This journal is the fuller explanation.
- **`android/`** — Android host project and app configuration. `android/app/src/main/AndroidManifest.xml` declares Internet and coarse/fine location permissions. `android/gradle.properties` currently has `kotlin.incremental=false`, added to work around a Kotlin incremental-cache build failure. Gradle files configure the Android build; avoid editing generated files without a specific reason.
- **`ios/`, `macos/`, `windows/`, `linux/`, `web/`** — Flutter host/platform scaffolding generated for those targets. The current project goal is Android; platform-specific code belongs in the corresponding host folder only when that platform needs it.
- **`.dart_tool/`, `build/`, `.flutter-plugins-dependencies`, and generated plugin registrants** — generated by Flutter/package/build tooling. They are not the place for app feature code and can be regenerated by Flutter tooling.
- **`.idea/`, `trailblazer.iml`** — IDE project metadata; not app behavior.

The Android app declares Internet access because the current map style and map tiles are retrieved online. The location permission entries are needed for the device-location feature. Location permission prompts are controlled by Android and Geolocator at runtime.

## 6. Current feature status

### Map — partly implemented

- MapLibre displays the OpenFreeMap Liberty style.
- On opening the Map page, the app requests the current device location and uses it as the map's starting camera position at zoom level 15.
- A GPS/location status badge shows location loading, found, or unavailable.
- If location retrieval fails, the user can retry.
- Plus and minus controls call MapLibre camera zoom methods.
- The map supports its own gestures, but emulator pinch-to-zoom has not been verified because the emulator interaction workflow was not working as expected.
- The `Your Trail` introduction and `Add a photo` button are present. The button only displays a message; it does not select or save photos.
- Route recording, route drawing, and image markers/clusters are not implemented.

### Album — placeholder

The design plan is a photo collection ordered newest to oldest with Today, Week, Month, and Year filters. No photo storage or UI is implemented yet.

### History — placeholder

The design plan includes a daily movement summary, moving duration, start-to-end region labels (for example, Pangasinan → Tarlac), and a list of cities passed through. No activity detection or history persistence is implemented yet.

### Appearance/settings — basic behavior

The hamburger menu can switch light/dark theme while the app is running. The other listed menu items are intentionally inactive placeholders. Appearance is not saved between app launches yet.

## 7. Decisions and constraints to remember

- Use Flutter/Dart, editing in VS Code; Android Studio is installed for Android SDK/emulator/toolchain management.
- Use Clean Architecture with BLoC/Cubit.
- Keep the custom `lib/src/` source layout already in use.
- Work incrementally: get the map and location behavior stable before trail recording, markers, or photo features.
- The user prefers to make code edits in VS Code and receive explanations/code guidance in chat. Do not directly modify project files unless asked.
- Before that preference was stated, progress files were created at the user's request; this journal is also being created because the user explicitly asked for it.
- Keep location/travel data on-device as the product design intends. Decide on persistence and backup behavior explicitly before adding storage.

## 8. Suggested next steps

1. Verify the map opens centered on the physical phone's current location and that the location indicator behaves as expected.
2. Test touch pinch zoom on a physical phone or a reliable emulator multitouch setup; keep zoom buttons as an accessible alternative.
3. Test simulated movement in the Android emulator near a chosen location before implementing continuous recording.
4. Decide the location sampling, movement detection, battery use, and permission behavior for 24/7 tracking before building the recording feature.
5. Add recording state and location stream handling through the Map feature's Cubit/domain/data layers.
6. Add route rendering to MapLibre, then photo selection/storage and markers, followed by Album and History.
7. Add persistence only after agreeing on what is stored, retention/deletion controls, and whether data stays strictly local.

## 9. Resuming work

Start by opening `D:\chatgpt\programming\trailblazer\src\trailblazer` in VS Code. Read this journal's **Current feature status** and **Suggested next steps**, then inspect the relevant feature files under `lib/src/features/`. Keep the layer boundaries described above when extending behavior.
