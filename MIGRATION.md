# MoshiMoshi Migration History

This document consolidates every major migration the codebase has gone through, in chronological order. Each phase is a self-contained migration; together they trace the project from an older Flutter / web-only build to the current Flutter 3.41.7 mobile-first build.

---

## Phase 1 — Flutter 3.27 / AGP 8 baseline migration

Brought the project from older Flutter / AGP 7.x to **Flutter 3.27+, Dart 3.5+, Android Gradle Plugin 8.x**.

### Problems found

| # | File | Problem | Severity |
|---|---|---|---|
| 1 | `android/settings.gradle` | Used the old `app_plugin_loader.gradle` approach removed in Flutter 3.22 | Build-breaking |
| 2 | `android/build.gradle` | AGP 7.1.2 incompatible with Gradle 8.9; `jcenter()` shut down; google-services classpath had a typo | Build-breaking |
| 3 | `android/app/build.gradle` | Old `apply plugin:` imperative style; Kotlin 1.7.21 too old; `targetSdkVersion 30`; multidex used Support Library | Build-breaking |
| 4 | `android/app/src/main/AndroidManifest.xml` | `package=` attribute conflicts with `namespace` in AGP 8+; deprecated `SplashScreenDrawable` | AGP 8 error |
| 5 | `analysis_options.yaml` + `pubspec.yaml` | `dart_code_metrics` v4 used the analyzer plugin system removed in Dart 3.4 | `flutter analyze` broken |

### 1.1 `android/settings.gradle` — complete rewrite

**Before** (old plugin-loader style, removed in Flutter 3.22+):
```groovy
include ':app'

def localPropertiesFile = new File(rootProject.projectDir, "local.properties")
def properties = new Properties()

assert localPropertiesFile.exists()
localPropertiesFile.withReader("UTF-8") { reader -> properties.load(reader) }

def flutterSdkPath = properties.getProperty("flutter.sdk")
assert flutterSdkPath != null, "flutter.sdk not set in local.properties"
apply from: "$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle"
```

**After** (new declarative `pluginManagement` + `plugins {}` style):
```groovy
pluginManagement {
    def flutterSdkPath = {
        def properties = new Properties()
        file("local.properties").withInputStream { properties.load(it) }
        def flutterSdkPath = properties.getProperty("flutter.sdk")
        assert flutterSdkPath != null, "flutter.sdk not set in local.properties"
        return flutterSdkPath
    }()

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.7.0" apply false
    id "org.jetbrains.kotlin.android" version "1.9.25" apply false
}

include ":app"
```

**Why:** Flutter 3.22 removed `app_plugin_loader.gradle`. The new approach uses Gradle's native `pluginManagement {}` and declares AGP + Kotlin versions in one place so all sub-projects inherit them.

### 1.2 `android/build.gradle` — major simplification

**Before:**
```groovy
buildscript {
    ext.kotlin_version = '1.7.21'
    repositories {
        google()
        jcenter()          // shut down, causes resolution failures
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.1.2'               // AGP 7 incompatible with Gradle 8.9
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath "com.google.gms.google-services4.4.1"                // TYPO: missing colon before version
    }
}
allprojects {
    repositories {
        google()
        jcenter()
    }
}
```

**After:**
```groovy
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = "../build"
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}
```

**Why:** With the new `settings.gradle`, `buildscript {}` is no longer needed — plugin versions are declared in `settings.gradle`. `jcenter()` was sunset February 2022. The google-services classpath typo would have caused a Gradle resolution failure.

### 1.3 `android/app/build.gradle` — full migration to the plugins block

**Before** (imperative `apply plugin:` style):
```groovy
apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"
apply plugin: ("com.google.gms.google-services")

android {
    compileSdkVersion 34
    // ... no namespace
    defaultConfig {
        minSdkVersion flutter.minSdkVersion
        targetSdkVersion 30      // outdated
        multiDexEnabled true
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    implementation 'com.android.support:multidex:1.0.3'  // support library, not AndroidX
}
```

**After** (declarative `plugins {}` style):
```groovy
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
    id "com.google.gms.google-services"
}

android {
    namespace "it.unimib.mindblooming"
    compileSdk 34
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId "it.unimib.mindblooming"
        minSdk flutter.minSdkVersion
        targetSdk 34
        multiDexEnabled true
    }
}

dependencies {
    implementation "androidx.multidex:multidex:2.0.1"
}
```

