# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app (requires a running emulator or connected device)
flutter run

# Build for web (production)
flutter build web --release --source-maps

# Static analysis (must pass before committing)
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Regenerate Hive type adapters after modifying a @HiveType model
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Environment Setup

The app requires a `.env` file in the project root (listed as an asset in `pubspec.yaml`). It must contain:

```
QUALTRICS_URL=
QUALTRICS_TOKEN=
FIREBASE_API_KEY=
FIREBASE_APP_ID=
FIREBASE_SENDER_ID=
FIREBASE_PROJECT_ID=
FIREBASE_AUTH_DOMAIN=
FIREBASE_STORAGE_BUCKET=
FIREBASE_MEASUREMENT_ID=
VAPID_KEY=
GITLAB_PROJECT_ID=
GITLAB_API_TOKEN=
ADMIN_DEBUG_PASSWORD=
```

Firebase is initialized from these env vars on web (`Firebase.initializeApp(options: ...)`) and from `google-services.json` / `GoogleService-Info.plist` on native. The `.env` file is **gitignored** — CI injects it via GitLab CI/CD variables (see `.gitlab-ci.yml`).

## Architecture

### State Management

Nine `ChangeNotifier` providers registered in `main.dart` via `MultiProvider`:

| Provider | Responsibility |
|---|---|
| `Answers` | Survey responses; submits to Qualtrics API; persists in Hive `"MoshiMoshi"` box |
| `Questions` | Loads/caches survey structure from Qualtrics; evaluates DisplayLogic/InPageDisplayLogic for 11 question types |
| `Validation` | Validates answers against 40+ rule types (whitelist, blacklist, regex, min/max) |
| `Screening` | Scores clinical instruments (BDI-2, STAI, PSQI, CSSRS, SBI, BPI); produces severity levels |
| `Moduli` | Maps 6 treatment modules to their weekly exercises |
| `Progress` | 49-day program state; syncs start date and syncCount to Firestore |
| `UserSettings` | Notification preferences, plant selection, debug flag |
| `Calendar` | Calendar UI focus state |
| `SafetyPlanning` | Metadata for 7 safety-plan categories |

### Navigation

Two navigation systems coexist:
- **`Navigator`** (standard Flutter) — used for all screen transitions (`pushReplacement`, `push`)
- **`Get.dialog()`** (GetX) — used only for in-app FCM notification popups in `main.dart`

The root widget is `GetMaterialApp` (required for `Get.dialog` to work), wrapping a `Stack` that places a global GitLab feedback `FloatingActionButton` over the app.

Auth gate: `FirebaseAuth.instance.currentUser == null` → `WelcomeScreen`, else → `LoadingScreen` (which fetches user data then routes to `MainScreen` or `ScreeningScreen`).

`MainScreen` is a tab shell with five tabs: Homepage, Exercises, Safety Planning, Diary, Settings.

### Local Persistence (Hive)

Three registered Hive types:
- `DailyScreening` (TypeId 0) — `daily_screening.dart`
- `Exercise` (TypeId 1) — uses `ExerciseSafeAdapter` (defensive reader with defaults) instead of generated `ExerciseAdapter`
- `WeeklyScreening` (TypeId 2) — `weekly_screening.dart`

On startup, `migrateWeeklyExercises()` normalises old `Exercise` records missing `assessment`/`tappa` fields before any provider reads from Hive.

Box names: `"moshimoshi"` (opened at startup for migration) and `"MoshiMoshi"` (used by providers — note the capitalisation difference).

### Survey / Qualtrics Integration

`Questions` provider fetches survey JSON from the Qualtrics API (`QUALTRICS_URL` + `QUALTRICS_TOKEN`) and caches it in Hive. The JSON structure mirrors Qualtrics export format (blocks → questions with `QuestionType`, `Selector`, `SubSelector`). Display logic evaluation (`DisplayLogic`, `InPageDisplayLogic`) with AND/OR conditions is implemented in `questions.dart`. Eleven question-type handlers live in `lib/questionHandlers/` and each corresponding widget is in `lib/widgets/questions/`.

### Key Global Constants

In `main.dart`:
- `const bool demo = false` — when `true`, skips certain API calls
- `const bool canSend = true` — gates answer submission to Qualtrics

## Linting

The project uses both `flutter analyze` lints (see `analysis_options.yaml`) and `dart_code_metrics`. Notable enforced rules:
- `prefer_relative_imports` — always use relative paths within `lib/`
- `avoid_print` — use `dart:developer`'s `log()` instead
- `use_build_context_synchronously` — required; async gaps before `context` use must be guarded
- `newline-before-return`, `prefer-trailing-comma`, `no-empty-block` — from dart_code_metrics

## CI/CD

GitLab CI (`.gitlab-ci.yml`) uses Flutter **3.29.1** image. Only `flutter build web --release` is run in CI; no test stage is currently configured.
