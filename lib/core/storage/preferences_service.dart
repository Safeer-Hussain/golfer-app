import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../data/models/flight_model.dart';
import '../../data/models/round_scorecard_model.dart';

class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  // Theme
  String getThemeMode() {
    return _prefs.getString(AppConstants.keyThemeMode) ?? 'dark';
  }

  Future<bool> setThemeMode(String mode) {
    return _prefs.setString(AppConstants.keyThemeMode, mode);
  }

  // Unit System
  String getUnitSystem() {
    return _prefs.getString(AppConstants.keyUnitSystem) ?? 'yards';
  }

  Future<bool> setUnitSystem(String unit) {
    return _prefs.setString(AppConstants.keyUnitSystem, unit);
  }

  // Active Flight
  FlightModel? getActiveFlight() {
    final raw = _prefs.getString(AppConstants.keyActiveFlight);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return FlightModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveActiveFlight(FlightModel flight) {
    return _prefs.setString(AppConstants.keyActiveFlight, jsonEncode(flight.toJson()));
  }

  Future<bool> clearActiveFlight() {
    return _prefs.remove(AppConstants.keyActiveFlight);
  }

  // Active Round Scorecard
  RoundScorecardModel? getActiveScorecard() {
    final raw = _prefs.getString(AppConstants.keyActiveRoundScorecard);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return RoundScorecardModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveActiveScorecard(RoundScorecardModel scorecard) {
    return _prefs.setString(AppConstants.keyActiveRoundScorecard, jsonEncode(scorecard.toJson()));
  }

  Future<bool> clearActiveScorecard() {
    return _prefs.remove(AppConstants.keyActiveRoundScorecard);
  }

  // Active Hole Index
  int getActiveHoleIndex() {
    return _prefs.getInt(AppConstants.keyActiveHoleIndex) ?? 0;
  }

  Future<bool> setActiveHoleIndex(int index) {
    return _prefs.setInt(AppConstants.keyActiveHoleIndex, index);
  }

  // Recruiter Debug Preferences
  bool getSimulateLatency() {
    return _prefs.getBool(AppConstants.keySimulateLatency) ?? true;
  }

  Future<bool> setSimulateLatency(bool value) {
    return _prefs.setBool(AppConstants.keySimulateLatency, value);
  }

  bool getSimulateError() {
    return _prefs.getBool(AppConstants.keySimulateError) ?? false;
  }

  Future<bool> setSimulateError(bool value) {
    return _prefs.setBool(AppConstants.keySimulateError, value);
  }
}
