import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/golf_courses.dart';
import '../../core/storage/preferences_service.dart';
import '../../core/utils/handicap_calculator.dart';
import '../../data/models/flight_model.dart';
import '../../data/models/hole_score_model.dart';
import '../../data/models/player_model.dart';
import '../../data/models/round_scorecard_model.dart';
import '../../data/repositories/clubhouse_repository.dart';
import '../../data/repositories/scorecard_repository.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/hole_entity.dart';
import '../../domain/usecases/calculate_score_usecase.dart';

class ScorecardController extends ChangeNotifier {
  final ScorecardRepository _scorecardRepository;
  final PreferencesService _prefs;
  final CalculateScoreUseCase _calculateScoreUseCase;
  final ClubhouseRepository _clubhouseRepository;

  late RoundScorecardModel _activeScorecard;
  late CourseEntity _course;
  late List<PlayerModel> _players;
  int _currentHoleIndex = 0;

  ScorecardController(
    this._scorecardRepository,
    this._prefs,
    this._calculateScoreUseCase,
    this._clubhouseRepository,
  );

  RoundScorecardModel get activeScorecard => _activeScorecard;
  CourseEntity get course => _course;
  List<PlayerModel> get players => _players;
  int get currentHoleIndex => _currentHoleIndex;
  int get currentHoleNumber => _currentHoleIndex + 1;
  HoleEntity get currentHole => _course.holes[_currentHoleIndex];

  void initializeWithFlight(FlightModel flight) {
    _course = GolfCourses.getCourseById(flight.courseId);
    _players = flight.players;
    _currentHoleIndex = _prefs.getActiveHoleIndex().clamp(0, 17);
    _activeScorecard = _scorecardRepository.getOrCreateActiveScorecard(flight);
    notifyListeners();
  }

  void setHoleIndex(int index) {
    if (index < 0 || index >= 18) return;
    _currentHoleIndex = index;
    _prefs.setActiveHoleIndex(index);
    notifyListeners();
  }

  void nextHole() {
    if (_currentHoleIndex < 17) {
      setHoleIndex(_currentHoleIndex + 1);
    }
  }

  void previousHole() {
    if (_currentHoleIndex > 0) {
      setHoleIndex(_currentHoleIndex - 1);
    }
  }

  HoleScoreModel getScoreForPlayer(String playerId, int holeNumber) {
    final list = _activeScorecard.playerScores[playerId];
    if (list != null && list.isNotEmpty) {
      final match = list.where((s) => s.holeNumber == holeNumber);
      if (match.isNotEmpty) return match.first;
    }
    return HoleScoreModel(holeNumber: holeNumber, strokes: currentHole.par);
  }

  void updateStrokes(String playerId, int holeNumber, int delta) {
    final current = getScoreForPlayer(playerId, holeNumber);
    final newStrokes = (current.strokes + delta).clamp(1, 15);
    _updateHoleScore(playerId, current.copyWith(strokes: newStrokes));
  }

  void updatePutts(String playerId, int holeNumber, int delta) {
    final current = getScoreForPlayer(playerId, holeNumber);
    final newPutts = (current.putts + delta).clamp(0, 10);
    _updateHoleScore(playerId, current.copyWith(putts: newPutts));
  }

  void updateFir(String playerId, int holeNumber, String fir) {
    final current = getScoreForPlayer(playerId, holeNumber);
    _updateHoleScore(playerId, current.copyWith(fir: fir));
  }

  void toggleGir(String playerId, int holeNumber) {
    final current = getScoreForPlayer(playerId, holeNumber);
    _updateHoleScore(playerId, current.copyWith(gir: !current.gir));
  }

  void toggleBunker(String playerId, int holeNumber) {
    final current = getScoreForPlayer(playerId, holeNumber);
    _updateHoleScore(playerId, current.copyWith(bunker: !current.bunker));
  }

  void togglePenalty(String playerId, int holeNumber) {
    final current = getScoreForPlayer(playerId, holeNumber);
    _updateHoleScore(playerId, current.copyWith(penalty: !current.penalty));
  }

  void _updateHoleScore(String playerId, HoleScoreModel updatedHoleScore) {
    final currentList = List<HoleScoreModel>.from(
      _activeScorecard.playerScores[playerId] ?? [],
    );

    final idx = currentList.indexWhere((h) => h.holeNumber == updatedHoleScore.holeNumber);
    if (idx != -1) {
      currentList[idx] = updatedHoleScore;
    } else {
      currentList.add(updatedHoleScore);
    }

    final newScoresMap = Map<String, List<HoleScoreModel>>.from(_activeScorecard.playerScores);
    newScoresMap[playerId] = currentList;

    _activeScorecard = _activeScorecard.copyWith(playerScores: newScoresMap);
    _scorecardRepository.saveActiveScorecard(_activeScorecard);
    notifyListeners();
  }

