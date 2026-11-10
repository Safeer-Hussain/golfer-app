class AppConstants {
  static const String appName = 'Golfer';
  static const String appVersion = '1.0.0+1';
  static const String appSubheading =
      'Championship Multi-Player Flight & AI Caddie';

  // Persistence Keys
  static const String keyThemeMode = 'golfer_theme_mode';
  static const String keyUnitSystem =
      'golfer_unit_system'; // 'yards' or 'meters'
  static const String keyActiveFlight = 'golfer_active_flight_json';
  static const String keyActiveRoundScorecard = 'golfer_active_scorecard_json';
  static const String keyActiveHoleIndex = 'golfer_active_hole_index';
  static const String keySimulateLatency = 'golfer_debug_simulate_latency';
  static const String keySimulateError = 'golfer_debug_simulate_error';
  static const String keyClubBagCalibrated = 'golfer_club_bag_calibrated';

  // Database
  static const String dbName = 'golfer_championship.db';
  static const int dbVersion = 1;

  // Formats
  static const String formatStrokePlay = 'Stroke Play (Gross/Net)';
  static const String formatStableford = 'Stableford Points';
  static const String formatMatchPlay = 'Match Play';
  static const String formatScramble = '4-Player Scramble';

  // Tee Boxes
  static const String teeBlack = 'Championship Black';
  static const String teeBlue = 'Tournament Blue';
  static const String teeWhite = 'Member White';
  static const String teeRed = 'Forward Red';
}
