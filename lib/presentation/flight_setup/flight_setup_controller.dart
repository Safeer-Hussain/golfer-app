import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/golf_courses.dart';
import '../../core/utils/handicap_calculator.dart';
import '../../data/models/flight_model.dart';
import '../../data/models/player_model.dart';
import '../../data/repositories/flight_repository.dart';
import '../../domain/entities/course_entity.dart';

class FlightSetupController extends ChangeNotifier {
  final FlightRepository _flightRepository;
  final Uuid _uuid = const Uuid();

  late CourseEntity _selectedCourse;
  late String _selectedTee;
  late String _selectedFormat;
  late List<PlayerModel> _flightPlayers;

  FlightSetupController(this._flightRepository) {
    _init();
  }

  CourseEntity get selectedCourse => _selectedCourse;
  String get selectedTee => _selectedTee;
  String get selectedFormat => _selectedFormat;
  List<PlayerModel> get flightPlayers => List.unmodifiable(_flightPlayers);

  bool get canAddMorePlayers => _flightPlayers.length < 4;

  void _init() {
    final active = _flightRepository.getOrCreateActiveFlight();
    _selectedCourse = GolfCourses.getCourseById(active.courseId);
    _selectedTee = active.defaultTeeBox;
    _selectedFormat = active.gameFormat;
    _flightPlayers = List.from(active.players);
    _recalculateCourseHandicaps();
  }

  void selectCourse(CourseEntity course) {
    _selectedCourse = course;
    _recalculateCourseHandicaps();
    _persistFlight();
    notifyListeners();
  }

  void selectTee(String tee) {
    _selectedTee = tee;
    _flightPlayers = _flightPlayers
        .map((p) => p.copyWith(teeBox: tee))
        .toList();
    _recalculateCourseHandicaps();
    _persistFlight();
    notifyListeners();
  }

  void selectFormat(String format) {
    _selectedFormat = format;
    _persistFlight();
    notifyListeners();
  }

  void addMemberPlayer(PlayerModel player) {
    if (_flightPlayers.length >= 4) return;
    if (_flightPlayers.any((p) => p.id == player.id)) return;

    final updatedPlayer = player.copyWith(
      teeBox: _selectedTee,
      courseHandicap: _calculatePlayerCourseHandicap(player.handicapIndex),
    );

    _flightPlayers.add(updatedPlayer);
    _persistFlight();
    notifyListeners();
  }

  bool addCustomPlayer({
    required String name,
    required double handicap,
    required String teeBox,
  }) {
    if (_flightPlayers.length >= 4) return false;
    final id = 'player_${_uuid.v4().substring(0, 8)}';
    final customPlayer = PlayerModel(
      id: id,
      name: name,
      handicapIndex: handicap,
      avatarAsset: 'assets/images/avatar_player4.png',
      teeBox: teeBox,
      courseHandicap: _calculatePlayerCourseHandicap(handicap),
      isCurrentDeviceUser: false,
    );

    _flightPlayers.add(customPlayer);
    _persistFlight();
    notifyListeners();
    return true;
  }

  void removePlayer(String playerId) {
    // Keep at least 1 player
    if (_flightPlayers.length <= 1) return;
    _flightPlayers.removeWhere((p) => p.id == playerId);
    _persistFlight();
    notifyListeners();
  }

  void updatePlayerTee(String playerId, String teeBox) {
    final index = _flightPlayers.indexWhere((p) => p.id == playerId);
    if (index != -1) {
      final p = _flightPlayers[index];
      _flightPlayers[index] = p.copyWith(
        teeBox: teeBox,
        courseHandicap: _calculatePlayerCourseHandicap(p.handicapIndex),
      );
      _persistFlight();
      notifyListeners();
    }
  }

  int _calculatePlayerCourseHandicap(double handicapIndex) {
    return HandicapCalculator.calculateCourseHandicap(
      handicapIndex: handicapIndex,
      slopeRating: _selectedCourse.slope,
      courseRating: _selectedCourse.rating,
      par: _selectedCourse.par,
    );
  }

  void _recalculateCourseHandicaps() {
    _flightPlayers = _flightPlayers.map((p) {
      return p.copyWith(
        courseHandicap: _calculatePlayerCourseHandicap(p.handicapIndex),
      );
    }).toList();
  }

  FlightModel getCurrentFlightModel() {
    return FlightModel(
      courseId: _selectedCourse.id,
      courseName: _selectedCourse.name,
      defaultTeeBox: _selectedTee,
      gameFormat: _selectedFormat,
      players: _flightPlayers,
      startedAt: DateTime.now(),
    );
  }

  Future<void> _persistFlight() async {
    await _flightRepository.saveActiveFlight(getCurrentFlightModel());
  }

  Future<void> saveAndStartRound() async {
    await _persistFlight();
  }
}