  Map<String, dynamic> getPlayerAnalytics(String playerId) {
    final scores = _activeScorecard.playerScores[playerId] ?? [];
    final player = _players.firstWhere((p) => p.id == playerId, orElse: () => _players.first);
    return _calculateScoreUseCase.computeRoundAnalytics(
      scores: scores,
      course: _course,
      courseHandicap: player.courseHandicap,
    );
  }

  List<Map<String, dynamic>> getLeaderboard() {
    final list = <Map<String, dynamic>>[];
    for (final player in _players) {
      final analytics = getPlayerAnalytics(player.id);
      list.add({
        'player': player,
        'gross': analytics['grossTotal'],
        'net': analytics['netTotal'],
        'points': analytics['stablefordTotal'],
        'diffVsPar': analytics['diffVsPar'],
        'thru': _activeScorecard.playerScores[player.id]?.length ?? 0,
      });
    }

    list.sort((a, b) => (a['net'] as int).compareTo(b['net'] as int));
    return list;
  }

  Future<void> completeRound() async {
    final userPlayer = _players.firstWhere(
      (p) => p.isCurrentDeviceUser,
      orElse: () => _players.first,
    );
    await _scorecardRepository.completeAndArchiveRound(_activeScorecard, userPlayer.id);
    notifyListeners();
  }

  Future<void> postRoundToClubhouse({required String commentary}) async {
    final userPlayer = _players.firstWhere(
      (p) => p.isCurrentDeviceUser,
      orElse: () => _players.first,
    );
    final analytics = getPlayerAnalytics(userPlayer.id);

    await _clubhouseRepository.createPost(
      authorName: userPlayer.name,
      authorAvatar: userPlayer.avatarAsset,
      courseName: _course.name,
      scoreGross: analytics['grossTotal'] as int,
      scoreNet: analytics['netTotal'] as int,
      diffVsPar: analytics['diffVsPar'] as String,
      textContent: commentary.isEmpty
          ? 'Completed 18-hole championship round at ${_course.name}. Gross ${analytics['grossTotal']} (${analytics['diffVsPar']}).'
          : commentary,
      firPct: analytics['firPct'] as int,
      girPct: analytics['girPct'] as int,
    );
    notifyListeners();
  }

  Future<void> copyAsciiScorecardToClipboard() async {
    final sb = StringBuffer();
    sb.writeln('========================================');
    sb.writeln('GOLFER DIGITAL SCORECARD - ${_course.name}');
    sb.writeln('Date: ${_activeScorecard.playedAt.toString().substring(0, 10)} | Tee: ${_activeScorecard.teeBox}');
    sb.writeln('========================================');
    sb.writeln('Hole | Par | Gross | Net | Pts');
    sb.writeln('----------------------------------------');

    final userPlayer = _players.firstWhere(
      (p) => p.isCurrentDeviceUser,
      orElse: () => _players.first,
    );
    final scores = _activeScorecard.playerScores[userPlayer.id] ?? [];

    for (final s in scores) {
      final hole = _course.getHole(s.holeNumber);
      final net = HandicapCalculator.calculateNetScore(
        grossStrokes: s.strokes,
        holeStrokeIndex: hole.strokeIndex,
        courseHandicap: userPlayer.courseHandicap,
      );
      final pts = HandicapCalculator.calculateStablefordPoints(
        grossStrokes: s.strokes,
        par: hole.par,
        holeStrokeIndex: hole.strokeIndex,
        courseHandicap: userPlayer.courseHandicap,
      );
      sb.writeln('${s.holeNumber.toString().padLeft(4)} | ${hole.par.toString().padLeft(3)} | ${s.strokes.toString().padLeft(5)} | ${net.toString().padLeft(3)} | ${pts.toString().padLeft(3)}');
    }

    final analytics = getPlayerAnalytics(userPlayer.id);
    sb.writeln('========================================');
    sb.writeln('TOTAL: Gross ${analytics['grossTotal']} (${analytics['diffVsPar']}) | Net ${analytics['netTotal']} | Stableford ${analytics['stablefordTotal']} pts');
    sb.writeln('FIR: ${analytics['firPct']}% | GIR: ${analytics['girPct']}% | Putts: ${analytics['totalPutts']}');
    sb.writeln('========================================');

    await Clipboard.setData(ClipboardData(text: sb.toString()));
  }
}