**Key changes:**
- `compileSdkVersion` → `compileSdk` (AGP 8 syntax)
- `targetSdkVersion 30` → `targetSdk 34` (Android 14; required for Play Store, compatible with Gradle 8.9/AGP 8.7)
- `namespace "it.unimib.mindblooming"` added (AGP 8 requires namespace in `build.gradle`, not manifest)
- `ndkVersion flutter.ndkVersion` — delegate NDK version to Flutter
- Kotlin stdlib no longer explicitly declared; AGP 8 + Kotlin Gradle plugin auto-include it
- `com.android.support:multidex` → `androidx.multidex:multidex:2.0.1` (AndroidX)
- Added `compileOptions` + `kotlinOptions` (required by some Firebase / plugin dependencies at the time)

### 1.4 `AndroidManifest.xml` — two fixes

**Removed `package` attribute (AGP 8 conflict):**
```xml
<!-- Before -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.mind_blooming">

<!-- After -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
```
AGP 8.0+ treats a `package` attribute differing from `namespace` in `build.gradle` as an error. The Kotlin source package (`com.example.mind_blooming`) is unrelated — it lives in the filesystem path.

**Removed deprecated `SplashScreenDrawable` meta-data:**
```xml
<!-- Removed -->
<meta-data
  android:name="io.flutter.embedding.android.SplashScreenDrawable"
  android:resource="@drawable/launch_background"
  />
```
Removed in Flutter 3.22; splash is now handled via `flutter_native_splash`.

### 1.5 `android/gradle.properties` — JVM memory bump

```properties
# Before
org.gradle.jvmargs=-Xmx1536M

# After
org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=2G -XX:+HeapDumpOnOutOfMemoryError
android.suppressUnsupportedCompileSdk=34
```

AGP 8.7 + Kotlin 1.9.25 consume significantly more heap than AGP 7 — 1536 MB caused OOM failures. `suppressUnsupportedCompileSdk=34` silences a lint warning when `compileSdk` is newer than the AGP release date.

### 1.6 `dart_code_metrics` removal

The Dart analyzer plugin system was removed in **Dart 3.4 / Flutter 3.22**. `dart_code_metrics` v4 registered itself as such a plugin via:
```yaml
analyzer:
  plugins:
    - dart_code_metrics
```
With Dart 3.5+ this section silently stops working and on some toolchains causes `flutter analyze` to error or hang.

**Changes:**
- Removed `analyzer: plugins: - dart_code_metrics` from `analysis_options.yaml`
- Removed the `dart_code_metrics:` rules block from `analysis_options.yaml`
- Removed `dart_code_metrics: ^4.19.2` from `pubspec.yaml` dev_dependencies

To keep enforcing dart_code_metrics rules, migrate to v5+ which ships as a standalone CLI (`dart run dart_code_metrics:metrics analyze lib`). `custom_lint` is a community replacement for the plugin mechanism.

### Versions

| Component | Before | After |
|---|---|---|
| Android Gradle Plugin | 7.1.2 | 8.7.0 |
| Kotlin | 1.7.21 | 1.9.25 (via `settings.gradle`) |
| Gradle Wrapper | 8.9 (already updated) | 8.9 (unchanged) |
| `targetSdk` | 30 | 34 |
| `compileSdk` | 34 | 34 (unchanged) |
| Multidex | `com.android.support:1.0.3` | `androidx.multidex:2.0.1` |
| Repository | `jcenter()` | `mavenCentral()` |
| `dart_code_metrics` | 4.19.2 (plugin, broken) | removed |

### What was NOT changed in Phase 1

- `lib/utility/mindblooming_color_scheme.dart` — `Color.withValues(alpha:)` is the modern API introduced in Flutter 3.27. No change needed at this phase (the `.red` / `.g` / `.b` migration came later in Phase 3).
- No Dart source files needed deprecation fixes at this phase.
- `pubspec.yaml` package versions were not bumped — existing constraints resolved to Dart 3.5+ / Flutter 3.29.1 compatible versions.
- iOS / macOS untouched by the Android Gradle migration.

---

## Phase 2 — Web → Android/iOS port

Removed web-only assumptions and the single file that was blocking mobile compilation.

### Root cause

`lib/widgets/custom_yt_adapter.dart` imported `dart:ui_web` at the top level:
```dart
import 'package:universal_html/html.dart' as html;
import 'dart:ui_web' as ui_web;
```
`dart:ui_web` doesn't exist in the mobile Flutter SDK, so the import was a compile-time error on every non-web target. Because the file was included unconditionally (via `question_text.dart`), the entire Android/iOS build failed before any code ran.

### 2.1 `lib/widgets/custom_yt_adapter.dart` — full rewrite

**Before:** Raw HTML `<iframe>` embedded via `HtmlElementView`, `dart:ui_web.platformViewRegistry`, and `universal_html` DOM APIs. Web-only; prevents mobile compilation.

**After:** Uses the `youtube_player_iframe` package (already in `pubspec.yaml`), which renders YouTube via an embedded WebView on Android/iOS. `YoutubePlayerScaffold` handles fullscreen correctly on mobile.

