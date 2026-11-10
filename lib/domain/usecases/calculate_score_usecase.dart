import '../../core/utils/handicap_calculator.dart';
import '../../data/models/hole_score_model.dart';
import '../entities/course_entity.dart';

class CalculateScoreUseCase {
  Map<String, dynamic> computeRoundAnalytics({
    required List<HoleScoreModel> scores,
    required CourseEntity course,
    required int courseHandicap,
  }) {
    int grossTotal = 0;
    int netTotal = 0;
    int parTotal = 0;
    int stablefordTotal = 0;
    int totalPutts = 0;
    int firHits = 0;
    int firOpportunities = 0;
    int girHits = 0;
    int birdiesOrBetter = 0;
    int pars = 0;
    int bogeys = 0;
    int doubleBogeysOrWorse = 0;

    for (final score in scores) {
      final hole = course.getHole(score.holeNumber);
      grossTotal += score.strokes;
      parTotal += hole.par;
      totalPutts += score.putts;

      final net = HandicapCalculator.calculateNetScore(
        grossStrokes: score.strokes,
        holeStrokeIndex: hole.strokeIndex,
        courseHandicap: courseHandicap,
      );
      netTotal += net;

      final pts = HandicapCalculator.calculateStablefordPoints(
        grossStrokes: score.strokes,
        par: hole.par,
        holeStrokeIndex: hole.strokeIndex,
        courseHandicap: courseHandicap,
      );
      stablefordTotal += pts;

      if (hole.par > 3) {
        firOpportunities++;
        if (score.fir == 'center') firHits++;
      }

      if (score.gir) girHits++;

      final diff = score.strokes - hole.par;
      if (diff <= -1) {
        birdiesOrBetter++;
      } else if (diff == 0) {
        pars++;
      } else if (diff == 1) {
        bogeys++;
      } else {
        doubleBogeysOrWorse++;
      }
    }

    final firPct = firOpportunities > 0
        ? ((firHits / firOpportunities) * 100).round()
        : 0;
    final girPct = scores.isNotEmpty
        ? ((girHits / scores.length) * 100).round()
        : 0;

    return {
      'grossTotal': grossTotal,
      'netTotal': netTotal,
      'parTotal': parTotal,
      'stablefordTotal': stablefordTotal,
      'totalPutts': totalPutts,
      'firPct': firPct,
      'girPct': girPct,
      'birdiesOrBetter': birdiesOrBetter,
      'pars': pars,
      'bogeys': bogeys,
      'doubleBogeysOrWorse': doubleBogeysOrWorse,
      'diffVsPar': HandicapCalculator.formatScoreVsPar(grossTotal, parTotal),
    };
  }
}
