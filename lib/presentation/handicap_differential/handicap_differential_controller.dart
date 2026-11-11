import 'package:flutter/material.dart';

import '../../domain/entities/course_entity.dart';
import '../../domain/entities/handicap_differential_entity.dart';
import '../../domain/usecases/handicap_differential_usecase.dart';
import '../scorecard/scorecard_controller.dart';

class HandicapDifferentialController extends ChangeNotifier {
  final HandicapDifferentialUseCase _useCase;
  final ScorecardController _scorecardController;

  double _pcc = 0.0;
  String _selectedPlayerId = 'p1';
  double _playerHandicapIndex = 4.2;
  final double _lowHandicapIndex365 = 3.6;

  late CourseEntity _course;
  late String _teeBox;
  late List<int> _rawHoleStrokes;
  late List<HistoricalRoundScore> _historicalRounds;

  HandicapDifferentialController(this._useCase, this._scorecardController) {
    _course = _scorecardController.course;
    _teeBox = _scorecardController.activeScorecard.teeBox;
    _seedHistoricalRounds();
    _refreshFromScorecard();
  }

  double get pcc => _pcc;
  String get selectedPlayerId => _selectedPlayerId;
  double get playerHandicapIndex => _playerHandicapIndex;
  double get lowHandicapIndex365 => _lowHandicapIndex365;
  CourseEntity get course => _course;
  String get teeBox => _teeBox;
  List<int> get rawHoleStrokes => _rawHoleStrokes;
  List<HistoricalRoundScore> get historicalRounds => _historicalRounds;

  int get courseHandicap {
    final slope = _course.slopeForTee(_teeBox);
    final rating = _course.ratingForTee(_teeBox);
    final par = _course.totalPar;
    final slopeFactor = slope / 113.0;
    return (_playerHandicapIndex * slopeFactor + (rating - par)).round();
  }

  ScoreDifferentialResult get differentialResult {
    return _useCase.calculateScoreDifferential(
      holes: _course.holes,
      rawHoleStrokes: _rawHoleStrokes,
      courseHandicap: courseHandicap,
      courseRating: _course.ratingForTee(_teeBox),
      slopeRating: _course.slopeForTee(_teeBox),
      pcc: _pcc,
      playerHandicapIndex: _playerHandicapIndex,
    );
  }

  HandicapIndexCalculation get whsCalculation {
    return _useCase.calculateHandicapIndexFromRounds(
      _historicalRounds,
      lowHandicapIndex365: _lowHandicapIndex365,
    );
  }

  void setPcc(double value) {
    _pcc = value.clamp(-1.0, 3.0);
    notifyListeners();
  }

  void updateHoleStroke(int holeIndex, int strokes) {
    if (holeIndex >= 0 && holeIndex < _rawHoleStrokes.length) {
      _rawHoleStrokes[holeIndex] = strokes.clamp(1, 15);
      notifyListeners();
    }
  }

  void setPlayer(String playerId, double handicapIndex) {
    _selectedPlayerId = playerId;
    _playerHandicapIndex = handicapIndex;
    _refreshFromScorecard();
    notifyListeners();
  }

  void _refreshFromScorecard() {
    _course = _scorecardController.course;
    _teeBox = _scorecardController.activeScorecard.teeBox;

    final strokes = <int>[];
    for (var i = 1; i <= 18; i++) {
      final score = _scorecardController.getScoreForPlayer(
        _selectedPlayerId,
        i,
      );
      final raw = score.strokes > 0 ? score.strokes : _course.getHole(i).par;
      strokes.add(raw);
    }
    _rawHoleStrokes = strokes;
  }

