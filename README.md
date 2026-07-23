# MindBlooming — Moshi Moshi

> A Flutter-based digital mental-health companion that guides users through a personalised, clinically-grounded **49-day psychological support programme**.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Key Features](#2-key-features)
3. [Tech Stack](#3-tech-stack)
4. [Architecture & Data Flow](#4-architecture--data-flow)
   - [4.1 Application Bootstrap](#41-application-bootstrap-maindart)
   - [4.2 Navigation & Startup Routing](#42-navigation--startup-routing)
   - [4.3 The Nine Providers (State Layer)](#43-the-nine-providers-state-layer)
   - [4.4 Networking — the Qualtrics Client](#44-networking--the-qualtrics-client-chiamatedart)
   - [4.5 End-to-End Data Flow](#45-end-to-end-data-flow)
5. [Data Persistence (Hive)](#5-data-persistence-hive)
6. [The 49-Day Programme Timeline](#6-the-49-day-programme-timeline)
7. [Clinical Screening & Scoring](#7-clinical-screening--scoring)
8. [Treatment Modules & Recommendation Algorithm](#8-treatment-modules--recommendation-algorithm)
9. [Survey Engine (Qualtrics)](#9-survey-engine-qualtrics)
10. [Notifications](#10-notifications)
11. [In-App Feedback (GitHub)](#11-in-app-feedback-github)
12. [Project Structure](#12-project-structure)
13. [Getting Started](#13-getting-started)
14. [Scripts & Commands](#14-scripts--commands)
15. [Coding Conventions & Linting](#15-coding-conventions--linting)
16. [CI/CD](#16-cicd)
17. [Known Quirks & Gotchas](#17-known-quirks--gotchas)

---

## 1. Overview

**MindBlooming** (internal codename **Moshi Moshi**, package `moshi_moshi`) is a Flutter application developed at the **University of Milan-Bicocca**. It is a self-paced, mobile-first mental-health companion that takes a user from an initial clinical assessment all the way through a structured, multi-week therapeutic journey.

When a new user opens the app, they complete a **baseline clinical screening** built from validated psychometric instruments. The app scores those responses on-device, maps them to severity tiers, and proposes up to **two personalised treatment modules** (for example *Depression & Anxiety* or *Burnout*). From there the user progresses through a fixed **49-day programme**: each week unlocks psychoeducational lessons and exercises, while short **daily** mood check-ins and longer **weekly** screenings track the user's trajectory and render it as charts.

Its primary value proposition is **clinically-grounded, fully personalised mental-health guidance delivered offline-first**. All survey/lesson content is authored in **Qualtrics** and rendered dynamically by a generic survey engine, so the clinical team can revise questionnaires, lessons, and entire treatment paths **without shipping a new build**. The current revision is intentionally **local-first and privacy-light**: user identity is an anonymous on-device UUID (no account, no password), survey content is cached in Hive for offline use, and completed responses are posted directly to the Qualtrics API.

> ### ⚠️ Important note for new joiners — legacy integrations have been removed
> An earlier revision of this app integrated **Firebase** (Auth, Firestore, Cloud Messaging) and **GitLab** feedback. **Those integrations have been removed from the running code.** Concretely:
> - **Authentication** is now an anonymous local UUID (`lib/utility/local_user.dart`); `FirebaseAuthService` is a thin stub that simply returns that UUID.
> - **Feedback** opens a **GitHub** issue (`lib/utility/github_feedback.dart`), not a GitLab one.
> - **Notifications** are **local-only** (`flutter_local_notifications`); there is no remote push.
> - **`logErrorToFirestore()`** (in `lib/utility/error_logger.dart`) despite its name only writes to the local `dart:developer` log.
>
> Treat any lingering `firebase` / `firestore` / `gitlab` symbol names as historical leftovers, not live integrations. This README documents the **current** state of the code.

---

## 2. Key Features

| Feature | Description |
|---|---|
| **Anonymous onboarding** | On first launch an on-device UUID is generated (`LocalUser.ensureUid()`) and stored in Hive — no account or password. The UUID is injected into Qualtrics "UUID" survey blocks so responses can be correlated server-side. |
| **Clinical baseline screening** | A multi-block Qualtrics questionnaire (`MM_baseline_assessment_week1`) covering inclusion criteria, sociodemographics, and six validated instruments. |
| **On-device scoring** | The `Screening` provider scores **BDI-2, STAI, PSQI, C-SSRS, SBI, BPI** locally and maps each to a 0–3 severity tier (Minimo / Lieve / Moderato / Alto). |
| **Personalised modules** | Up to two treatment modules are recommended from the scores; `pensieriautodistruttivi` (self-destructive thoughts) is always force-included as a safety priority. |
| **49-day structured programme** | Daily check-ins, weekly screenings, and weekly exercises are scheduled relative to the programme `start` date and surfaced via an interactive calendar/timeline. |
| **Follow-up assessments** | Additional baseline assessments are auto-scheduled at **day 56 (+8 wk)**, **day 84 (+12 wk)**, and **day 168 (+24 wk)**. |
| **Multi-format exercises** | Lessons, surveys, audio (`just_audio`), YouTube videos (`youtube_player_iframe`), and in-app PDFs (`syncfusion_flutter_pdfviewer` + `printing`). |
| **Personal diary** | Free-text journal persisted in its own Hive `diary` box, shown as a card feed with create/edit/delete. |
| **Safety planning** | A seven-category crisis plan with drag-and-drop reordering (`drag_and_drop_lists`) and an image-backed "reasons for living" category that uploads attachments to Qualtrics. |
| **Progress visualisation** | Sparkline charts (`chart_sparkline`) of daily mood metrics (`m1`, `m2`) and relational-difficulty scores across the 49-day timeline. |
| **Companion plant** | A Rive animation (`assets/plants.riv`) plus selectable plant avatars used as a gamified progress metaphor. |
| **Local reminders** | Daily, weekly, and lesson notifications scheduled in the Europe/Rome timezone, reconciled against OS permission state on every launch. |
| **In-app feedback** | Annotate a screenshot (`feedback` package) → opens a labelled GitHub issue and pushes the PNG to a dedicated branch. |
| **Italian localisation** | UI and content are in Italian (`it_IT`); date formatting initialised at startup. |
| **Offline-first** | Survey definitions and all progress state are cached in Hive; the app degrades gracefully when Qualtrics is unreachable rather than blocking the user. |

---

## 3. Tech Stack

**Language & framework**

| | |
|---|---|
| Language | **Dart** `>= 3.5.3` |
| Framework | **Flutter** (CI/reference toolchain **3.29.1**) |
| App version | `1.3.0` (`pubspec.yaml`) |
| Target platforms | **Android, iOS, macOS, Web** (these platform folders are present; no Windows/Linux desktop) |

**Architecture & state**

| Concern | Library |
|---|---|
| State management | [`provider`](https://pub.dev/packages/provider) `^6.0.5` — nine `ChangeNotifier`s |
| Navigation / dialogs | [`get`](https://pub.dev/packages/get) (GetX) `^4.6.6` — `GetMaterialApp` root + `Get.dialog` |
| Local persistence | [`hive`](https://pub.dev/packages/hive) `^2.2.3` + `hive_flutter` `^1.1.0` |
| Identity | [`uuid`](https://pub.dev/packages/uuid) `^4.1.0` (anonymous local UID) |
| Preferences | `shared_preferences` `^2.1.1` |

**Networking & data**

| Concern | Library |
|---|---|
| Qualtrics REST client | [`http`](https://pub.dev/packages/http) `^1.0.0` |
| GitHub feedback client | [`dio`](https://pub.dev/packages/dio) `^5.8.0` |
| Config | [`flutter_dotenv`](https://pub.dev/packages/flutter_dotenv) `^5.2.1` (`.env` is a bundled asset) |
| JSON / collections | `dart:convert`, `collection` `^1.19.1`, `basics` `^0.10.0` |

**UI, layout & content**

`google_fonts`, `flutter_svg`, `sizer`, `flutter_screenutil`, `flutter_responsive`, `flutter_platform_widgets`, `dropdown_button2`, `card_swiper`, `dotted_line`, `flutter_inner_shadow`, `rounded_loading_button`, `quickalert`, `fluttertoast`, `font_awesome_flutter`, `table_calendar`, `timelines_plus`, `chart_sparkline`, and `flutter_widget_from_html_core` (+ `fwfh_url_launcher`, `fwfh_text_style`, `fwfh_cached_network_image`) for rendering Qualtrics rich HTML content.

**Media**

`just_audio` (audio exercises), `youtube_player_iframe` (video), `syncfusion_flutter_pdfviewer` + `printing` (PDF view/print), `image_network`, `file_picker`.

**Animation**

`rive` `^0.13.20` (`assets/plants.riv`).

**Notifications & platform**

`flutter_local_notifications` `^17.2.4`, `timezone` `^0.9.2`, `permission_handler` `^11.3.1`, `device_info_plus`, `package_info_plus`, `path_provider`.

**Internationalisation**

`intl` `^0.20.2` (`it_IT`), `flutter_localizations`.

**Feedback**

`feedback` `^3.2.0` → GitHub Issues.

**Dev / build**

`flutter_test`, `build_runner` `^2.4.4`, `hive_generator` `^2.0.0`.

---

## 4. Architecture & Data Flow

The app follows a pragmatic **Provider + thin-service** layering — a flavour of **MVVM**. There is *no* formal Clean-Architecture/use-case layering. Instead:

- **View** → `lib/screens/**` (full screens) and `lib/widgets/**` (reusable components).
- **View-model / state** → `lib/providers/**` (nine `ChangeNotifier`s) and `lib/questionHandlers/**` (per-question-type logic).
- **Models** → `lib/models/**` (Hive `@HiveType` classes + adapters + migration).
- **Services / networking** → `lib/chiamate.dart` (the Qualtrics REST client; *chiamate* = "calls") and `lib/utility/**`.

**Where a new developer should look:**

| You want to change… | Go to… |
|---|---|
| A screen's UI | `lib/screens/<feature>/…` |
| A reusable widget | `lib/widgets/…` |
| Business logic / app state | `lib/providers/<name>.dart` |
| How a survey question renders | `lib/widgets/questions/…` + `lib/questionHandlers/…` |
| Clinical scoring | `lib/providers/screening.dart` |
| Qualtrics API calls | `lib/chiamate.dart` |
| Data shapes stored on device | `lib/models/…` |
| Notifications | `lib/utility/notification_api.dart` + `lib/providers/user_settings.dart` |

### 4.1 Application Bootstrap (`main.dart`)

`main()` runs a strict, order-dependent startup sequence:

```text
main()
 1. dotenv.load('.env')                      // env must load before anything reads it
 2. WidgetsFlutterBinding.ensureInitialized()
 3. Hive.initFlutter()
 4. register adapters:
       ExerciseSafeAdapter()                 // custom, defensive — NOT the generated ExerciseAdapter
       DailyScreeningAdapter()  (typeId 0)
       WeeklyScreeningAdapter() (typeId 2)
 5. Intl.defaultLocale = 'it_IT' + initializeDateFormatting()
 6. open Hive box 'moshimoshi'
       → migrateWeeklyExercises(box, 'weeklyExercises')   // normalise legacy Exercise records
 7. open Hive box 'diary'
 8. LocalUser.ensureUid()                     // create/read anonymous UUID
 9. NotificationAPI.init()                    // timezone + Android channels
10. runApp(...)
```

The widget tree wraps the app in feedback + responsive-sizing layers:

```text
BetterFeedback (custom feedback form, draw mode)
└─ Sizer
   └─ Main (MultiProvider: 9 ChangeNotifiers)
      └─ Stack
         ├─ GetMaterialApp(home: LoadingScreen, theme: MindBlooming colorScheme)
         └─ Positioned FloatingActionButton  → BetterFeedback.show() → uploadFeedbackToGitHub()
```

Two **compile-time flags** live at the top of `main.dart`:

| Flag | Default | Effect |
|---|---|---|
| `const bool demo` | `false` | When `true`, skips certain API calls during development. |
| `const bool canSend` | `true` | Gates submission of answers to Qualtrics (also mirrored into `UserSettings.canSend`, persisted in Hive). |

### 4.2 Navigation & Startup Routing

Two navigation systems coexist by design:

- **`Navigator`** (standard Flutter) handles *all* screen transitions via `push` / `pushReplacement`.
- **`Get.dialog()`** (GetX) is used *only* for in-app pop-up dialogs — which is why the root is `GetMaterialApp`.

`LoadingScreen` is the entry route. It ensures the local UUID and calls `initQuestions(context, demo, canSend)` (in `chiamate.dart`), which initialises every provider from Hive, fetches the baseline survey from Qualtrics if not cached, and returns the next destination string:

```text
LoadingScreen._loadData()
 └─ initQuestions() returns:
      "Home"      → MainScreen
      "Screening" → ( doneBlocks contains "MM_baseline_assessment_week1"
                       ? ScreeningScreen        // resume an in-progress baseline
                       : OnBoard )              // brand-new user
      (anything else / failure) → NoInternetScreen
```

The `"Home"` vs `"Screening"` decision is:

```dart
next = (progress.doneSurveys.contains("MM_baseline_assessment_week1")
        && moduli.moduli.length == 2)
     ? "Home" : "Screening";
```

i.e. you reach Home **only** once the baseline is done **and** exactly two modules are active.

`MainScreen` is a five-tab shell driven by a single `_selectedIndex` (custom `BottomNavbar`, not a `BottomNavigationBar`):

| Index | Tab | Screen |
|---|---|---|
| 0 | Homepage | `HomepageScreen` (dashboard: calendar, assessment summary, charts, testimonials) |
| 1 | Exercises | `ExercisesScreen` |
| 2 | Safety Planning | `SafetyPlanningScreen` |
| 3 | Diary | `DiaryScreen` |
| 4 | Settings | `SettingsScreen` |

### 4.3 The Nine Providers (State Layer)

All app state lives in `ChangeNotifier`s registered in `main.dart`. **Most expose an `async init()`** that opens the `"MoshiMoshi"` Hive box and hydrates fields — called explicitly by `initQuestions()` / the screens, *not* in the constructor, because Hive opens asynchronously.

| Provider | Hive keys it owns | Key responsibilities & notable API |
|---|---|---|
| **`Answers`** | `answers`, `alreadySent` | The answer store, keyed `surveyID → {questionID → value}`. `addAnswer/removeAnswer/getAnswer/hasAnswer*`, plus per-type helpers (`hasAnswerChoice`, `hasAllAnswers`, `hasAnswerPGR`). Submits via **`sendAnswers()`** (`POST /surveys/{id}/responses`) and **`sendAnswersWithAttachment()`** (multipart upload for the "reasons for living" images, mapped to `QID3`). Tracks "wrong" (invalid) question IDs for inline error UI. |
| **`Questions`** | Hive-persisted survey cache | Loads/caches Qualtrics survey JSON (`readFromLocal/writeToLocal/areQuestionsSaved`). Holds `names`, `images`, `profileAbout`, `profileCredits`. Exposes `surveys`, `blocks`, `questions`, `surveyID(name)` / `surveyName(id)`. Evaluates **skip / display logic** (`isSkip`, `_checkSkip`, numeric/text comparators) for `DisplayLogic` & `InPageDisplayLogic` with AND/OR. |
| **`Validation`** | — | Applies **40+ validation rule types** against answers (see [§9](#9-survey-engine-qualtrics)). |
| **`Screening`** | `patologie_selezionate`, `sesso`, `anni`, `terapia` | Scores the six clinical instruments and builds the module recommendation (`scelte` = forced, `daScegliere` = user-choosable). Entry point: `addDone(blockName, ctx)` → `evaluate()` → per-instrument scorer → `doneScreening()`. |
| **`Moduli`** | (module metadata) | The six treatment modules: `prettyName` labels + `descrizioni` (per-week curricula). Also maps the `baseline_assessment*` pseudo-modules to "Screening". |
| **`Progress`** | `start`, `doneBlocks`, `doneSurveys`, `dailyScreenings`, `weeklyScreenings`, `weeklyExercises`, `dailym1`, `dailym2`, `dailyDiffRel` | The heart of the 49-day timeline. `initEvents()` materialises all daily/weekly/exercise events relative to `start`. Tracks completion (`addDoneBlock`, `addDoneSurvey`, `setExerciseDone`, `setDailyDone`, `setWeeklyDone`) and the three mood metric arrays (49 slots, sentinel `-10.0` = "no data"). Helpers: `getFirstUndoneEx`, `undoneEx(week)`, `isReadyForWeek6`, `isPanoramicaEmpty`. |
| **`UserSettings`** | `plant`, `canSend`, `demo`, `debug`, `notifica_giornaliera`, `notifica_settimanale`, `notifica_esercizi`, `hour`/`minute`, `settimanale_*`, `lezioni_*` | Notification preferences (daily / weekly / lessons), schedule times, companion-plant selection, and the **debug** flag. On `init()` it reconciles notification flags against actual OS permissions and cleans up legacy notification IDs. |
| **`Calendar`** | — | Lightweight UI state: `today` + `focusedDay` for the calendar widgets. |
| **`SafetyPlanning`** | — | Static metadata (`prettyName`, `descrizioni`) for the seven safety-plan categories. |

### 4.4 Networking — the Qualtrics Client (`chiamate.dart`)

All survey traffic goes through plain top-level functions in `chiamate.dart`, authenticating with the `X-API-TOKEN` header (`QUALTRICS_TOKEN`) against `QUALTRICS_URL`:

| Function | Purpose |
|---|---|
| `getSurveys()` | Paginates `GET /API/v3/surveys` to list all surveys (name → id). |
| `_buildSurveyIndex()` | Caches that name→id map in-memory for the session. |
| `getBlocksQuestions(id, …)` | `GET /survey-definitions/{id}`; strips Trash blocks, resolves the **UUID block** (writes the local UID into the fake `_TEXT` question via `Answers`), and orders blocks by `SurveyFlow`. |
| `_fetchAndProcessSurvey(name, id, …)` | Downloads one survey and registers its blocks/questions in the `Questions` provider (skipping `Page Break` and `Timing` questions). |
| `_loadSettings(id, …)` | Parses the `MM_settings` survey for `survey_names`, profile texts, and exercise images. |
| `initQuestions(ctx, demo, canSend)` | Startup orchestrator: inits providers, downloads `settings` + baseline on first run (else reads from Hive and force-refreshes `MM_testimonianze`), returns `"Home"`/`"Screening"`. **Fails soft** — if Qualtrics is unreachable, it falls through to navigation using cached Hive data instead of blocking. |
| `loadModuleSurveys(ctx, m1, m2)` | After module selection, downloads **only** the surveys required for the chosen pair (see `getRequiredSurveyNames`). |
| `getRequiredSurveyNames(m1, m2)` | Computes the exact survey-name set: dailies `w1..7 d1..7`, weeklies `w2..7`, exercises `week1..6`, the follow-up baselines (`_8/_12/_24`), plus a fixed list of common safety-planning/testimonial/diary surveys. |
| `getDiaryContent(surveyID)` | Kicks off a Qualtrics **export-responses** job, polls `percentComplete` (≤60 attempts, 1 s apart), downloads the file, and extracts the current user's diary entries by matching the UUID in `QID6_TEXT`. |
| `verifyAndSyncQuestions(ctx)` | Reconciles local cache against remote, adding only missing surveys/blocks/questions. |

> The first ~650 lines of `chiamate.dart` are a **commented-out previous implementation** kept for reference; the live code starts at the second `import` block.

### 4.5 End-to-End Data Flow

```text
        ┌─────────────────────── Qualtrics REST API ───────────────────────┐
        │  GET /surveys · GET /survey-definitions/{id}                      │
        │  POST /surveys/{id}/responses · export-responses (diary)          │
        └───────────────▲───────────────────────────────────┬──────────────┘
                        │ http (X-API-TOKEN)                 │ POST answers
                        │                                    │
                 chiamate.dart ─────────► Questions / Answers / Progress / Screening
                        │                          │  (ChangeNotifier state)
                        ▼                          ▼
        ┌─────────────── Hive (on-device, offline cache) ───────────────────┐
        │  'moshimoshi'  → localUid, weeklyExercises (migration), ragionidivita│
        │  'MoshiMoshi'  → answers, doneBlocks, dailyScreenings, dailym1…    │
        │  'diary'       → journal entries                                   │
        └───────────────────────────────────────────────────────────────────┘
                        │ Provider.of / Consumer
                        ▼
                 Screens & Widgets (lib/screens, lib/widgets)
```

Completed responses are sent to **Qualtrics only**; there is no app-owned remote database. Hive is the single source of truth for offline reads.

---

## 5. Data Persistence (Hive)

### Registered type adapters

| Type | TypeId | File | Fields | Notes |
|---|---|---|---|---|
| `DailyScreening` | **0** | `models/daily_screening.dart` | `blockName, surveyName, modulo, index, done` | Generated adapter. |
| `Exercise` | **1** | `models/exercise_safe_adapter.dart` | `surveyName(6), modulo(7), done(8), assessment(13), tappa(14)` | **Custom defensive adapter** registered instead of the generated `ExerciseAdapter`. Reads tolerate missing/typed-differently fields and supply safe defaults — protecting against records written by older app versions. |
| `WeeklyScreening` | **2** | `models/weekly_screening.dart` | `blockName(9), modulo(11), surveyName(10), done(12)` | Generated adapter. |

> Generated `*.g.dart` files exist for all three models; only `DailyScreening` and `WeeklyScreening` register their generated adapters. The `Exercise` model is deliberately handled by `ExerciseSafeAdapter`. Regenerate with `build_runner` after editing any `@HiveType` model.

### Startup migration

`migrateWeeklyExercises(box, 'weeklyExercises')` runs **before** any provider reads Hive. It walks the stored `Map<date, List<Exercise>>`, infers missing `assessment`/`tappa` values for legacy `baseline_assessment` records from the `surveyName` (`_8`→`first`, `_12`→`second`, `_24`→`third`), and rewrites the map only if something changed. Failures are logged, never thrown.

### The three boxes (mind the capitalisation!)

| Box | Opened in | Holds |
|---|---|---|
| **`moshimoshi`** (lowercase) | `main.dart` | `localUid` (anonymous identity), the `weeklyExercises` map targeted by migration, and `ragionidivita` (safety-plan images). |
| **`MoshiMoshi`** (capitalised) | each provider's `init()` | All provider state: `answers`, `doneBlocks`, `dailyScreenings`, `dailym1/2`, settings, screening results, … |
| **`diary`** | `main.dart` | Personal diary entries. |

> `"moshimoshi"` and `"MoshiMoshi"` are **two distinct boxes**. This is an established quirk of the codebase, not a bug to "fix" casually — code on both sides depends on the exact names.

---

## 6. The 49-Day Programme Timeline

`Progress.initEvents(modulo1, modulo2)` materialises the entire schedule relative to the persisted `start` date (always normalised to midnight). Dates are keyed `yyyy-MM-dd`.

| Event type | Count | Schedule | Survey-name pattern |
|---|---|---|---|
| **Daily screenings** | 49 (7 weeks × 7 days) | day `i` = `start + i` | `MM_{m1}_{m2}_daily_w{week}_d{day}` |
| **Weekly screenings** | weeks 2–7, 2 per week | `start + 7·(week-1)` | `MM_{m1}_weekly_w{n}`, `MM_{m2}_weekly_w{n}` |
| **Weekly exercises** | weeks 1–6, 2 per week | `start + 7·i` | `MM_{m1}_week{n}`, `MM_{m2}_week{n}` |
| **Follow-up baseline +8 wk** | 1 | `start + 56` | `MM_baseline_assessment_8` (`tappa: first`) |
| **Follow-up baseline +12 wk** | 1 | `start + 84` | `MM_baseline_assessment_12` (`tappa: second`) |
| **Follow-up baseline +24 wk** | 1 | `start + 168` | `MM_baseline_assessment_24` (`tappa: third`) |

Three parallel 49-slot `double` arrays track mood over time, using **`-10.0` as the "no data" sentinel**:

- `dailym1`, `dailym2` — daily mood metrics charted on the dashboard.
- `dailyDiffRel` — relational-difficulty score (for the `difficoltarelazionali` module).

`isPanoramicaEmpty()` returns `true` while every slot is still the sentinel (drives the "no data yet" empty state).

---

## 7. Clinical Screening & Scoring

After the user completes a baseline block, `Screening.addDone(blockName, ctx)` calls `evaluate()`, which dispatches on `blockName` to the matching scorer. Each scorer reads the raw Qualtrics answers + question definitions and writes a **0–3 severity tier** into the `_patologie` map (persisted as `patologie_selezionate`).

| Block | Instrument | Scoring summary | Output key & tiers |
|---|---|---|---|
| `criteri_di_inclusione` | Inclusion criteria | Parses age (eligible 18–29) and whether currently in therapy. | sets `anni`, `terapia` |
| `domande_sociodemografiche` | Demographics | Stores `sesso` (used by gender-specific SBI cut-offs). | sets `sesso` |
| `screening_depressione` | **BDI-2** | Sums per-item first-digit scores; flags suicide item (≥1 ⇒ self-destructive=Alto), agitation, sleep. | `depressione`: ≤13→0, ≤19→1, ≤28→2, ≤63→3 |
| `screening_ansia` | **STAI** | State (items ≤20) vs Trait (items >20); 19 reverse-coded items (`5 − value`); takes the max subscale. | `ansia`: <40→0, <50→1, <60→2, ≤80→3 |
| `screening_sonno` | **PSQI** | Computes the 7 component scores (latency, duration, efficiency, disturbances, quality, medication, daytime dysfunction) and sums them. | `sonno`: <5→0, <10→1, <15→2, else→3 |
| `screening_pensieri_autodistruttivi` | **C-SSRS** | If any weighted item (indices `2,3,4,5,6,10,11,12,13`) = "Sì" ⇒ Alto. | `pensieriautodistruttivi`: 3 or 0 |
| `screening_burnout` | **SBI** | Computes Exhaustion/Cynicism/Inadequacy subscale means; compares against **gender-specific** thresholds (uomo / donna / other). | `burnout`: 0–3 |
| `screening_sintomi_dolorosi` | **BPI** | Severity (mean of 4 items) and Interference (mean of 7 items); takes the max, rounded up. | `dolorecronico`: <5→0, <7→1, <9→2, else→3 |

> These algorithms encode validated clinical cut-offs and are sensitive to the exact Qualtrics question ordering and choice text. **Do not refactor `screening.dart` without clinical sign-off** — the scorers rely on positional indices (`questions.values.elementAt(i)`) and on parsing the leading digit / display text of choices.

---

## 8. Treatment Modules & Recommendation Algorithm

The six treatment modules (`lib/providers/moduli.dart`), each ~5 weeks of content:

| Module key | Italian label |
|---|---|
| `depressioneansia` | Depressione e Ansia |
| `pensieriautodistruttivi` | Pensieri Autodistruttivi |
| `burnout` | Burnout e Stress Lavoro Correlato |
| `dolorecronico` | Dolore Cronico |
| `difficoltarelazionali` | Difficoltà Relazionali |
| `stiledivita` | Difficoltà nello Stile di Vita |

Plus the `baseline_assessment` pseudo-module (and `_8/_12/_24` follow-ups) used by the screening flow.

**Recommendation logic** (`Screening.doneScreening()`):

1. Group scored pathologies by tier — `alto` (3), `moderato` (2), `lieve` (1).
2. Build `daScegliere` (modules the user may choose) from those tiers, then backfill remaining `priority` modules at tier "Minimo".
3. **Force-include `pensieriautodistruttivi` as "Alto" in `scelte`** — it is always added as a safety priority, independent of its score.
4. The results screen lets the user pick the second module from `daScegliere`, ending with exactly two active modules → `Progress.initEvents(m1, m2)` + `loadModuleSurveys(m1, m2)`.

> The `priority` order is `burnout → depressioneansia → difficoltarelazionali → dolorecronico → stiledivita`. An older selection algorithm is preserved as comments for reference.

---

## 9. Survey Engine (Qualtrics)

The app treats Qualtrics as a headless CMS. Survey JSON (Qualtrics export format: `blocks → questions` with `QuestionType` / `Selector` / `SubSelector`) is fetched on demand and cached in Hive so launches are offline-capable. Each survey is downloaded only when needed (`loadModuleSurveys`).

### Question types

There are **ten** question-type handlers in `lib/questionHandlers/` (re-exported via `export_handlers.dart`), each paired with a render widget in `lib/widgets/questions/`:

| Handler | Question type |
|---|---|
| `multichoice_handler.dart` | Multiple Choice |
| `text_entry_handler.dart` | Text Entry |
| `description_box_handler.dart` | Descriptive / read-only content (`DB`) |
| `matrix_handler.dart` | Matrix (multiple sub-types) |
| `slider_handler.dart` | Slider |
| `rank_order_handler.dart` | Rank Order |
| `side_by_side_handler.dart` | Side-by-Side |
| `pick_group_rank_handler.dart` | Pick, Group & Rank |
| `constant_sum_handler.dart` | Constant Sum |
| `file_uploader_handler.dart` | File Upload (`StoredImage` model + multipart upload) |

### Display / skip logic

The `Questions` provider evaluates Qualtrics `DisplayLogic` and `InPageDisplayLogic` client-side (`isSkip`, `_checkSkip`, `_anyCompositeMatch`, `_compareNumeric`, `_compareText`, `_matchesSelected`, `_countSelections`) with full AND/OR composition, so questions show/hide reactively as the user answers.

### Validation rule catalogue

The `Validation` provider supports **40+ rule keys** parsed from each question's validation settings. The full set includes:

```
whitelist · matrixWhitelist · blacklist · matrixBlacklist
minChoices · maxChoices · minChar · totalChar
equal · equalIgnore · notEqual · notEqualIgnore
equalLength · equalLengthMatrix · notEqualLength · notEqualLengthMatrix
greaterThan · greaterThanEqual · greaterThanLength · greaterThanLengthMatrix
greaterThanEqualLength · greaterThanEqualLengthMatrix
lessThan · lessThanEqual · lessThanLength · lessThanLengthMatrix
lessThanEqualLength · lessThanEqualLengthMatrix
empty · notEmpty · contains · containsIgnore · notContains · notContainsIgnore · regex …
```

Invalid questions register their IDs with `Answers.addWrong()` so the corresponding widget can render an inline error.

---

## 10. Notifications

**Local only** — configured in `lib/utility/notification_api.dart` (`flutter_local_notifications` + `timezone`, pinned to **Europe/Rome**). There is no remote/push channel.

Three Android notification channels are created at init:

| Channel enum | Android channel id | Purpose |
|---|---|---|
| `NotificationChannel.daily` | `mind_blooming_daily` | Daily-screening reminder |
| `NotificationChannel.weekly` | `mind_blooming_weekly` | Weekly-screening reminder |
| `NotificationChannel.lessons` | `mind_blooming_lessons` | Lessons/exercises reminder |

Scheduling is orchestrated by `UserSettings`:

- **Daily** — `scheduleDaily()` at the user's `timeOfDay` (default 08:00), notification id `0`.
- **Weekly** & **Lessons** — `scheduleWeeklyOccurrences()` schedules `_weeklyOccurrencesAhead = 8` future occurrences from base ids `100` (weekly) and `200` (lessons), at a user-chosen weekday/hour/minute.
- On launch, `_reconcileNotificationFlagsWithOs()` re-checks OS permission: if the user revoked notifications, the stored flags are turned back off; legacy ids `1`/`2` are cancelled once.

---

## 11. In-App Feedback (GitHub)

A floating action button (rendered in the `Stack` in `main.dart`) opens the `feedback` package's draw-mode form. On submit, `uploadFeedbackToGitHub()` (`lib/utility/github_feedback.dart`, using `dio`):

1. Ensures a dedicated **`feedback-attachments`** branch exists (creates it from the repo's default branch on first use).
2. Pushes the annotated screenshot PNG to `screenshots/feedback-<timestamp>.png` via the Contents API.
3. Opens an **issue** on `GITHUB_REPO_OWNER/GITHUB_REPO_NAME` with the user's text, an inline `![screenshot](…)` link, and a `feedback` label.

The PAT in `GITHUB_API_TOKEN` needs **`Issues: write`** and **`Contents: write`** on that repo.

---

## 12. Project Structure

```text
moshimoshi/
├── lib/
│   ├── main.dart                       # Entry point & bootstrap sequence
│   ├── chiamate.dart                   # Qualtrics REST client ("calls")
│   ├── utility.dart                    # Shared content/string helpers
│   ├── login/
│   │   ├── pages/                      # welcome / login / register / loading screens
│   │   ├── widget/                     # form fields, toasts
│   │   └── firebase_auth_implementation/
│   │       └── firebase_auth_service.dart   # local-UUID stub (legacy name)
│   ├── models/
│   │   ├── daily_screening.dart  (+ .g.dart)
│   │   ├── weekly_screening.dart (+ .g.dart)
│   │   ├── exercise.dart         (+ .g.dart)
│   │   ├── exercise_safe_adapter.dart  # defensive Hive adapter actually used
│   │   └── exercise_migration.dart     # startup normalisation
│   ├── providers/                      # 9 ChangeNotifiers (see §4.3)
│   │   ├── answers.dart  questions.dart  validation.dart  screening.dart
│   │   ├── moduli.dart   progress.dart   user_settings.dart
│   │   └── calendar.dart safety_planning.dart
│   ├── questionHandlers/               # 10 per-type handlers + export_handlers.dart
│   ├── widgets/
│   │   ├── questions/                  # per-type render widgets
│   │   ├── bottom_navbar/              # custom tab bar
│   │   └── …                           # splash, custom feedback form, shared UI
│   ├── screens/
│   │   ├── main_screen/                # 5-tab shell + features
│   │   │   ├── homepage_screen/        #   dashboard, calendar, charts, testimonials
│   │   │   ├── exercises_screen/       #   weekly exercise cards
│   │   │   ├── diary_screen/           #   journal list / edit / save
│   │   │   ├── safety_planning_screen/ #   7-category crisis plan
│   │   │   └── settings_screen/        #   account, notifiche, risorse, tutorial, debug
│   │   ├── questions_screen/           # generic survey renderer + appbar
│   │   ├── results_screen/             # screening results + module suggestions
│   │   ├── blocks_screen/              # block navigation within a survey
│   │   ├── before_finishing_screen/   # pre-completion prompts
│   │   ├── screening_screen.dart  on_board.dart  presentation_screen.dart
│   │   ├── congratulation_screen.dart  no_internet_screen.dart
│   │   └── weekly_screening_screen/ …
│   └── utility/
│       ├── local_user.dart             # anonymous UUID identity
│       ├── notification_api.dart       # local notification scheduling
│       ├── github_feedback.dart        # feedback → GitHub issue
│       ├── error_logger.dart           # local dev logging (legacy name)
│       ├── compute_progress.dart  progress.dart  date_key_custom_week_ext.dart
│       ├── mindblooming_color_scheme.dart  mindblooming_text_style.dart
│       └── error_alert.dart
├── assets/                             # images, SVGs, plants.riv, .env (asset-loaded)
├── android/ · ios/ · macos/ · web/     # supported platform projects
├── test/                               # widget_test.dart (default scaffold only — see §14)
├── pubspec.yaml
├── analysis_options.yaml
├── .gitlab-ci.yml                      # web build + GitLab Pages deploy
└── CLAUDE.md                           # repo guidance (note: partially predates the de-Firebase refactor)
```

---

## 13. Getting Started

### Prerequisites

- **Flutter SDK** — the CI/reference image is `ghcr.io/cirruslabs/flutter:3.29.1`; use a matching **3.29.x** toolchain. Dart `>= 3.5.3` ships with it.
- **Android**: Android Studio + Android SDK + an emulator or physical device; **JDK 17** (required by recent Android Gradle Plugin).
- **iOS / macOS** (macOS hosts only): **Xcode** + **CocoaPods**.
- **Web**: Chrome (for `flutter run -d chrome`).
- A **`.env`** file in the project root — it is declared as a Flutter **asset** in `pubspec.yaml`, so the app **will not start without it**.

> Supported platform folders in the repo: **Android, iOS, macOS, Web**. (No Windows/Linux desktop targets.)

### Installation

```bash
# 1. Clone
git clone <repository-url>
cd moshimoshi

# 2. Install dependencies
flutter pub get

# 3. Create the .env file in the project root (see keys below)
#    macOS/Linux:        touch .env
#    Windows PowerShell: New-Item -ItemType File .env

# 4. (Only if you modified a @HiveType model) regenerate Hive adapters
flutter packages pub run build_runner build --delete-conflicting-outputs
```

#### Environment variables (`.env`)

These keys are **read directly by the code** and are required for the corresponding features:

```env
# Qualtrics survey backend — REQUIRED (the app fetches all content from here)
QUALTRICS_URL=your-instance.qualtrics.com      # host only — no scheme, no path
QUALTRICS_TOKEN=your_qualtrics_api_token

# In-app feedback → opens a GitHub issue + uploads the screenshot
GITHUB_REPO_OWNER=your_org_or_user
GITHUB_REPO_NAME=your_repo
GITHUB_API_TOKEN=ghp_xxx                        # PAT: Issues:write + Contents:write

# Unlocks the hidden debug settings screen
ADMIN_DEBUG_PASSWORD=your_debug_password
```

> The historical CI config and `CLAUDE.md` also list `FIREBASE_*` and `VAPID_KEY`. These are **no longer referenced by the application code** (Firebase was removed) and are not needed to build or run the current app. The `.env` file is **gitignored**; CI injects it from pipeline secrets.

### Running the App

```bash
# Pick a running emulator/simulator or connected device, then:
flutter run

# Target a specific platform/device:
flutter run -d chrome            # Web
flutter run -d emulator-5554     # a specific Android emulator (see `flutter devices`)
flutter run -d <ios-simulator>   # iOS Simulator (macOS only)
flutter run -d macos             # macOS desktop
```

> **Developer toggles** (`main.dart`): set `demo = true` to skip some API calls, or `canSend = false` to stop answers being submitted to Qualtrics during testing.

---

## 14. Scripts & Commands

| Command | Purpose |
|---|---|
| `flutter pub get` | Install / resolve dependencies. |
| `flutter run` | Run on a connected device / emulator / simulator. |
| `flutter run -d chrome` | Run the web build locally. |
| `flutter analyze` | Static analysis / linting (config in `analysis_options.yaml`). |
| `flutter test` | Run the test suite — **see note below.** |
| `flutter packages pub run build_runner build --delete-conflicting-outputs` | Regenerate Hive type adapters after editing a `@HiveType` model. |
| `flutter build web --release --source-maps` | Production web build (used by CI). |
| `flutter build apk --release` | Android APK. |
| `flutter build appbundle --release` | Android App Bundle (Play Store). |
| `flutter build ios --release` | iOS build (macOS + Xcode). |
| `flutter build macos --release` | macOS desktop build. |

> **⚠️ Automated testing is not yet configured.** `test/` contains only the default scaffolded `widget_test.dart` — a "counter" smoke test that does **not** match this app and would not meaningfully pass (it even pumps `Main()` directly, bypassing the bootstrap sequence). Treat `flutter test` as a placeholder until a real suite is written. The GitLab pipeline has **no test stage**.

---

## 15. Coding Conventions & Linting

Run `flutter analyze` before committing. `analysis_options.yaml` enables a curated lint set, notably:

- **`prefer_relative_imports`** — always use relative paths inside `lib/` (the codebase uses `import './providers/…'`, not package imports).
- **`avoid_print`** — use `dart:developer`'s `log()` instead of `print()`.
- **`use_build_context_synchronously`** — guard `BuildContext` use across `async` gaps (the code uses `if (!mounted) return;` / `ctx.mounted` checks).
- Plus `prefer_const_constructors`, `prefer_final_locals`, `always_declare_return_types`, `curly_braces_in_flow_control_structures`, `unnecessary_*`, and more.

> The previous **`dart_code_metrics`** analyzer plugin was **removed** (its rules are kept as comments in `analysis_options.yaml`) because the analyzer-plugin system was dropped in Dart 3.4 / Flutter 3.22. To re-enforce those rules, migrate to `dart_code_metrics` v5+ CLI or `custom_lint`.

---

## 16. CI/CD

CI is defined in `.gitlab-ci.yml` using the `ghcr.io/cirruslabs/flutter:3.29.1` image:

| Stage | Job | Trigger | Action |
|---|---|---|---|
| `build` | `build_and_test_web_app` | every push | Injects `.env` from CI/CD variables (`before_script`), then `flutter build web --release --source-maps` → artifacts in `build/web`. |
| `deploy` | `pages` | `main` only | Copies `build/web` → `public/` for **GitLab Pages**. |

There is **no test stage**. The pipeline still echoes legacy `FIREBASE_*` / `VAPID_KEY` / `GITLAB_*` variables into `.env` that the current code no longer consumes — these can be pruned when convenient.

---

## 17. Known Quirks & Gotchas

A short list of things that surprise new contributors:

1. **Two Hive boxes differing only by case** — `"moshimoshi"` vs `"MoshiMoshi"`. Both are real and both are used; don't "normalise" them.
2. **Firebase/GitLab names are dead** — `FirebaseAuthService`, `logErrorToFirestore`, `firebase_auth_implementation/`. They no longer talk to any backend. (See the note in [§1](#1-overview).)
3. **`-10.0` is a sentinel**, not real data, in the `dailym1/m2/DiffRel` arrays — it means "no entry yet".
4. **`pensieriautodistruttivi` is always force-selected** as a module, regardless of score, for safety reasons.
5. **Scoring is position-sensitive** — `screening.dart` indexes questions by order and parses choice display text; treat it as clinically frozen.
6. **`Exercise` uses a hand-written adapter** (`ExerciseSafeAdapter`), *not* the generated one — keep field numbers (6,7,8,13,14) stable.
7. **`chiamate.dart` opens with ~650 lines of commented-out legacy code**; the live implementation is the second half of the file.
8. **`initQuestions` fails soft** — if Qualtrics is unreachable on a returning user, the app proceeds from Hive instead of showing `NoInternetScreen`.
9. **`CLAUDE.md` predates the de-Firebase refactor** in places; trust the code (and this README) over it.
```
