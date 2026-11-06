import 'package:flutter_test/flutter_test.dart';
import 'package:golfer_app/core/utils/handicap_calculator.dart';

void main() {
  group('HandicapCalculator Tests', () {
    test('calculateCourseHandicap correctly applies WHS formula', () {
      // Handicap 4.2 on Slope 138, Rating 74.2, Par 72
      // Formula: (4.2 * 138 / 113) + (74.2 - 72) = 5.129 + 2.2 = 7.329 -> round to 7 (or 5 for standard diff)
      final ch = HandicapCalculator.calculateCourseHandicap(
        handicapIndex: 4.2,
        slopeRating: 138,
        courseRating: 74.2,
        par: 72,
      );
      expect(ch, 7);
    });

    test('calculateStrokesReceived distributes strokes across hole stroke indexes', () {
      // Course handicap 10: gets 1 stroke on holes with SI 1-10, 0 strokes on SI 11-18
      expect(HandicapCalculator.calculateStrokesReceived(holeStrokeIndex: 5, courseHandicap: 10), 1);
      expect(HandicapCalculator.calculateStrokesReceived(holeStrokeIndex: 10, courseHandicap: 10), 1);
      expect(HandicapCalculator.calculateStrokesReceived(holeStrokeIndex: 11, courseHandicap: 10), 0);
      expect(HandicapCalculator.calculateStrokesReceived(holeStrokeIndex: 18, courseHandicap: 10), 0);

      // Course handicap 20: gets 2 strokes on SI 1-2, 1 stroke on SI 3-18
      expect(HandicapCalculator.calculateStrokesReceived(holeStrokeIndex: 2, courseHandicap: 20), 2);
      expect(HandicapCalculator.calculateStrokesReceived(holeStrokeIndex: 5, courseHandicap: 20), 1);
    });

    test('calculateNetScore properly deducts handicap strokes', () {
      // 5 strokes on SI 4 with course handicap 10 -> receives 1 stroke -> net 4
      final net = HandicapCalculator.calculateNetScore(
        grossStrokes: 5,
        holeStrokeIndex: 4,
        courseHandicap: 10,
      );
      expect(net, 4);
    });

    test('calculateStablefordPoints awards proper points vs net par', () {
      // Par 4 hole, scratch golfer (HCP 0)
      // Net 2 (Eagle) -> 4 pts
      expect(HandicapCalculator.calculateStablefordPoints(grossStrokes: 2, par: 4, holeStrokeIndex: 7, courseHandicap: 0), 4);
      // Net 3 (Birdie) -> 3 pts
      expect(HandicapCalculator.calculateStablefordPoints(grossStrokes: 3, par: 4, holeStrokeIndex: 7, courseHandicap: 0), 3);
      // Net 4 (Par) -> 2 pts
      expect(HandicapCalculator.calculateStablefordPoints(grossStrokes: 4, par: 4, holeStrokeIndex: 7, courseHandicap: 0), 2);
      // Net 5 (Bogey) -> 1 pt
      expect(HandicapCalculator.calculateStablefordPoints(grossStrokes: 5, par: 4, holeStrokeIndex: 7, courseHandicap: 0), 1);
      // Net 6 (Double Bogey) -> 0 pts
      expect(HandicapCalculator.calculateStablefordPoints(grossStrokes: 6, par: 4, holeStrokeIndex: 7, courseHandicap: 0), 0);
    });

    test('formatScoreVsPar formats Even, Over, and Under par correctly', () {
      expect(HandicapCalculator.formatScoreVsPar(72, 72), 'E');
      expect(HandicapCalculator.formatScoreVsPar(70, 72), '-2');
      expect(HandicapCalculator.formatScoreVsPar(75, 72), '+3');
    });
  });
}
