import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../core/network/network_service.dart';
import '../../core/storage/preferences_service.dart';

class SettingsController extends ChangeNotifier {
  final PreferencesService _prefs;
  final NetworkService _networkService;
  late final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isOffline = false;
  String _unitSystem = 'yards';
  bool _simulateLatency = true;
  bool _simulateError = false;

  Map<String, dynamic>? _liveTournamentData;
  bool _isLoadingTournament = false;
  String? _tournamentError;

  SettingsController(this._prefs, this._networkService) {
    _unitSystem = _prefs.getUnitSystem();
    _simulateLatency = _prefs.getSimulateLatency();
    _simulateError = _prefs.getSimulateError();
    _connectivity = Connectivity();
    _initConnectivity();
  }

  bool get isOffline => _isOffline;
  String get unitSystem => _unitSystem;
  bool get simulateLatency => _simulateLatency;
  bool get simulateError => _simulateError;
  Map<String, dynamic>? get liveTournamentData => _liveTournamentData;
  bool get isLoadingTournament => _isLoadingTournament;
  String? get tournamentError => _tournamentError;

  void _initConnectivity() {
    try {
      _connectivity
          .checkConnectivity()
          .then(_updateConnectionStatus)
          .catchError((Object _) {});
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectionStatus,
        onError: (Object _) {},
      );
    } catch (_) {}
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final offline =
        results.isEmpty || results.contains(ConnectivityResult.none);
    if (_isOffline != offline) {
      _isOffline = offline;
      notifyListeners();
    }
  }

  Future<void> setUnitSystem(String unit) async {
    _unitSystem = unit;
    await _prefs.setUnitSystem(unit);
    notifyListeners();
  }

  Future<void> toggleSimulateLatency(bool val) async {
    _simulateLatency = val;
    await _prefs.setSimulateLatency(val);
    notifyListeners();
  }

  Future<void> toggleSimulateError(bool val) async {
    _simulateError = val;
    await _prefs.setSimulateError(val);
    notifyListeners();
  }

  Future<void> testTournamentSync() async {
    _isLoadingTournament = true;
    _tournamentError = null;
    notifyListeners();

    try {
      _liveTournamentData = await _networkService
          .fetchLiveTournamentLeaderboard();
    } catch (e) {
      _tournamentError = e.toString();
      _liveTournamentData = null;
    } finally {
      _isLoadingTournament = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
