import 'dart:math' as math;

import '../../core/utils/handicap_calculator.dart';
import '../entities/handicap_differential_entity.dart';
import '../entities/hole_entity.dart';

class HandicapDifferentialUseCase {
  int calculateNetDoubleBogey({
    required int par,
    required int strokesReceived,
  }) {
    return par + 2 + strokesReceived;
  }

  ScoreDifferentialResult calculateScoreDifferential({
    required List<HoleEntity> holes,
    required List<int> rawHoleStrokes,
    required int courseHandicap,
    required double courseRating,
    required int slopeRating,
    double pcc = 0.0,
    double? playerHandicapIndex,
  }) {
    assert(holes.length == rawHoleStrokes.length);

    int rawGrossTotal = 0;
    int adjustedGrossTotal = 0;
    int truncatedCount = 0;
    final holeAdjustments = <HoleScoreAdjustment>[];

    for (var i = 0; i < holes.length; i++) {
      final hole = holes[i];
      final raw = rawHoleStrokes[i];
      rawGrossTotal += raw;

      final strokesReceived = HandicapCalculator.calculateStrokesReceived(
        holeStrokeIndex: hole.strokeIndex,
        courseHandicap: courseHandicap,
      );

      final maxNdb = calculateNetDoubleBogey(
        par: hole.par,
        strokesReceived: strokesReceived,
      );

      final wasTruncated = raw > maxNdb;
      final adjusted = wasTruncated ? maxNdb : raw;
      if (wasTruncated) {
        truncatedCount++;
      }
      adjustedGrossTotal += adjusted;

      holeAdjustments.add(
        HoleScoreAdjustment(
          holeNumber: hole.holeNumber,
          par: hole.par,
          strokeIndex: hole.strokeIndex,
          strokesReceived: strokesReceived,
          rawStrokes: raw,
          maxNetDoubleBogey: maxNdb,
          adjustedStrokes: adjusted,
          wasTruncated: wasTruncated,
        ),
      );
    }

    final safeSlope = slopeRating > 0 ? slopeRating : 113;
    final rawDiff =
        (113.0 / safeSlope) * (adjustedGrossTotal - courseRating - pcc);
    final roundedDiff = (rawDiff * 10).round() / 10.0;

    bool isExceptional = false;
    double esrAdjustment = 0.0;

    if (playerHandicapIndex != null) {
      final drop = playerHandicapIndex - roundedDiff;
      if (drop >= 10.0) {
        isExceptional = true;
        esrAdjustment = -2.0;
      } else if (drop >= 7.0) {
        isExceptional = true;
        esrAdjustment = -1.0;
      }
    }

    return ScoreDifferentialResult(
      rawGrossScore: rawGrossTotal,
      adjustedGrossScore: adjustedGrossTotal,
      courseRating: courseRating,
      slopeRating: safeSlope,
      pcc: pcc,
      scoreDifferential: roundedDiff,
      isExceptionalScore: isExceptional,
      esrAdjustment: esrAdjustment,
      holesAdjustedCount: truncatedCount,
      totalStrokesShaved: rawGrossTotal - adjustedGrossTotal,
      holeAdjustments: holeAdjustments,
    );
  }

  HandicapIndexCalculation calculateHandicapIndexFromRounds(
    List<HistoricalRoundScore> rounds, {
    double? lowHandicapIndex365,
  }) {
    if (rounds.isEmpty) {
      return const HandicapIndexCalculation(
        totalRoundsSubmitted: 0,
        countingRoundsCount: 0,
        bestAverage: 0.0,
        rawCalculatedIndex: 0.0,
        lowHandicapIndex365: 0.0,
        softCapApplied: false,
        hardCapApplied: false,
        finalHandicapIndex: 0.0,
        rankedRounds: [],
      );
    }

    // Sort by lowest differential ascending
    final sortedByDiff = List<HistoricalRoundScore>.from(rounds)
      ..sort((a, b) => a.differential.compareTo(b.differential));

    final totalCount = rounds.length;
    final int countingCount;
    double adjustment = 0.0;

    if (totalCount >= 20) {
      countingCount = 8;
    } else if (totalCount >= 15) {
      countingCount = 6;
    } else if (totalCount >= 12) {
      countingCount = 5;
    } else if (totalCount >= 9) {
      countingCount = 4;
    } else if (totalCount >= 7) {
      countingCount = 3;
    } else if (totalCount == 6) {
      countingCount = 2;
      adjustment = -1.0;
    } else if (totalCount == 5) {
      countingCount = 1;
    } else if (totalCount == 4) {
      countingCount = 1;
      adjustment = -1.0;
    } else {
      countingCount = 1;
      adjustment = -2.0;
    }

    final countingRounds = sortedByDiff.take(countingCount).toList();
    final countingIds = countingRounds.map((r) => r.id).toSet();

    final sum = countingRounds.fold<double>(
      0.0,
      (acc, r) => acc + r.differential,
    );
    final rawAverage = (sum / countingCount) + adjustment;
    final bestAverage = (rawAverage * 10).round() / 10.0;

    double calculatedIndex = bestAverage;
    bool softCap = false;
    bool hardCap = false;

    if (lowHandicapIndex365 != null) {
      final softCapThreshold = lowHandicapIndex365 + 3.0;
      final hardCapThreshold = lowHandicapIndex365 + 5.0;

      if (calculatedIndex > softCapThreshold) {
        softCap = true;
        final excess = calculatedIndex - softCapThreshold;
        calculatedIndex = softCapThreshold + (excess * 0.5);

        if (calculatedIndex > hardCapThreshold) {
          hardCap = true;
          calculatedIndex = hardCapThreshold;
        }
      }
    }

    final finalIndex = math.max(
      -5.0,
      math.min(54.0, (calculatedIndex * 10).round() / 10.0),
    );

    // Return all original rounds with flag for counting best 8
    final rankedRounds = rounds.map((r) {
      return r.copyWith(isCountedInBest8: countingIds.contains(r.id));
    }).toList();

    return HandicapIndexCalculation(
      totalRoundsSubmitted: totalCount,
      countingRoundsCount: countingCount,
      bestAverage: bestAverage,
      rawCalculatedIndex: bestAverage,
      lowHandicapIndex365: lowHandicapIndex365 ?? finalIndex,
      softCapApplied: softCap,
      hardCapApplied: hardCap,
      finalHandicapIndex: finalIndex,
      rankedRounds: rankedRounds,
    );
  }
}
