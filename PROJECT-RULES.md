# Project Rules

## Purpose and scope

This file records the project-specific rules to follow while designing and building this project. Keep it in the project folder beside the project README.

- `BLUEPRINT-RULES.md` contains shared rules for the Programming workspace and blueprint handoffs.
- `PROJECT_WORKFLOW.md` contains the step-by-step project brainstorming and handoff process.
- The project README contains the project purpose, features, requirements, architecture, technology choices, and open questions.
- This file supplements those documents with agreed project-specific implementation rules. Do not repeat their general guidance here.

## Project-specific decisions

Add or update rules here when the project requires a decision or constraint that is not already covered by the shared rules or README. Use only sections relevant to this project.

### Architecture and code organization

- Build the Android app with Flutter and Dart. Android is the only target platform in scope unless the user changes scope.
- Keep Dart application code in the project-level `src` directory. Retain Flutter's `lib/main.dart` entry point and delegate from it into `src` for compatibility with Flutter tooling.
- Use MapLibre for map rendering through a Flutter integration backed by MapLibre Native on Android. Confirm the specific integration and its required capabilities before relying on it.
- Keep Flutter package choices for local persistence and Android platform integrations open until confirmed.
- Support Android 13 (API 33) and newer. Keep the target Android SDK version as an open decision until it is confirmed.
- Keep the architecture small and responsibility-focused.
- Keep app data local. Do not add a backend, user accounts, cloud sync, or remote photo storage unless the user requests a scope change.
- Keep location recording, photo/media access, local persistence, and map presentation in clear responsibilities. Add abstractions only where they help those responsibilities remain understandable and changeable.

### API conventions

For projects with an API, record project-specific conventions such as:

- Route and versioning patterns.
- Request and response formats.
- Authentication and authorization behavior.
- Pagination, filtering, and sorting conventions.
- Compatibility requirements for API changes.

### Validation and error handling

- Record project-specific input validation requirements.
- Define any required error response shape or error codes.
- Do not expose secrets, stack traces, or sensitive internal details in client-facing errors.

### Security and data handling

- Treat location history, photo references, notes, and authentication state as sensitive personal data.
- Do not upload or log precise locations, photo metadata, notes, or authentication data.
- Use Android built-in biometric or device-credential authentication. Do not introduce a separate password or backend login unless requested.
- Request only required Android media/location permissions and explain their purpose in the app. Handle denied, limited, revoked, or unavailable permissions without crashing or losing unrelated saved records.
- Do not represent an old confirmed point as the user's current location. Preserve its timestamp and mark a photo association based on app location history as approximate.
- Follow the README's local-first and map-tile privacy requirements. Map tile requests may reveal the approximate map area viewed, but must not include Trailblazer's stored route, photo records, or notes.

### Location history

- Use both movement and elapsed time to request/record location updates. The initial target is about 10 meters or 30 seconds, whichever comes first; treat these as tunable starting values.
- Persist confirmed locations on-device and retain timestamps and available accuracy information.
- When GPS updates stop, keep the last confirmed point as historical data; do not silently present it as a fresh fix.
- For a photo without GPS metadata, use the most recent suitable confirmed app location recorded before capture and mark the association approximate. The age limit for a "suitable" location remains an open decision; do not invent one.
- If no suitable confirmed location exists, keep the photo without a map location and allow manual placement later.

### Photos and in-app album

- Do not copy or move source photos. The Trailblazer album is an in-app collection referencing original items from the phone's Camera album; keep Download photos separate.
- Removing an item from the Trailblazer album must not delete or move the original photo. The effect on its app note/location association is still an open decision; preserve data unless the user agrees to a deletion behavior.
- Handle source photos that are moved, deleted, or become inaccessible gracefully.
- Show older photos without prompting for notes. Prompt for a note for new photos captured after Trailblazer is installed.
- Read photo GPS metadata only when available and permitted by the user's Android permissions.

### Maps and offline regions

- Use the agreed MapLibre engine for the map UI, route trail, and photo markers through the selected Flutter integration.
- OpenFreeMap is only a proposed online tile source; confirm its terms and availability before depending on it.
- Before downloading offline regions, verify that the selected map-data provider permits offline downloads and follow its attribution, usage, and update requirements.
- If tiles are unavailable offline, retain locally saved records and show the map's unavailable state without implying location history has been lost.

### Implementation workflow

- Review the project README and these rules before starting a feature.
- Work in small, reviewable steps and keep behavior aligned with the README's agreed scope.
- Verify background location behavior early on a physical Android device because OS versions and device settings affect background operation.
- Do not implement offline tile downloads until the provider and its terms are confirmed.
- Do not add or run tests unless the user asks for testing or verification, as required by the shared blueprint rules.

### Project status

When the user sends one of these commands, update this project's **Status** in `D:\chatgpt\programming\project-blueprint\PROJECT_TRACKER.md`:

- `Status Planned`
- `Status In Progress`
- `Status Paused`
- `Status Complete`

### Other project constraints

- Desktop viewing, backend services, accounts, cloud backup, and sync are out of scope unless the user requests a change.
- Follow [README.md](README.md) for the remaining project decisions and open questions.

## Updating these rules

- Add a rule only when it is agreed for this project.
- If an item is already covered by `BLUEPRINT-RULES.md` or the project README, refer to it rather than duplicating it.
- Keep unresolved decisions in the project README as open questions; do not invent rules to fill gaps.
- Update this file when the user approves a change to a project-specific rule.
