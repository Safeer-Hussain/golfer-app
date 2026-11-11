# Golfer Autonomous Engineering Backlog

This backlog defines 25 granular daily engineering sprints for autonomous progression. Each sprint specifies end-to-end user-facing capability, domain logic, and automated test requirements.

- [x] **Sprint 1: Nassau Press Side-Bet Calculator**
  - Interactive Front 9, Back 9, and 18-hole Nassau match tracker with automatic 2-down press detection and ledger balancing across 4 players.
  - Tests: `test/unit/nassau_calculator_test.dart`.

- [x] **Sprint 2: Green Reading Slope & Stimpmeter Simulator**
  - Gyroscope/accelerometer slope reading tool displaying degrees of break, fall line arrow, and adjusted putting distance for green speeds 8.0 to 13.0 stimp.
  - Tests: `test/unit/green_reading_test.dart`, `test/widget/green_reading_view_test.dart`.

- [x] **Sprint 3: Swing Tempo Metronome Audio/Visual Trainer**
  - 3:1 Tour tempo audio/visual metronome (e.g. 21/7 and 24/8 frames) with vibrating tactile beats and swing rhythm calibrator.
  - Tests: `test/unit/swing_tempo_test.dart`, `test/widget/swing_tempo_view_test.dart`.

- [ ] **Sprint 4: USGA Handicap Differential Calculator & Equitable Stroke Control**
  - Calculates score differentials `(113 / Slope) * (Adjusted Gross - Rating)` and enforces net double bogey maximum hole score adjustments.
  - Tests: `test/unit/handicap_differential_test.dart`.

- [ ] **Sprint 5: Tournament Skins Pot Splitter & Carryover Engine**
  - Low gross/net hole-by-hole skins tracker with automatic carryovers, validation modal, and payout ledger.
  - Tests: `test/unit/skins_pot_test.dart`.

- [ ] **Sprint 6: Wolf Game Mode Scoring Engine**
  - 4-player rotational Wolf format tracker: Blind Wolf calls, Lone Wolf scoring, partner pick timers, and point leaderboards.
  - Tests: `test/unit/wolf_game_test.dart`.

- [ ] **Sprint 7: Club Gapping Matrix & Distance Dispersion Radar**
  - Interactive visual distance gapping table highlighting yardage overlaps or >15-yard gaps between consecutive clubs in the player's 14-club bag.
  - Tests: `test/unit/club_gapping_test.dart`.

- [ ] **Sprint 8: Wind Vector Compass HUD & True Crosswind Resolver**
  - Real-time compass rose resolving current hole heading against live atmospheric wind degrees, displaying headwind, tailwind, and lateral crosswind knots.
  - Tests: `test/unit/wind_compass_test.dart`.

- [ ] **Sprint 9: Stableford Quota Tournament Flight Engine**
  - Point quota game mode (36 minus player handicap index) with real-time +/- quota deficit indicators during round.
  - Tests: `test/unit/stableford_quota_test.dart`.

- [ ] **Sprint 10: Laser Rangefinder Target Pin Magnifier View**
  - 2x/4x digital crosshair zoom viewport with high-precision pin seeker reticle and vibration confirmation.
  - Tests: `test/unit/pin_magnifier_test.dart`.

- [ ] **Sprint 11: Vegas / Monte Carlo Golf Bet Calculator**
  - Team pairing 2v2 multiplier game mode where team scores form 2-digit numbers (e.g., 4 and 5 = 45 vs 5 and 6 = 56).
  - Tests: `test/unit/vegas_bet_test.dart`.

- [ ] **Sprint 12: Putt Distance & Break Trajectory Visualizer**
  - 2D green contour visualizer showing apex target aim point, entry speed, and uphill/downhill rollback curves.
  - Tests: `test/unit/putt_trajectory_test.dart`.

- [ ] **Sprint 13: 4-Ball Match Play Dormie Status Tracker**
  - Live Ryder Cup style match cockpit displaying holes remaining, dormie status (e.g., "3 & 2", "1 UP", "AS"), and press triggers.
  - Tests: `test/unit/match_play_test.dart`.

- [ ] **Sprint 14: Weather & Barometric Pressure Air Density Adjuster**
  - Calculates air density index (temperature, humidity, altitude, barometric pressure) and outputs percentage carry distance delta.
  - Tests: `test/unit/air_density_test.dart`.

- [ ] **Sprint 15: Scoring Dispersion Heatmap & Approach Radial Chart**
  - Radar scatter plot plotting miss tendencies (short-left, long-right, pin-high) per club category.
  - Tests: `test/unit/dispersion_heatmap_test.dart`.

- [ ] **Sprint 16: Bing Bango Bongo Points Cockpit**
  - Tracks 3 points per hole: First on the green (Bingo), closest to the pin once all on (Bango), first in the cup (Bongo).
  - Tests: `test/unit/bing_bango_bongo_test.dart`.

- [ ] **Sprint 17: Hole-by-Hole Club Recommendation Matrix**
  - Full 18-hole pre-round caddie playbook mapping out driver vs 3-wood off tee and optimal approach clubs.
  - Tests: `test/unit/caddie_playbook_test.dart`.

- [ ] **Sprint 18: Scramble Team Contribution Audit**
  - Logs whose drive, approach, and putt was selected on each hole during a 4-person scramble to ensure required drive quotas are met.
  - Tests: `test/unit/scramble_audit_test.dart`.

- [ ] **Sprint 19: Offline Tournament Leaderboard Broadcaster**
  - Local Wi-Fi / Bluetooth peer-to-peer live scorecard broadcaster synchronizing flights across devices without internet.
  - Tests: `test/unit/offline_broadcaster_test.dart`.

- [ ] **Sprint 20: Yardage Book Printable PDF Generator**
  - Exports vector printable PGA-tour style fairway yardage book pages with hazard distances and green depths.
  - Tests: `test/unit/yardage_book_pdf_test.dart`.

- [ ] **Sprint 21: Three-Putt Avoidance Drill & Putting Tracker**
  - Logs first-putt lag distance (feet) and second-putt conversions, generating 3-putt percentage risk warnings.
  - Tests: `test/unit/lag_putting_test.dart`.

- [ ] **Sprint 22: Lie Angle & Turf Interaction Advisor**
  - Inputs fairway lie, rough thickness (first cut vs heavy rough), or sand firmness to adjust effective ball launch.
  - Tests: `test/unit/lie_angle_advisor_test.dart`.

- [ ] **Sprint 23: Live Voice Stroke Logging Controller**
  - On-course speech-to-intent processor parsing phrases like "Safeer 4 with 2 putts FIR center" directly into scorecard cells.
  - Tests: `test/unit/voice_logger_test.dart`.

- [ ] **Sprint 24: Shot Dispersion Confidence Cone on Map**
  - Overlays semi-transparent lateral and longitudinal ellipse polygons representing club dispersion on the OpenStreetMap rangefinder canvas.
  - Tests: `test/unit/confidence_cone_test.dart`.

- [ ] **Sprint 25: Career Milestone Trophy Cabinet & Personal Bests Archive**
  - Tracks career low round, longest drive, most birdies in a round, and lowest 9-hole score with badge unlocks in SQLite.
  - Tests: `test/unit/trophy_cabinet_test.dart`.
