import 'package:flutter/material.dart';

import '../../data/models/player_model.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/skins_pot_entity.dart';
import '../../domain/usecases/skins_pot_usecase.dart';
import '../scorecard/scorecard_controller.dart';

class SkinsPotController extends ChangeNotifier {
  final SkinsPotUseCase _useCase;
  final ScorecardController _scorecardController;

  SkinsScoringMode _mode = SkinsScoringMode.gross;
  double _stakePerHole = 5.0;
  Hole18CarryoverRule _hole18Rule = Hole18CarryoverRule.carryoverPush;
  bool _useSimulatedScores = false;

  late CourseEntity _course;
  late List<PlayerModel> _players;
  late Map<String, List<int>> _simulatedScores;

  SkinsPotController(this._useCase, this._scorecardController) {
    _course = _scorecardController.course;
    _players = _resolveFlightPlayers();
    _seedSimulatedScores();
  }

  SkinsScoringMode get mode => _mode;
  double get stakePerHole => _stakePerHole;
  Hole18CarryoverRule get hole18Rule => _hole18Rule;
  bool get useSimulatedScores => _useSimulatedScores;
  CourseEntity get course => _course;
  List<PlayerModel> get players => _players;

  List<PlayerModel> _resolveFlightPlayers() {
    final active = _scorecardController.players;
    if (active.length >= 2) return active;

    // Provide default 4-player tournament flight if only 1 player is initialized
    return const [
      PlayerModel(
        id: 'p1',
        name: 'Safeer Hussain',
        handicapIndex: 4.2,
        avatarAsset: 'assets/images/avatar_safeer.png',
        teeBox: 'Black',
      ),
      PlayerModel(
        id: 'p2',
        name: 'Hamza Khan',
        handicapIndex: 8.6,
        avatarAsset: 'assets/images/avatar_player2.png',
        teeBox: 'Blue',
      ),
      PlayerModel(
        id: 'p3',
        name: 'Bilal Tariq',
        handicapIndex: 12.4,
        avatarAsset: 'assets/images/avatar_player3.png',
        teeBox: 'Blue',
      ),
      PlayerModel(
        id: 'p4',
        name: 'Usman Malik',
        handicapIndex: 16.8,
        avatarAsset: 'assets/images/avatar_player4.png',
        teeBox: 'White',
      ),
    ];
  }

  void _seedSimulatedScores() {
    // Realistic 18-hole scores with natural ties and multi-hole carryover sweeps
    _simulatedScores = {
      'p1': [4, 5, 3, 4, 4, 3, 5, 4, 4, 4, 5, 3, 4, 4, 3, 5, 4, 4],
      'p2': [4, 5, 3, 5, 4, 4, 5, 4, 5, 4, 6, 3, 4, 5, 3, 5, 4, 5],
      'p3': [5, 6, 4, 5, 5, 3, 6, 5, 5, 5, 6, 4, 5, 5, 4, 6, 5, 5],
      'p4': [5, 6, 4, 6, 5, 4, 6, 5, 6, 5, 7, 4, 5, 6, 4, 6, 5, 6],
    };
  }

  Map<String, int> get playerCourseHandicaps {
    final map = <String, int>{};
    final slope = _course.slope;
    final rating = _course.rating;
    final par = _course.par;

    for (final player in _players) {
      final slopeFactor = slope / 113.0;
      final ch = (player.handicapIndex * slopeFactor + (rating - par)).round();
      map[player.id] = ch;
    }
    return map;
  }

  Map<String, List<int>> get activeScores {
    if (_useSimulatedScores) {
      return _simulatedScores;
    }

    final result = <String, List<int>>{};
    for (final player in _players) {
      final scores = <int>[];
      for (var i = 1; i <= 18; i++) {
        final holeScore = _scorecardController.getScoreForPlayer(player.id, i);
        scores.add(holeScore.strokes);
      }
      result[player.id] = scores;
    }

    // If active scorecard has 0 completed holes, fallback to simulation for rich UX
    final totalStrokes = result.values.fold<int>(
      0,
      (acc, list) => acc + list.fold(0, (a, b) => a + b),
    );
    if (totalStrokes == 0) {
      return _simulatedScores;
    }

    return result;
  }

  SkinsGameResult get gameResult {
    return _useCase.evaluateSkinsGame(
      holes: _course.holes,
      players: _players,
      playerScores: activeScores,
      playerCourseHandicaps: playerCourseHandicaps,
      mode: _mode,
      stakePerHole: _stakePerHole,
      hole18Rule: _hole18Rule,
    );
  }

  void setMode(SkinsScoringMode mode) {
    if (_mode != mode) {
      _mode = mode;
      notifyListeners();
    }
  }

  void setStakePerHole(double stake) {
    if (_stakePerHole != stake) {
      _stakePerHole = stake;
      notifyListeners();
    }
  }

  void setHole18Rule(Hole18CarryoverRule rule) {
    if (_hole18Rule != rule) {
      _hole18Rule = rule;
      notifyListeners();
    }
  }

  void toggleSimulatedScores() {
    _useSimulatedScores = !_useSimulatedScores;
    notifyListeners();
  }

  void updatePlayerHoleScore(String playerId, int holeIndex, int strokes) {
    if (_simulatedScores.containsKey(playerId) &&
        holeIndex >= 0 &&
        holeIndex < 18) {
      _simulatedScores[playerId]![holeIndex] = strokes.clamp(1, 15);
      _useSimulatedScores = true;
      notifyListeners();
    }
  }
}
