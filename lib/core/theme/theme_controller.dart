import 'package:flutter/material.dart';
import '../storage/preferences_service.dart';

class ThemeController extends ChangeNotifier {
  final PreferencesService _prefs;
  late ThemeMode _themeMode;

  ThemeController(this._prefs) {
    final savedMode = _prefs.getThemeMode();
    _themeMode = savedMode == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
      await _prefs.setThemeMode('light');
    } else {
      _themeMode = ThemeMode.dark;
      await _prefs.setThemeMode('dark');
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _prefs.setThemeMode(mode == ThemeMode.light ? 'light' : 'dark');
    notifyListeners();
  }
}
