# Golfer Product Requirements Document (PRD)

## 1. Executive Summary
**Golfer** is an interactive multi-player golf flight management system, automated digital scorecard, GPS course rangefinder, and on-device AI caddie built in Flutter. The platform enables tournament players, flight captains, and recreational golfers to manage multi-player flights, track hole-by-hole scores, obtain real-time GPS yardages, evaluate on-device shot strategy, calibrate club distances, and share verified round milestones within a social clubhouse feed.

---

## 2. Target Audience & Personas
- **Tournament Flight Captains**: Managing 1 to 4 players simultaneously with real-time gross/net leaderboard calculations, handicap slope indices, and Stableford point tallies.
- **Competitive Golfers**: Seeking on-course target crosshairs, elevation/wind adjustment vectors, and shot distance tracking logged directly into club calibration databases.
- **Club Members**: Interacting with clubhouse round feeds, liking milestone achievements, reviewing handicap trends, and fine-tuning their 14-club bag carry/total yardages.

---

## 3. Core Production Modules

### Module 1: Interactive Multi-Player Flight Selection & Round Setup
- **Interactive Flight Lobby**: Supports 1 to 4 simultaneous players.
- **Default Seeded Golfer**: Safeer Hussain (Handicap Index: 4.2).
- **Club Member Roster & Custom Players**: Quick selection of active members (M. Khan, Ali Tariq, Zayd Karim) or custom player creation with inline handicap (0.0 to 54.0) and tee box validation.
- **Game Formats**: Stroke Play (Gross/Net), Stableford Points, Match Play, and 4-Player Scramble.
- **Championship Courses & Tee Boxes**:
  - Lahore Garrison Golf & Country Club (Par 72, 7,120 yds)
  - Royal Palm Golf & Country Club (Par 72, 6,850 yds)
  - Emerald Links Golf Resort (Par 71, 6,590 yds)
  - Tee Boxes: Championship Black (Slope 138), Tournament Blue (Slope 132), Member White (Slope 125), Forward Red (Slope 118).
- **Automated WHS Math**: Computes Course Handicap via `(Handicap Index * Slope / 113) + (Course Rating - Par)`.
- **1-Tap Tee Off / Resume Active Round**: Persists flight state into `SharedPreferences` via `GetIt`.

### Module 2: Automated 18-Hole Digital Scorecard & Live Leaderboard Matrix
- **Hole-by-Hole Scoring Cockpit**: Switcher for Holes 1 through 18 with Par, Stroke Index, and Yardage.
- **Player Scoring Rows**:
  - Stroke steppers (`-` and `+`) with visual Eagle/Birdie circles and Bogey squares.
  - Putt counter stepper.
  - Fairways in Regulation (FIR: Left, Center, Right, Miss).
  - Greens in Regulation (GIR) and Bunker/Penalty hazard toggles.
- **Real-Time Automated Calculations**:
  - Gross Score vs Par (`E`, `-2`, `+3`).
  - Net Score (adjusted for hole stroke index and course handicap).
  - Stableford points auto-calculator (Albatross: 5, Eagle: 4, Birdie: 3, Par: 2, Bogey: 1, Double+: 0).
- **Round Matrix Tabs**: Instant Front 9 (`OUT`), Back 9 (`IN`), and 18-Hole (`TOTAL`) summary grid.
- **Flight Leaderboard Drawer**: Real-time rank sorting by net/gross score.
- **End-of-Round Verification & Sharing**:
  - Archive completed round to SQLite (`completed_rounds`).
  - Copy Formatted ASCII Scorecard to Clipboard.
  - Post Round to Clubhouse Feed.
  - Export Round Telemetry (JSON format).

### Module 3: GPS Course Rangefinder, Target Crosshair & Shot Tracker
- **OpenStreetMap Integration**: Powered by `flutter_map` with zero billing keys required.
- **Authentic Locus Vectors**: Mapped GPS coordinates for Lahore Garrison (Tee boxes, fairway doglegs, sand traps, water hazards, green pins).
- **Interactive Target Crosshair**: Tap anywhere on the course canvas to show:
  - Tee-to-Target distance (Yards or Meters).
  - Target-to-Pin center distance.
  - Front and Back green distances.
  - "Plays Like" distance (adjusted for wind headwind/tailwind and elevation change).
- **Live Shot Tracker**:
  - Measures shot carry distance in real time.
  - Logs club used directly into player's 14-club bag statistics in SQLite.

### Module 4: On-Device AI Golf Caddie & Club Strategy Engine
- **Dedicated AI Caddie Workspace**: Reads current hole par, yardage, wind direction/speed, elevation, hazards, and player's calibrated 14-club carry yardages.
- **Token-by-Token Streaming Engine**: Realistic streaming simulation with transient calculation indicator strictly guarded in `try ... finally`.
- **One-Tap Prompt Shortcuts**:
  - "Recommend Club for Current Hole & Wind"
  - "Analyze My Front-9 Putting & GIR Trends"
  - "Suggest Safe Layup Strategy"
  - "Fix My Driver Slice Tendency"
- **Zero-Emoji Technical Advice**: Pure technical golf mechanics (dispersion cone, aiming bias, dynamic loft, target line safety).

### Module 5: Clubhouse Social Feed, Handicap Analytics & My Bag Calibrator
- **Handicap & Performance Analytics**:
  - Full-width `fl_chart` Scoring Average and Handicap Index progression line chart (`width: double.infinity`, `reservedSize: 0`).
  - Performance breakdown progress meters: FIR %, GIR %, Putts per Round, Scrambling %.
- **14-Club Bag Calibrator**:
  - Interactive list of 14 clubs (Driver through Putter).
  - Editable carry and total yardage sliders persisted to SQLite.
  - Displays tracked live shot count per club.
- **Clubhouse Social Feed**:
  - Community round shares and tournament notices.
  - Reactive Like button (instant heart fill and count increment).
  - Comment modal bottom sheet backed by SQLite.
  - Share post to clipboard.
  - "+ Post Round Milestone" FAB with inline form validation.

---

## 4. Architectural Standards & Design Patterns
- **Clean Architecture + MVVM**: Strict separation across `core/`, `data/`, `domain/`, and `presentation/`.
- **State Management**: `GetIt` service locator managing reactive `ChangeNotifier` stores bound to `ListenableBuilder`.
- **Persistence Strategy**:
  - Active in-progress round and unit preferences: `SharedPreferences`.
  - Historical rounds, club bag calibrations, and social feed: `sqflite`.
- **Zero Hardcoded Colors**: Augusta Emerald Dark and Crisp Fairway Light modes resolved exclusively through `Theme.of(context).colorScheme`.
- **Landscape Architecture**: 800x360 safe with compact `NavigationRail` (`minWidth: 56`, `NavigationRailLabelType.none`, wrapped in `SingleChildScrollView`), micro-appbar, and two-pane master-detail scrollable layouts.
- **Physical Device & Android SDK 36 Compatibility**:
  - `compileSdk = 36`, `targetSdk = 36`, `minSdk = 21`.
  - Impeller Vulkan disabled on Android to prevent MediaTek/Mali physical device crashes.
  - Post-frame initialization in `SplashView`.
