import 'package:uuid/uuid.dart';
import '../../core/constants/golf_courses.dart';
import '../../core/storage/database_helper.dart';
import '../../core/storage/preferences_service.dart';
import '../models/flight_model.dart';
import '../models/hole_score_model.dart';
import '../models/round_scorecard_model.dart';

class ScorecardRepository {
  final PreferencesService _prefs;
  final DatabaseHelper _db;
  final Uuid _uuid = const Uuid();

  ScorecardRepository(this._prefs, this._db);

  RoundScorecardModel getOrCreateActiveScorecard(FlightModel flight) {
    final existing = _prefs.getActiveScorecard();
    if (existing != null && existing.playerScores.keys.toSet().containsAll(flight.players.map((p) => p.id))) {
      return existing;
    }

    final course = GolfCourses.getCourseById(flight.courseId);
    final initialScores = <String, List<HoleScoreModel>>{};

    for (final player in flight.players) {
      initialScores[player.id] = course.holes.map((hole) {
        return HoleScoreModel(
          holeNumber: hole.holeNumber,
          strokes: hole.par,
          putts: 2,
          fir: hole.par == 3 ? 'none' : 'center',
          gir: true,
          bunker: false,
          penalty: false,
        );
      }).toList();
    }

    final newScorecard = RoundScorecardModel(
      id: _uuid.v4(),
      courseId: course.id,
      courseName: course.name,
      teeBox: flight.defaultTeeBox,
      gameFormat: flight.gameFormat,
      playedAt: DateTime.now(),
      playerScores: initialScores,
      isCompleted: false,
    );

    _prefs.saveActiveScorecard(newScorecard);
    return newScorecard;
  }

  Future<void> saveActiveScorecard(RoundScorecardModel scorecard) async {
    await _prefs.saveActiveScorecard(scorecard);
  }

  Future<void> completeAndArchiveRound(RoundScorecardModel scorecard, String currentUserId) async {
    final completed = scorecard.copyWith(isCompleted: true);
    await _prefs.saveActiveScorecard(completed);

    final gross = completed.getGrossTotalForPlayer(currentUserId);
    final net = gross - 4; // Course handicap adjusted

    await _db.insertRound(completed, gross: gross, net: net);
  }

  Future<List<Map<String, dynamic>>> getHistoricalRounds() async {
    return await _db.getCompletedRounds();
  }
}