Logic kept from the old implementation: video ID extraction supports all YouTube URL formats — `youtube.com/watch?v=`, `youtu.be/`, `/embed/`, and `youtube-nocookie.com/embed/`.

### 2.2 `pubspec.yaml` — dependency cleanup

| Package | Action | Reason |
|---|---|---|
| `universal_html: ^2.0.8` | **Removed** | Web-only; only used in the now-rewritten `custom_yt_adapter.dart` |
| `flutter_platform_widgets: ^1.11.0` | **Removed** | Listed but never imported |
| `syncfusion_flutter_pdfviewer: ^28.2.12` | **Removed** | Listed but never imported; PDF rendering uses `printing` |
| `dio: ^5.8.0+1` | **Removed** | Listed but never imported; HTTP uses `http` |
| `audio_session: ^0.1.21` | **Added** | Imported in `custom_audio_adapter.dart` but missing from pubspec |

### 2.3 `android/app/build.gradle` — `minSdkVersion` bump

Changed from `flutter.minSdkVersion` (which resolved to 16 in older Flutter setups) to an explicit `21`, to satisfy:

| Package | Min SDK |
|---|---|
| `just_audio` | 21 |
| `flutter_local_notifications` | 21 |
| `firebase_messaging` (since removed) | 19 |
| `youtube_player_iframe` (via flutter_inappwebview) | 19 |

Also dropped the `implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"` line — `$kotlin_version` was undefined after Phase 1 moved Kotlin to `settings.gradle`, and the modern plugin DSL auto-includes the stdlib.

### What didn't need changes in Phase 2

- `lib/utility/mindblooming_text_style.dart` — already uses `GetPlatform.isMobile` / `GetPlatform.isDesktop` for responsive text sizing.
- `lib/widgets/questions/question_text.dart` — `image_network` (mobile + web) and `printing` (mobile) work.
- `lib/widgets/custom_audio_adapter.dart` — `just_audio` + `audio_session` are mobile-native.
- `lib/questionHandlers/file_uploader_handler.dart` — `file_picker` supports Android and iOS.
- `lib/utility/notification_api.dart` — `flutter_local_notifications` already configured with Android/iOS-specific details.
- All providers, Hive models, and screen widgets were platform-agnostic.

---

## Phase 3 — Flutter 3.27 → 3.41.7 upgrade

**Date:** April 23, 2026
**From:** Flutter 3.27 / Dart 3.5.3
**To:** Flutter 3.41.7 / Dart 3.11.5

### 3.1 Dart / SDK updates

- `pubspec.yaml` SDK constraint → `">=3.5.3 <4.0.0"`
- `intl` `^0.19.0` → `^0.20.2` (required by Flutter 3.40+)

### 3.2 Deprecated API fixes

- `lib/utility/mindblooming_color_scheme.dart` — Color components `.red` / `.green` / `.blue` → `.r * 255` / `.g * 255` / `.b * 255` (deprecated in newer Flutter)
- `lib/screens/main_screen/settings_screen/settings_screen.dart` — `SwitchListTile` `activeColor` → `activeThumbColor`

### 3.3 Package updates

- `google_fonts` `4.0.5` → `8.0.0` (fixes a FontWeight constant evaluation error introduced in newer Dart)

### 3.4 `lib/widgets/custom_yt_adapter.dart` — web platform safety

Added try-catch around `platformViewRegistry` to gracefully handle browsers where it's unavailable. (The Phase 2 rewrite already moved this file to `youtube_player_iframe`; this is a follow-up hardening for the fallback path.)

### 3.5 Build configuration touch-ups

- Confirmed `targetSdkVersion 34` (Android 14 compatibility — completed in Phase 1, re-verified here)
- Confirmed `mavenCentral()` repositories (Phase 1)

### File changes summary

| File | Change |
|---|---|
| `pubspec.yaml` | SDK constraint + `intl` + `google_fonts` |
| `lib/utility/mindblooming_color_scheme.dart` | Color API migration |
| `lib/screens/main_screen/settings_screen/settings_screen.dart` | `SwitchListTile` fix |
| `lib/widgets/custom_yt_adapter.dart` | Web platform error handling |
| `android/app/build.gradle` | Build configuration |
| `android/build.gradle` | Repository and dependencies |
| `android/gradle/wrapper/gradle-wrapper.properties` | Gradle version |
| `android/settings.gradle` | Plugin management |

### Verification

```bash
flutter pub run build_runner build --delete-conflicting-outputs
# [INFO] Succeeded after 4.0s with 6 outputs (317 actions)

flutter pub get
# All dependencies resolved successfully

flutter analyze
# No critical errors found
```

### Final environment

