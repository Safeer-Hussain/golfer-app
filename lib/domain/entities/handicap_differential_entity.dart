class HoleScoreAdjustment {
  final int holeNumber;
  final int par;
  final int strokeIndex;
  final int strokesReceived;
  final int rawStrokes;
  final int maxNetDoubleBogey;
  final int adjustedStrokes;
  final bool wasTruncated;

  const HoleScoreAdjustment({
    required this.holeNumber,
    required this.par,
    required this.strokeIndex,
    required this.strokesReceived,
    required this.rawStrokes,
    required this.maxNetDoubleBogey,
    required this.adjustedStrokes,
    required this.wasTruncated,
  });

  int get strokesShaved => rawStrokes - adjustedStrokes;
}

class ScoreDifferentialResult {
  final int rawGrossScore;
  final int adjustedGrossScore;
  final double courseRating;
  final int slopeRating;
  final double pcc; // Playing Conditions Calculation (-1.0 to +3.0)
  final double scoreDifferential;
  final bool isExceptionalScore;
  final double esrAdjustment; // -1.0 or -2.0 if exceptional
  final int holesAdjustedCount;
  final int totalStrokesShaved;
  final List<HoleScoreAdjustment> holeAdjustments;

  const ScoreDifferentialResult({
    required this.rawGrossScore,
    required this.adjustedGrossScore,
    required this.courseRating,
    required this.slopeRating,
    required this.pcc,
    required this.scoreDifferential,
    required this.isExceptionalScore,
    required this.esrAdjustment,
    required this.holesAdjustedCount,
    required this.totalStrokesShaved,
    required this.holeAdjustments,
  });
}

class HistoricalRoundScore {
  final String id;
  final DateTime date;
  final String courseName;
  final String teeBox;
  final int rawGross;
  final int adjustedGross;
  final double differential;
  final bool isCountedInBest8;

  const HistoricalRoundScore({
    required this.id,
    required this.date,
    required this.courseName,
    required this.teeBox,
    required this.rawGross,
    required this.adjustedGross,
    required this.differential,
    this.isCountedInBest8 = false,
  });

  HistoricalRoundScore copyWith({
    String? id,
    DateTime? date,
    String? courseName,
    String? teeBox,
    int? rawGross,
    int? adjustedGross,
    double? differential,
    bool? isCountedInBest8,
  }) {
    return HistoricalRoundScore(
      id: id ?? this.id,
      date: date ?? this.date,
      courseName: courseName ?? this.courseName,
      teeBox: teeBox ?? this.teeBox,
      rawGross: rawGross ?? this.rawGross,
      adjustedGross: adjustedGross ?? this.adjustedGross,
      differential: differential ?? this.differential,
      isCountedInBest8: isCountedInBest8 ?? this.isCountedInBest8,
    );
  }
}

class HandicapIndexCalculation {
  final int totalRoundsSubmitted;
  final int countingRoundsCount;
  final double bestAverage;
  final double rawCalculatedIndex;
  final double lowHandicapIndex365;
  final bool softCapApplied;
  final bool hardCapApplied;
  final double finalHandicapIndex;
  final List<HistoricalRoundScore> rankedRounds;

  const HandicapIndexCalculation({
    required this.totalRoundsSubmitted,
    required this.countingRoundsCount,
    required this.bestAverage,
    required this.rawCalculatedIndex,
    required this.lowHandicapIndex365,
    required this.softCapApplied,
    required this.hardCapApplied,
    required this.finalHandicapIndex,
    required this.rankedRounds,
  });
}
