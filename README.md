# MindBlooming — Moshi Moshi

**MindBlooming** is a mobile-first Flutter application developed at the University of Milan-Bicocca (`it.unimib.mindblooming`). It is a digital mental health companion that guides users through structured 49-day psychological support programs, combining clinical assessment tools, psychoeducational exercises, a personal diary, and a safety planning module.

The app is available on **Android**, **iOS**, **Web**, and **macOS**.

---

## Table of Contents

- [Features](#features)
- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [State Management](#state-management)
- [Data Persistence](#data-persistence)
- [Clinical Assessment Tools](#clinical-assessment-tools)
- [Treatment Modules](#treatment-modules)
- [Survey Engine (Qualtrics)](#survey-engine-qualtrics)
- [Notifications](#notifications)
- [Prerequisites](#prerequisites)
- [Environment Setup](#environment-setup)
- [Running the App](#running-the-app)
- [Building for Production](#building-for-production)
- [Linting & Analysis](#linting--analysis)
- [CI/CD](#cicd)
- [Technology Stack](#technology-stack)

---

## Features

| Feature | Description |
|---|---|
| **Onboarding & Auth** | Firebase Authentication (email/password). New users are routed through a clinical baseline screening before accessing the main app. |
| **Structured Program** | A 49-day therapeutic journey divided into weekly cycles. Each week contains psychoeducational lessons and exercises tied to the user's selected treatment modules. |
| **Clinical Screening** | Validated psychological instruments scored automatically (BDI-2, STAI, PSQI, CSSRS, SBI, BPI). Results determine which treatment modules are proposed to the user. |
| **Treatment Modules** | Six specialised paths (Depression & Anxiety, Self-Destructive Thoughts, Burnout, Chronic Pain, Relational Difficulties, Lifestyle). Up to 2 modules are active at a time; each covers 5 weeks of content. |
| **Daily & Weekly Check-ins** | Short daily mood assessments (m1, m2 psychometric metrics) and longer weekly screenings. Progress is charted over the programme duration. |
| **Exercises** | Weekly exercises delivered as lessons, surveys, audio sessions, videos (YouTube), or PDFs. Completion is tracked per week and module. |
| **Diary** | A personal journal with free-text entries. Entries are stored locally in Hive and displayed in a card feed. |
| **Safety Planning** | A structured seven-category crisis safety plan (warning signs, coping strategies, social contacts, professional contacts, safe environment, reasons for living, pleasurable activities). Each category supports drag-and-drop reordering. |
| **Push Notifications** | Firebase Cloud Messaging for remote notifications. Local notifications (daily check-in reminders, weekly and lesson nudges) are scheduled via `flutter_local_notifications`. |
| **Progress Visualisation** | Sparkline charts showing m1/m2 daily mood trends and BDI/DiffRel scores over the programme timeline. |
| **Feedback** | In-app screenshot annotation via `feedback` package, submitted as a GitLab issue. |
| **PDF Export** | Clinical summaries can be exported and viewed in-app via Syncfusion PDF Viewer and printed with the `printing` package. |

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                    main.dart                        │
│  BetterFeedback > Sizer > GetMaterialApp            │
│  MultiProvider (9 ChangeNotifiers)                  │
│  Auth gate: WelcomeScreen | LoadingScreen           │
└──────────────────────┬──────────────────────────────┘
                       │
         ┌─────────────▼─────────────┐
         │        MainScreen         │  ← 5-tab shell
         │  (StatefulWidget, index)  │
         └─┬──────┬──────┬──────┬───┘
           │      │      │      │
      Home Exercise Safety Diary Settings
```

### Navigation

Two navigation systems coexist:

- **`Navigator`** (standard Flutter) — all screen transitions use `pushReplacement` / `push`.
- **`Get.dialog()`** (GetX) — used only for in-app FCM notification popups in `main.dart`. `GetMaterialApp` is required as the root for this to work.

### Authentication Flow

```
WelcomeScreen
  ├─ LoginScreen  ──► LoadingScreen ──► MainScreen or ScreeningScreen
  └─ RegisterScreen ─► LoadingScreen ──► ScreeningScreen (baseline)
```

`LoadingScreen` reads the Hive box and Firestore to determine whether the user has completed the baseline screening. Users who have not yet completed it are sent to the `ScreeningScreen` (Qualtrics baseline assessment) before the main app is shown.

---

## Project Structure

```
lib/
├── main.dart                     # Entry point: Firebase, Hive, Provider, Sizer init
├── calling.dart                  # HTTP helper for Qualtrics API calls
├── utility.dart                  # HTML/media content parsing helpers
├── login/                        # Auth screens + FirebaseAuthService
├── models/                       # Hive data models (DailyScreening, Exercise, WeeklyScreening)
│   └── exercise_migration.dart   # Startup migration for legacy Exercise records
├── providers/                    # 9 ChangeNotifier state managers (see below)
├── screens/
│   ├── main_screen/              # Tab shell + 5 feature screens
│   │   ├── homepage_screen/      # Dashboard: calendar, assessment summary, testimonials
│   │   ├── exercises_screen/     # Weekly exercise cards
│   │   ├── diary_screen/         # Journal list, edit, save
│   │   ├── safety_planning_screen/ # 7-category safety plan
│   │   └── settings_screen/      # Account, notifications, resources, tutorial, debug
│   ├── questions_screen/         # Generic survey renderer
│   ├── results_screen/           # Screening results + module suggestions
│   ├── screening_screen.dart     # Baseline screening entry point
│   └── weekly_screening_screen/  # Weekly follow-up surveys
├── widgets/
│   ├── bottom_navbar/            # Custom bottom navigation bar
│   ├── questions/                # Per-type question widgets (11 types)
│   └── ...                       # Shared UI components
├── questionHandlers/             # Business logic for each question type
├── push_notification/            # FCM token registration
└── utility/
    ├── mindblooming_color_scheme.dart  # Brand colours + MaterialColor factory
    ├── mindblooming_text_style.dart    # Typography scale
    ├── notification_api.dart           # Local notification scheduling
    └── error_logger.dart              # Error reporting utilities
```

---

## State Management

All state is managed via **Provider 6** (`ChangeNotifier`). The nine providers are registered in `main.dart` and are available throughout the widget tree.

| Provider | Key Responsibilities |
|---|---|
| `Answers` | Stores survey answers keyed by question ID; submits completed surveys to the Qualtrics API; caches in Hive `"MoshiMoshi"` box. |
| `Questions` | Fetches and caches survey JSON from Qualtrics. Evaluates `DisplayLogic` / `InPageDisplayLogic` (AND/OR) for conditional question display. Supports 11 question types. |
| `Validation` | Applies 40+ validation rules per question (regex, min/max, whitelist/blacklist, matrix constraints). |
| `Screening` | Scores completed baseline blocks against BDI-2, STAI, PSQI, CSSRS, SBI, BPI algorithms. Produces severity levels (Alto/Moderato/Lieve/Minimo). Gender-specific scoring is supported. |
| `Moduli` | Holds the 6 treatment module definitions, their 5-week curricula, and pretty-print names. |
| `Progress` | 49-day programme state: start date, done surveys/blocks, daily m1/m2/DiffRel metrics, weekly exercise completion. Syncs `start` and `syncCount` to Firestore. |
| `UserSettings` | Notification preferences, plant avatar choice, debug mode toggle, data-send consent. |
| `Calendar` | Lightweight UI state for the calendar's focused date. |
| `SafetyPlanning` | Metadata for the 7 safety plan categories (icons, labels). |

> **Provider initialisation pattern:** Most providers expose an `init()` method (called by the screens that need them) rather than initialising in the constructor, because Hive boxes must be opened asynchronously.

---

## Data Persistence

### Hive (local)

Three registered Hive type adapters:

| Type | TypeId | File |
|---|---|---|
| `DailyScreening` | 0 | `models/daily_screening.dart` |
| `Exercise` | 1 | `models/exercise_safe_adapter.dart` (custom, defensive) |
| `WeeklyScreening` | 2 | `models/weekly_screening.dart` |

> **Note:** `ExerciseSafeAdapter` is used instead of the generated `ExerciseAdapter` to provide safe defaults for missing fields in records written by older app versions. `ExerciseAdapter` is commented out in `main.dart`.

**Hive box name quirk:** Two names are used across the codebase — `"moshimoshi"` (lowercase, opened at startup for migration) and `"MoshiMoshi"` (capitalised, used by all providers). These are **distinct boxes**. The startup migration target is the lowercase one.

### Firestore (remote)

User documents in the `users` collection sync:
- `start` — programme start date
- `syncCount` — number of data syncs performed

Survey responses are **not** stored in Firestore; they go directly to the Qualtrics API.

---

## Clinical Assessment Tools

The `Screening` provider scores the following validated instruments after the user completes the corresponding Qualtrics survey blocks:

| Instrument | Full Name | Measures |
|---|---|---|
| BDI-2 | Beck Depression Inventory – II | Depression severity |
| STAI | State-Trait Anxiety Inventory | Anxiety (state + trait) |
| PSQI | Pittsburgh Sleep Quality Index | Sleep quality |
| CSSRS | Columbia Suicide Severity Rating Scale | Suicide risk |
| SBI | Suicidal Behaviors Inventory | Self-destructive behaviour |
| BPI | Brief Pain Inventory | Chronic pain intensity |

Scores are mapped to severity tiers (Alto / Moderato / Lieve / Minimo). The `results_screen` uses these tiers plus user selections to propose up to 2 treatment modules.

---

## Treatment Modules

Six therapeutic paths, each consisting of 5 weeks of content:

| Module Key | Italian Label |
|---|---|
| `depressioneansia` | Depressione e Ansia |
| `pensieriautodistruttivi` | Pensieri Autodistruttivi |
| `burnout` | Burnout e Stress Lavoro Correlato |
| `dolorecronico` | Dolore Cronico |
| `difficoltarelazionali` | Difficoltà Relazionali |
| `stiledivita` | Difficoltà nello Stile di Vita |

A `baseline_assessment` module exists for the initial screening flow and its follow-up variants (`baseline_assessment_8`, `_12`, `_24`).

---

## Survey Engine (Qualtrics)

The app fetches survey definitions from the Qualtrics REST API using `QUALTRICS_URL` and `QUALTRICS_TOKEN` from `.env`. Survey JSON is cached in Hive to avoid repeated API calls on every app launch.

### Supported Question Types

| Code | Type |
|---|---|
| `MC` | Multiple Choice |
| `TE` | Text Entry |
| `DB` | Descriptive Block (read-only content) |
| `Matrix` | Matrix table (multiple sub-types) |
| `Slider` | Numeric slider |
| `RO` | Rank Order |
| `SBS` | Side-by-Side |
| `PGR` | Pick, Group & Rank |
| `CS` | Constant Sum |
| `FileUpload` | File attachment |

Display logic (show/hide questions based on prior answers) is evaluated client-side in `Questions.evaluateDisplayLogic()` using the Qualtrics export format for `DisplayLogic` and `InPageDisplayLogic` objects.

---

## Notifications

### Remote (Firebase Cloud Messaging)
- `push_notification/push_token_service.dart` registers the FCM token to Firestore on login.
- Foreground messages are intercepted in `main.dart` and shown as a `Get.dialog()`.

### Local (`flutter_local_notifications` + `timezone`)
- Configured in `utility/notification_api.dart`.
- Three notification channels: daily check-in reminder, weekly screening reminder, lesson/exercise nudge.
- Schedules are set from `UserSettings` (time-of-day preferences stored in Hive).

---

## Prerequisites

- **Flutter SDK** ≥ 3.27.0 (CI uses 3.29.1)
- **Dart SDK** ≥ 3.5.3
- **Java** 17 (required by Android Gradle Plugin 8.x)
- **Android SDK**: compileSdk 34, minSdk per Flutter default (21), targetSdk 34
- **iOS**: Xcode ≥ 14, CocoaPods, minimum deployment target iOS 13.0
- **Firebase project** with Auth, Firestore, Storage, and Messaging enabled
- A `.env` file (see [Environment Setup](#environment-setup))

---

## Environment Setup

Create a `.env` file in the project root. It is listed as a Flutter asset and loaded at startup via `flutter_dotenv`.

```env
QUALTRICS_URL=https://your-qualtrics-instance.qualtrics.com/API/v3
QUALTRICS_TOKEN=your_qualtrics_api_token

FIREBASE_API_KEY=
FIREBASE_APP_ID=
FIREBASE_SENDER_ID=
FIREBASE_PROJECT_ID=
FIREBASE_AUTH_DOMAIN=
FIREBASE_STORAGE_BUCKET=
FIREBASE_MEASUREMENT_ID=
VAPID_KEY=                     # Web push VAPID key for FCM

GITLAB_PROJECT_ID=             # For in-app feedback issue creation
GITLAB_API_TOKEN=              # GitLab personal access token with api scope
ADMIN_DEBUG_PASSWORD=          # Password to unlock debug settings screen
```

> On native Android/iOS, Firebase is also initialised from `google-services.json` (Android) and `GoogleService-Info.plist` (iOS). These files are gitignored.

---

## Running the App

```bash
# Install dependencies
flutter pub get

# Regenerate Hive adapters if you modified a @HiveType model
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run on a connected device or emulator
flutter run

# Run on a specific device
flutter run -d chrome          # Web
flutter run -d <device-id>     # Android / iOS / macOS
```

> **Debug flags in `main.dart`:**
> - `const bool demo = false` — set to `true` to skip certain API calls during development.
> - `const bool canSend = true` — set to `false` to prevent answer submission to Qualtrics.

---

## Building for Production

```bash
# Web
flutter build web --release --source-maps

# Android APK
flutter build apk --release

# Android App Bundle (recommended for Play Store)
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ios --release

# macOS
flutter build macos --release
```

> The release build currently uses the **debug signing config** for Android. Before publishing, configure a proper signing key in `android/app/build.gradle`.

---

## Linting & Analysis

```bash
flutter analyze
```

The project enforces both standard Flutter lints and `dart_code_metrics` rules (see `analysis_options.yaml`). Key enforced rules:

- `prefer_relative_imports` — always use relative paths inside `lib/`
- `avoid_print` — use `dart:developer`'s `log()` instead of `print()`
- `use_build_context_synchronously` — required; guard async gaps before using `BuildContext`
- `newline-before-return`, `prefer-trailing-comma`, `no-empty-block` — enforced by dart_code_metrics

---

## CI/CD

GitLab CI (`.gitlab-ci.yml`) runs on the `ghcr.io/cirruslabs/flutter:3.29.1` image.

| Stage | Job | Trigger |
|---|---|---|
| `build` | `build_and_test_web_app` | Every push |
| `deploy` | `pages` (GitLab Pages) | Push to `main` only |

The pipeline injects all `.env` values from GitLab CI/CD variables before building. The web release artifact is deployed to GitLab Pages.

---

## Technology Stack

| Category | Library / Service |
|---|---|
| **Framework** | Flutter 3.29.1, Dart 3.7+ |
| **State Management** | Provider 6 (ChangeNotifier) |
| **Navigation** | Flutter Navigator + GetX (dialogs only) |
| **Local Storage** | Hive 2 + Hive Flutter |
| **Backend** | Firebase Auth, Cloud Firestore, Firebase Storage, Firebase Messaging |
| **Survey Platform** | Qualtrics REST API (custom client in `calling.dart`) |
| **HTTP** | `http` + `dio` |
| **UI** | Material Design, flutter_screenutil, Sizer, Google Fonts |
| **Animation** | Rive (`.riv` plant animation) |
| **Localisation** | `intl` (Italian locale, `it_IT`) |
| **Notifications** | flutter_local_notifications + Firebase Cloud Messaging |
| **Media** | just_audio, youtube_player_iframe, Syncfusion PDF Viewer |
| **Feedback** | `feedback` + `feedback_gitlab` |
| **Charts** | chart_sparkline |
| **Calendar** | table_calendar |
| **Env Config** | flutter_dotenv |
