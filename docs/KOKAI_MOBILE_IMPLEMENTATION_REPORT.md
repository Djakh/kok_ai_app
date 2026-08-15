# KOK.AI Mobile MVP Implementation Report

Date: 2026-08-15

## Outcome

The Flutter prototype now has a backend-ready, repository-driven tree-registration MVP with a coherent Material 3 environmental technology design. Debug builds use a clearly labelled local fixture by default while the backend is unavailable; release builds default to the remote API.

No real KOK.AI backend or Kindwise integration was available for end-to-end verification.

## Implemented screens and components

- New Home dashboard with KOK.AI identity, registration CTA, honest recent-tree state, demo badge, loading skeleton, empty state, error state, refresh, and no fabricated impact totals.
- Five-action primary navigation: Home, Map, Add Tree, My Trees, Profile. Add Tree opens a full-screen route while the four persistent destinations keep their indexed-stack state.
- Eight-stage registration:
  1. contextual safety and privacy instructions;
  2. categorized multi-photo capture with required-slot validation, retake/remove, compression bounds, and permanent-denial settings path;
  3. 12-second foreground multi-sample location capture with live accuracy/sample count;
  4. indeterminate, honest analysis progress and retry;
  5. candidate confidence/taxonomy review, alternatives, unknown/manual correction, and attribution;
  6. nearby duplicate review with explicit same/new-tree actions;
  7. final evidence, privacy, nickname, notes, accuracy, and duplicate-check review;
  8. success actions for tree details, map, and another registration.
- Production-ready My Trees list with search debounce, sort options, cursor pagination, pull-to-refresh, incremental loading, skeleton, empty, error/retry, uncertainty source, dates, and accuracy.
- Repository-backed Map with tree markers, selected-tree preview, recenter action, user position only with permission, current-position accuracy circle, denied permission notice, empty/error/loading states, and Add Tree.
- Repository-backed tree details with identity source, AI confidence/provider, recorded accuracy circle, species description, categorized photos, optional health only when supplied, scan history, and disclaimers.

## Architecture decisions

- Retained Flutter BLoC, GetIt, GoRouter, Dio, SharedPreferences, Google Maps, Geolocator, Image Picker, Permission Handler, and Easy Localization from the repository.
- Added TreeRepository as the UI-facing boundary with analyzeTree, findNearbyTrees, createTree, getTree, getTrees, and getTreeScans.
- Added provider-neutral domain models for photos, samples, location evidence, species candidates, analysis, duplicates, trees, scans, and pagination.
- Added ApiTreeRepository for the future backend and FixtureTreeRepository for explicit demo mode.
- Added TreeDtoMapper to keep JSON parsing out of widgets and safely map nullable/unknown values.
- Added TreeRegistrationCubit as the workflow state machine.
- Added SharedPreferences draft persistence. Photos remain as local file paths; analysis failures do not clear them.
- A stable draft id produces stable "-analysis" and "-create" idempotency keys across retries.

## Location algorithm

LocationQualityService:

- rejects invalid latitude/longitude and accuracy ≤0 or above the configured 80 m ceiling;
- requires at least three accepted readings;
- calculates a median coordinate and rejects points outside max(12 m, median accuracy × 2.5);
- uses inverse-square accuracy weighting;
- caps weighting accuracy at one metre so an unrealistically optimistic fix cannot dominate;
- reports final coordinate, conservative max(best accuracy, accepted spread), sample counts, best reading, duration, timestamp, and quality;
- classifies excellent ≤5 m, acceptable ≤10 m, and poor >10 m.

These are UX categories and are never presented as survey-grade accuracy.

## Reused existing code

- Authentication/token refresh, profile pages, social/community routes, upload infrastructure, application startup, translations, and platform setup were retained.
- Existing GoRouter and GetIt structures were extended incrementally.
- Existing legacy TreeApiService remains for compatibility with unrelated code, but the core tree MVP uses TreeRepository.
- Existing Android/iOS camera and foreground-location permission declarations were retained and audited.

## Removed static or simulated production behavior

- Social feed is no longer the primary Home destination.
- Home no longer shows fabricated environmental statistics.
- Verification status is no longer labelled "Healthy."
- Tree map points no longer substitute a hardcoded coordinate for a missing tree location.
- Registration no longer uses fake percentage progress.
- AI analysis is never presented as real in demo mode.
- The new creation flow no longer generates a fresh idempotency key per retry.

## Remaining development fixtures

FixtureTreeRepository is selected when:

- KOKAI_DATA_MODE=fixture is explicitly supplied.

It is labelled "Demo data mode" in the UI. It returns two deterministic example species candidates, stores created trees only in process memory, finds nearby trees from that in-memory list, and never calls Kindwise. Debug and release builds now default to the backend API; release builds require API_BASE_URL.

## Tests executed

Pre-change baseline:

    dart format --output=none --set-exit-if-changed lib test

Found 19 existing formatting differences.

    flutter analyze

Result: no issues.

    flutter test

Result: 1 existing smoke test passed.

Post-change:

    dart format lib test
    flutter analyze
    flutter test
    flutter build apk --debug --dart-define=KOKAI_DATA_MODE=fixture