  void _seedHistoricalRounds() {
    final now = DateTime.now();
    _historicalRounds = [
      HistoricalRoundScore(
        id: 'rnd_1',
        date: now.subtract(const Duration(days: 4)),
        courseName: 'Lahore Garrison Championship',
        teeBox: 'Black',
        rawGross: 76,
        adjustedGross: 75,
        differential: 3.8,
      ),
      HistoricalRoundScore(
        id: 'rnd_2',
        date: now.subtract(const Duration(days: 10)),
        courseName: 'Royal Palm Country Club',
        teeBox: 'Blue',
        rawGross: 78,
        adjustedGross: 77,
        differential: 4.5,
      ),
      HistoricalRoundScore(
        id: 'rnd_3',
        date: now.subtract(const Duration(days: 16)),
        courseName: 'Emerald Links Championship',
        teeBox: 'Black',
        rawGross: 81,
        adjustedGross: 79,
        differential: 5.6,
      ),
      HistoricalRoundScore(
        id: 'rnd_4',
        date: now.subtract(const Duration(days: 22)),
        courseName: 'Lahore Garrison Championship',
        teeBox: 'Black',
        rawGross: 75,
        adjustedGross: 75,
        differential: 3.2,
      ),
      HistoricalRoundScore(
        id: 'rnd_5',
        date: now.subtract(const Duration(days: 30)),
        courseName: 'Royal Palm Country Club',
        teeBox: 'Blue',
        rawGross: 79,
        adjustedGross: 78,
        differential: 5.1,
      ),
      HistoricalRoundScore(
        id: 'rnd_6',
        date: now.subtract(const Duration(days: 38)),
        courseName: 'Lahore Garrison Championship',
        teeBox: 'Blue',
        rawGross: 77,
        adjustedGross: 76,
        differential: 4.2,
      ),
      HistoricalRoundScore(
        id: 'rnd_7',
        date: now.subtract(const Duration(days: 46)),
        courseName: 'Emerald Links Championship',
        teeBox: 'Black',
        rawGross: 83,
        adjustedGross: 80,
        differential: 6.4,
      ),
      HistoricalRoundScore(
        id: 'rnd_8',
        date: now.subtract(const Duration(days: 55)),
        courseName: 'Lahore Garrison Championship',
        teeBox: 'Black',
        rawGross: 74,
        adjustedGross: 74,
        differential: 2.8,
      ),
      HistoricalRoundScore(
        id: 'rnd_9',
        date: now.subtract(const Duration(days: 64)),
        courseName: 'Royal Palm Country Club',
        teeBox: 'Blue',
        rawGross: 80,
        adjustedGross: 79,
        differential: 5.8,
      ),
      HistoricalRoundScore(
        id: 'rnd_10',
        date: now.subtract(const Duration(days: 75)),
        courseName: 'Lahore Garrison Championship',
        teeBox: 'Black',
        rawGross: 76,
        adjustedGross: 75,
        differential: 3.7,
      ),
      HistoricalRoundScore(
        id: 'rnd_11',
        date: now.subtract(const Duration(days: 86)),
        courseName: 'Emerald Links Championship',
        teeBox: 'Blue',
        rawGross: 82,
        adjustedGross: 80,
        differential: 6.2,
      ),
      HistoricalRoundScore(
        id: 'rnd_12',
        date: now.subtract(const Duration(days: 98)),
        courseName: 'Lahore Garrison Championship',
        teeBox: 'Black',
        rawGross: 77,
        adjustedGross: 76,
        differential: 4.4,
      ),
      HistoricalRoundScore(
        id: 'rnd_13',
        date: now.subtract(const Duration(days: 110)),
        courseName: 'Royal Palm Country Club',
        teeBox: 'White',
        rawGross: 76,
        adjustedGross: 76,
        differential: 4.9,
      ),
      HistoricalRoundScore(
        id: 'rnd_14',
        date: now.subtract(const Duration(days: 122)),
        courseName: 'Lahore Garrison Championship',
        teeBox: 'Black',
        rawGross: 79,
        adjustedGross: 78,
        differential: 5.4,
      ),
      HistoricalRoundScore(
        id: 'rnd_15',
        date: now.subtract(const Duration(days: 135)),
        courseName: 'Emerald Links Championship',
        teeBox: 'Black',
        rawGross: 85,
        adjustedGross: 81,
        differential: 7.1,
      ),
      HistoricalRoundScore(
        id: 'rnd_16',
        date: now.subtract(const Duration(days: 150)),
        courseName: 'Lahore Garrison Championship',
        teeBox: 'Black',
        rawGross: 75,
        adjustedGross: 75,
        differential: 3.4,
      ),
      HistoricalRoundScore(
        id: 'rnd_17',
        date: now.subtract(const Duration(days: 165)),
        courseName: 'Royal Palm Country Club',
        teeBox: 'Blue',
        rawGross: 80,
        adjustedGross: 79,
        differential: 5.7,
      ),
      HistoricalRoundScore(
        id: 'rnd_18',
        date: now.subtract(const Duration(days: 180)),
        courseName: 'Lahore Garrison Championship',
        teeBox: 'Blue',
        rawGross: 78,
        adjustedGross: 77,
        differential: 4.8,
      ),
      HistoricalRoundScore(
        id: 'rnd_19',
        date: now.subtract(const Duration(days: 195)),
        courseName: 'Emerald Links Championship',
        teeBox: 'Black',
        rawGross: 84,
        adjustedGross: 81,
        differential: 6.9,
      ),
      HistoricalRoundScore(
        id: 'rnd_20',
        date: now.subtract(const Duration(days: 210)),
        courseName: 'Lahore Garrison Championship',
        teeBox: 'Black',
        rawGross: 76,
        adjustedGross: 76,
        differential: 4.1,
      ),
    ];
  }
}
