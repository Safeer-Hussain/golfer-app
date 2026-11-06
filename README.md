# Golfer

[![Golfer CI](https://github.com/Safeer-Hussain/golfer/actions/workflows/ci.yml/badge.svg)](https://github.com/Safeer-Hussain/golfer/actions/workflows/ci.yml)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.47.8-02569B?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.13.7-0175C2?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Interactive Multi-Player Golf Flight Manager, Automated Digital Scorecard, GPS Course Rangefinder, and On-Device AI Caddie Ecosystem built in Flutter with strict Feature-First Clean Architecture and MVVM state management.

---

## Architecture Overview

```mermaid
flowchart TD
    subgraph Presentation ["Presentation Layer (MVVM)"]
        UI["Widgets & AdaptiveScaffold"]
        Controllers["Controllers (ChangeNotifier)"]
        UI -->|ListenableBuilder| Controllers
    end

    subgraph Domain ["Domain Layer (Clean Architecture)"]
        UseCases["Use Cases (CalculateScore, CaddieStrategy)"]
        Entities["Entities (CourseEntity, HoleEntity)"]
        Controllers --> UseCases
        UseCases --> Entities
    end

    subgraph Data ["Data Layer (Repositories & Models)"]
        Repos["Repositories (Flight, Scorecard, ClubBag, Clubhouse)"]
        Models["Models (FlightModel, HoleScoreModel, ClubModel)"]
        UseCases --> Repos
        Repos --> Models
    end

    subgraph Core ["Core Infrastructure & Persistence"]
        ServiceLocator["GetIt Service Locator"]
        Prefs["SharedPreferences (Active Flight, Live Hole, Units)"]
        SQLite["sqflite (Completed Rounds, Bag Calibration, Social Posts)"]
        DioMock["Dio Mock Network Interceptor (400-800ms Latency)"]
        ThemeCtrl["ThemeController (Augusta Dark / Fairway Light)"]
        Repos --> Prefs
        Repos --> SQLite
        Repos --> DioMock
    end
```

### Reactive State Flow

```mermaid
sequenceDiagram
    autonumber
    actor Golfer as Flight Captain
    participant ScorecardUI as ScorecardCockpit
    participant Controller as ScorecardController
    participant Repo as ScorecardRepository
    participant Prefs as SharedPreferences
    participant DB as SQLite AppDatabase

    Golfer->>ScorecardUI: Tap + Stroke on Hole 7
    ScorecardUI->>Controller: updateStrokes(playerId, hole=7, delta=+1)
    Controller->>Controller: Mutate HoleScore via .copyWith()
    Controller->>Repo: saveActiveScorecard(activeScorecard)
    Repo->>Prefs: Persist JSON String immediately
    Controller-->>ScorecardUI: notifyListeners()
    ScorecardUI-->>Golfer: Instant UI Re-render (Birdie/Bogey badge & Net HCP)
    Golfer->>ScorecardUI: Tap "Verify & Complete Round"
    ScorecardUI->>Controller: completeRound()
    Controller->>Repo: completeAndArchiveRound()
    Repo->>DB: INSERT into completed_rounds
    Repo->>Prefs: Mark round completed
```

---

## Feature Matrix

| Module | Core Capability | Offline Engine | Architecture Highlight |
|---|---|---|---|
| **Module 1: Flight Lobby** | 1 to 4 multi-player flight setup, custom players, tees | `SharedPreferences` | WHS Slope & Course Handicap auto-calc |
| **Module 2: Scorecard** | Hole 1-18 Cockpit, Gross/Net, Stableford, OUT/IN/TOTAL | `sqflite` + `SharedPreferences` | ASCII Scorecard Export, Leadboard Drawer |
| **Module 3: Rangefinder** | OpenStreetMap canvas, target crosshair, pin distances | `latlong2` Local Geodesics | Live Shot Carry GPS tracker into club bag |
| **Module 4: AI Caddie** | Atmospheric wind vector & elevation playing-distance | On-device strategy engine | Token-by-token streaming with `try-finally` |
| **Module 5: Clubhouse** | Handicap & Scoring charts (`fl_chart`), 14-club bag | `sqflite` | Reactive likes, comment threads, post modal |

---

## Pre-emptive Safety & Architecture Compliance

1. **Android SDK 36 Compatibility**: `compileSdk = 36`, `targetSdk = 36`, and `minSdk = 21` configured in `android/app/build.gradle.kts`.
2. **Impeller Protection**: Vulkan crash protection meta-data enabled in `AndroidManifest.xml` for MediaTek and Mali GPUs.
3. **Zero Hardcoded Colors**: Augusta Emerald Dark and Crisp Fairway Light modes resolved through `Theme.of(context).colorScheme`.
4. **Unique Hero Tags**: Explicit hero tags configured across every FloatingActionButton (`fab_flight_start`, `fab_scorecard_quick_log`, `fab_gps_shot_track`, `fab_clubhouse_post`).
5. **Landscape Viewport Safe**: Master-detail two-pane layout with independent scroll views and compact `NavigationRail` verified on 800x360dp screens.
6. **Zero External Paid APIs**: Fully autonomous local persistence and simulated network telemetry.

---

## Getting Started

### Prerequisites
- Flutter SDK 3.47.8 or higher
- Dart SDK 3.13.7 or higher

### Installation & Run
```bash
# Clone the repository
git clone https://github.com/Safeer-Hussain/golfer.git
cd golfer

# Install dependencies
flutter pub get

# Verify static analysis (0 warnings, 0 errors)
flutter analyze

# Run automated unit and widget test suite
flutter test

# Run application on emulator or connected device
flutter run
```

---

## Clean-Room NDA Disclaimer

This software was developed clean-room from public specifications, USGA/WHS handicap formulas, and OpenStreetMap open-access tiles. No proprietary code, confidential assets, or commercial golf APIs were utilized during development.