Result at handoff:

- Formatter: clean.
- Analyzer: no issues found.
- Tests: 43 passed, including startup retry recovery, persistent debug token fallback, static-session 401 protection, API request/response logging, refresh/error, multipart, idempotency, nullable mapping, and draft-resume contracts.
- Android debug build: succeeded at build/app/outputs/flutter-apk/app-debug.apk.

The first Android build attempt found a stale absolute output path inside the generated Flutter build cache. Running flutter clean and flutter pub get regenerated portable metadata; the subsequent APK build succeeded. The remaining Kotlin/Java deprecation messages are upstream plugin/toolchain warnings, not build failures.

New automated coverage includes:

- invalid coordinates and accuracy;
- empty/insufficient samples;
- geographic outlier removal;
- weighted coordinates and optimistic-fix cap;
- accuracy classification;
- normalized DTO and nullable data mapping;
- unknown enum fallback;
- health remaining distinct from registration status;
- required photo validation;
- analysis selection and user correction without overwriting AI evidence;
- workflow stage transitions;
- idempotency-key reuse after failed creation;
- multipart analysis photo-type/location-evidence association;
- nearby-tree empty and candidate API responses;
- remote invalid-image, low-confidence, quota, provider-unavailable, and timeout error codes;
- repeated remote creation using the same idempotency key;
- guided photo UI validation;
- analysis loading messaging;
- identification, nearby candidate, confirmation, and success widget states.

No automated test calls Kindwise or consumes provider credits.

## Known limitations

- A real backend is not deployed, so remote analysis, authentication compatibility, multipart limits, provider attribution, signed image URLs, pagination, and error mappings still require contract testing.
- The explicit same-tree action preserves the draft and explains the limitation; POST /trees/{tree_id}/scans is not submitted yet.
- Fixture-created trees live only for the current process. Registration drafts persist, but the fixture tree collection does not.
- Draft photo-file cleanup by age is not implemented yet. A production retention job should remove abandoned files after an agreed period.
- Image capture supports fixed typed slots. Replacement/removal is supported; arbitrary visual reordering is intentionally unnecessary because backend association is type-based.
- Map clustering was not added because it is a P1 item and needs a validated package/API choice plus a large dataset performance test.
- Tree list "nearest" needs the backend to define how client coordinates are supplied; the server must return unsupported_sort until agreed.
- Existing non-core profile/social screens still use their prior visual patterns and service layer.
- New MVP copy is English-first. Existing app localization remains active, but the new strings need translation after product wording is approved.
- The remote repository is covered with an in-process HTTP adapter, but deployed-environment contract tests are still required once the backend exists.
- The repository currently contains pre-existing user changes and platform Google Maps configuration. None were reverted.

## Backend blockers

- POST /api/v1/tree-analyses and Kindwise normalization.
- GET /api/v1/trees/nearby geospatial query.
- Idempotent POST /api/v1/trees.
- New paginated GET /api/v1/trees response.
- Full GET /api/v1/trees/{id} response.
- GET and POST scan endpoints.
- Stable error envelope/codes.
- Image storage, privacy, authentication, and licensed attribution behavior.

The exact contract is in docs/KOKAI_MOBILE_BACKEND_CONTRACT.md.

## Run commands

From the project root:

Fixture/demo mode:

    flutter pub get
    flutter run --dart-define=KOKAI_DATA_MODE=fixture

Remote API:

    flutter run \
      --dart-define=API_BASE_URL=https://api.example.com/api/v1

Platform-specific development URL overrides remain available:

    --dart-define=ANDROID_API_BASE_URL=http://10.0.2.2:8000/api/v1
    --dart-define=IOS_API_BASE_URL=http://localhost:8000/api/v1

Quality checks:

    dart format --output=none --set-exit-if-changed lib test
    flutter analyze
    flutter test

## Required configuration

| Variable | Values | Required |
|---|---|---|
| KOKAI_DATA_MODE | fixture or api | Optional; defaults to api |
| API_BASE_URL | HTTPS URL ending in /api/v1 | Required for production |
| ANDROID_API_BASE_URL | Development override | Optional |
| IOS_API_BASE_URL | Development override | Optional |

Platform Google Maps SDK keys are still configured through the existing Android manifest and iOS Info.plist setup. Kindwise variables must exist only on the backend and are intentionally absent from Flutter.

## Runtime backend dependencies

- A running backend and valid user session are required for live API mode.
- Real AI species identification and optional health information require the backend's Kindwise configuration and available credits.
- Provider image/text attribution.
- Persistent tree creation and cross-device list/map/detail refresh.
- Server-calculated nearby duplicate candidates.
- Follow-up scan creation.
- Remote cursor pagination and sorting.
- Authentication-protected or expiring image access.
- Backend-driven errors, quotas, timeout, and retry-after behavior.

## Recommended next task

Implement the backend contract starting with an authenticated, idempotent POST /api/v1/tree-analyses boundary that stores categorized uploads, validates location evidence, calls Kindwise only from the server, normalizes candidates, and maps provider failures to stable KOK.AI error codes. Add mocked-provider contract tests before using real Kindwise credits.
