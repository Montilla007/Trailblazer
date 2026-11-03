# Trailblazer

**Status:** In Progress  
**Plan finalized:** 2026-10-10  
**Platform:** Android  
**Minimum Android version:** Android 13 (API 33)  
**App framework:** Flutter  
**App language:** Dart  
**Storage:** On the user's device  
**Backend:** None for now

**Current implementation snapshot:** Mapbox map and puck controls are in place; local daily route storage is being developed and still needs end-to-end verification. Album and History remain placeholders.

## Purpose

Trailblazer is a personal location-history app. It records where the user has been and displays the current location and previous route on a map. Photos appear as map markers at their associated locations.

## Core features

### Location history and map

- Continuously record location on Android, including while the app is not in the foreground, subject to Android permissions and device behavior.
- Use both movement and elapsed time as location recording triggers. Initial values are about 10 meters or 30 seconds, whichever comes first; review and tune them during development/use.
- Show current location, the recorded trail, and photo markers on a map.
- Save location records on-device so tracking does not depend on an internet connection.

### Photos and notes

- Use the phone's default camera for capture.
- Detect photos in the phone's Camera album and show them in a Trailblazer album inside the app. Keep Download photos separate.
- Do not copy or move the original photo. Store a reference to it and keep Trailblazer notes/location associations in local app data.
- Prompt the user to add a note for a newly captured photo after Trailblazer is installed. Older photos can be viewed, but do not trigger note prompts.
- Use embedded GPS metadata when available and permitted by Android.
- If photo GPS metadata is unavailable, associate the photo with the most recent confirmed app location recorded before capture and indicate that the location is approximate.
- If no suitable recent confirmed location is available, save the photo in Trailblazer without a map location. Allow manual placement later.
- Removing a photo from the Trailblazer album removes it from that in-app collection only; it must not delete or move the original in Camera.

### Local authentication and offline use

- Unlock the app using Android's built-in biometric or device-credential authentication (such as fingerprint, face unlock, or device PIN). Do not add a separate app password or backend login.
- Keep location history, photo references, notes, and related app data on the device.
- Location recording and locally stored photo data should continue to work offline.
- Plan to support offline map regions stored on the device. The offline tile source is not yet selected and must permit offline downloads.
- When an area has not been downloaded and there is no connection, the map background may be unavailable while saved location and photo data remain accessible.

## Future features

- Desktop viewing is a possible future idea and is outside the current scope.
- Cloud sync, online backup, accounts, and a custom backend are outside the current scope unless requested later.

## Requirements and API specification

- Flutter app targeting Android; no custom backend or app API in the current plan.
- Support Android 13 (API 33) and newer. The target SDK remains to be confirmed.
- Integrate with Android location services, the default camera/media library, local notifications, and built-in device authentication through Flutter packages and Android platform integrations as needed.
- Request only the permissions needed for the agreed features and handle denied or limited permissions gracefully.

## Architecture and technology choices

### Agreed

- Flutter with Dart for the app.
- Android is the initial and only target platform in scope.
- Keep Dart application code in the project-level `src` directory. Retain the Flutter-generated `lib/main.dart` entry point and delegate from it into `src` so Flutter tooling can launch the app.
- Use Mapbox Maps Flutter for map rendering. Mapbox is the selected map SDK, and the unused MapLibre package has been removed.
- Use Geolocator for the phone location stream and GPS accuracy data.
- Use Drift with SQLite for local route history, grouped by local calendar day. Store timestamps in UTC and keep an increasing sequence for points within each day.
- Local-first data with no backend.
- Photos remain in the phone's Camera album; Trailblazer references them and maintains its own in-app album.

### Proposed, not yet agreed

- Flutter integrations for camera/media access, notifications, and biometric/device authentication.
- The data model and migration plan for future photo references, notes, and related metadata.

### Map data

- The current app uses Mapbox Maps Flutter for online map rendering.
- Offline regions remain a planned feature. Confirm Mapbox SDK capability, account limits, offline terms, attribution, storage needs, and update behavior before implementing downloads.
- Map tile requests disclose the approximate area being viewed to the tile provider; do not send the user's stored route, photo records, or notes to a map provider.

## Open questions

- Confirm Android platform integrations for media access, notifications, and biometric/device authentication.
- Confirm the offline map approach and Mapbox terms/account constraints before implementing offline downloads.
- Define the data model and migration approach for photo references and notes.
- Define how long a confirmed location remains eligible as the fallback for a photo without GPS metadata.
- Decide what Trailblazer should do with its note and location association when a photo is removed from the in-app album.
- Confirm the target Android SDK version and the exact permission flow for background location, Camera album access, photo-location metadata, and notifications. Android 13 (API 33) is the agreed minimum.
- Choose the final unique Android application ID.
- Review the initial 10-meter/30-second tracking settings after observing battery use and trail quality.

## Project rules

See [PROJECT-RULES.md](PROJECT-RULES.md) for implementation constraints and project-specific handling rules.
