class HandicapCalculator {
  static int calculateCourseHandicap({
    required double handicapIndex,
    required int slopeRating,
    required double courseRating,
    required int par,
  }) {
    final slope = slopeRating / 113.0;
    final ratingDiff = courseRating - par;
    return (handicapIndex * slope + ratingDiff).round();
  }

  static int calculateStrokesReceived({
    required int holeStrokeIndex,
    required int courseHandicap,
  }) {
    if (courseHandicap == 0) return 0;
    if (courseHandicap > 0) {
      final base = courseHandicap ~/ 18;
      final remainder = courseHandicap % 18;
      final extra = (holeStrokeIndex <= remainder) ? 1 : 0;
      return base + extra;
    } else {
      // Plus handicap golfer gives strokes back on lowest stroke indexes
      final positiveHandicap = courseHandicap.abs();
      final base = positiveHandicap ~/ 18;
      final remainder = positiveHandicap % 18;
      final strokeDeducted = (holeStrokeIndex > (18 - remainder)) ? 1 : 0;
      return -(base + strokeDeducted);
    }
  }

  static int calculateNetScore({
    required int grossStrokes,
    required int holeStrokeIndex,
    required int courseHandicap,
  }) {
    final handicapStrokes = calculateStrokesReceived(
      holeStrokeIndex: holeStrokeIndex,
      courseHandicap: courseHandicap,
    );
    return grossStrokes - handicapStrokes;
  }

  static int calculateStablefordPoints({
    required int grossStrokes,
    required int par,
    required int holeStrokeIndex,
    required int courseHandicap,
  }) {
    final netScore = calculateNetScore(
      grossStrokes: grossStrokes,
      holeStrokeIndex: holeStrokeIndex,
      courseHandicap: courseHandicap,
    );

    final diff = netScore - par;
    if (diff <= -3) return 5; // Albatross or better
    if (diff == -2) return 4; // Eagle
    if (diff == -1) return 3; // Birdie
    if (diff == 0) return 2; // Par
    if (diff == 1) return 1; // Bogey
    return 0; // Double bogey or worse
  }

  static String formatScoreVsPar(int totalStrokes, int totalPar) {
    final diff = totalStrokes - totalPar;
    if (diff == 0) return 'E';
    if (diff > 0) return '+$diff';
    return '$diff';
  }
}