```
Flutter: 3.41.7
Channel:  stable
Dart:     3.11.5
Framework revision: cc0734ac71 (2026-04-15)
Engine:   7a53c052bc4b472cf780b199087e1368e4a9aa8c
Tools:    DevTools 2.54.2
```

---

## Build and run commands

### Android
```bash
flutter clean
flutter pub get
flutter build apk --release
# or for App Bundle:
flutter build appbundle --release
```

### iOS
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ios --release
```

### On a device or emulator
```bash
flutter run
# Or specify device:
flutter run -d <device-id>
```

---

## Testing checklist

Before deploying to production, verify:

- Authentication — login/register flows work
- Assessments — daily/weekly screenings display and save correctly
- Exercises — exercise list loads and exercises play
- Diary — journal entries save and display (now backed by Hive, see note below)
- Safety planning — safety plan tools accessible
- Notifications — local notifications trigger correctly
- UI colours — app renders correctly with the new Color components API
- Settings — debug toggle and other settings work
- Offline mode — Hive local storage works

---

## Known limitations

### Web platform
- YouTube player requires additional browser permissions
- `platformViewRegistry` may not be available in all browsers (handled gracefully — see 3.4)

### Discontinued but still-functional packages
- `dart_code_metrics` (removed from this project in Phase 1; if you want to bring it back, use v5+ CLI)
- `flutter_platform_widgets` (removed from this project in Phase 2)

### Tooling
- If `analyzer` version warns about a mismatch with the SDK, upgrade with `flutter pub add dev:analyzer:^13.0.0`.

---

## Troubleshooting

If something doesn't compile after pulling these changes:

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

Check the toolchain:
```bash
flutter --version
flutter doctor -v
```

If a Hive adapter conflict appears, the `--delete-conflicting-outputs` flag above is what resolves it.

---

## Phase 4 — Firebase removal

Earlier phases referenced `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) as prerequisites for running the app. **Firebase has since been fully removed from the project.** The app is now fully offline-first apart from the Qualtrics survey API and the GitLab feedback endpoint.

### 4.1 What was removed

| Area | Before | After |
|---|---|---|
| Auth | `FirebaseAuth.signInWithEmailAndPassword(...)` | Stub `FirebaseAuthService` returning a `LocalUser` UUID stored in Hive |
| Diary | Firestore `collection('diary')` with `StreamBuilder<QuerySnapshot>` | Hive box `'diary'` with `ValueListenableBuilder<Box>` |
| Init | `Firebase.initializeApp()` in `main.dart` | Removed entirely |
| Web push | `web/firebase-messaging-sw.js` + service-worker registration in `web/index.html` | Both deleted |
| Native config | `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist` | Both deleted |
| Android plugin | `id "com.google.gms.google-services"` in `android/app/build.gradle` | Removed |
| Packages | `firebase_auth`, `firebase_core`, `cloud_firestore`, `firebase_storage` | Removed from `pubspec.yaml` |

### 4.2 Diary migration to Hive

A new Hive box `'diary'` is opened in `main.dart` at startup alongside the existing `'moshimoshi'` box. Each note is stored as a `Map<String, dynamic>` keyed by a UUID, with fields `{title, content, date, userId, diaryId, diaryType}`.

- `save_diary.dart`: generates a UUID and writes a new map to the box.
- `edit_diary.dart`: reads the existing map, spreads it, overwrites the changed fields.
- `diary_list_screen.dart`: replaces `StreamBuilder<QuerySnapshot>` with `ValueListenableBuilder<Box>` (Hive's reactive primitive — rebuilds whenever any key in the box changes). Original filter/sort behaviour is preserved: filter by `userId` + `diaryType`, search by title prefix, sort by title descending.

### 4.3 Legacy names retained (cosmetic, no Firebase imports)

These keep their old names but contain no Firebase code:

- Class `FirebaseAuthService` in `lib/login/firebase_auth_implementation/firebase_auth_service.dart` — fully stubbed against `LocalUser`.
- Folder `lib/login/firebase_auth_implementation/` — only contains the stub now.
- Function `logErrorToFirestore(...)` in `lib/utility/error_logger.dart` — logs to `dart:developer` only.

Safe to leave or rename as a follow-up cleanup pass.

### 4.4 Dead environment variables

These `.env` keys are no longer read by the app and can be retired from CI:

`FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_SENDER_ID`, `FIREBASE_PROJECT_ID`, `FIREBASE_AUTH_DOMAIN`, `FIREBASE_STORAGE_BUCKET`, `FIREBASE_MEASUREMENT_ID`, `VAPID_KEY`.

### 4.5 Caveat for existing users

Old users on this build will see an empty diary because their old notes lived in Firestore. If their data needs to be preserved, do a one-time Firestore export and import into the local Hive `'diary'` box before retiring the Firebase project.
