import '../../data/models/club_model.dart';
import '../entities/hole_entity.dart';

class CaddieRecommendation {
  final ClubModel recommendedClub;
  final int rawYardage;
  final int playsLikeYardage;
  final int windAdjustmentYards;
  final int elevationAdjustmentYards;
  final String aimLineAdjustment;
  final String strategyNotes;
  final double dispersionConeDegrees;

  const CaddieRecommendation({
    required this.recommendedClub,
    required this.rawYardage,
    required this.playsLikeYardage,
    required this.windAdjustmentYards,
    required this.elevationAdjustmentYards,
    required this.aimLineAdjustment,
    required this.strategyNotes,
    required this.dispersionConeDegrees,
  });
}

class CaddieStrategyUseCase {
  CaddieRecommendation evaluateShot({
    required HoleEntity hole,
    required String teeBox,
    required List<ClubModel> bag,
    int? overrideTargetDistance,
  }) {
    final rawYardage = overrideTargetDistance ?? hole.yardageForTee(teeBox);

    // Wind adjustment: 1 mph headwind adds approx 0.9 yard; tailwind subtracts 0.6 yard
    int windAdj = 0;
    String aimLine = 'Aim directly down target flagline.';
    if (hole.windDirection.contains('N') || hole.windDirection.contains('NE') || hole.windDirection.contains('NW')) {
      windAdj = (hole.windSpeedMph * 0.85).round();
      aimLine = 'Prevailing headwind. Keep trajectory low with smooth tempo.';
    } else if (hole.windDirection.contains('S') || hole.windDirection.contains('SE') || hole.windDirection.contains('SW')) {
      windAdj = -(hole.windSpeedMph * 0.6).round();
      aimLine = 'Downwind assistance. Allow for extra rollout on firm green.';
    }

    if (hole.windDirection.contains('E')) {
      aimLine = 'Crosswind from right to left. Hold target 5 yards right of pin.';
    } else if (hole.windDirection.contains('W')) {
      aimLine = 'Crosswind from left to right. Start ball 6 yards left of center.';
    }

    // Elevation adjustment: 3 feet = approx 1 yard
    final elevAdj = (hole.elevationChangeFeet / 3.0).round();

    final playsLike = rawYardage + windAdj + elevAdj;

    // Find best matching club from bag
    ClubModel bestClub = bag.first;
    int minDiff = 9999;

    for (final club in bag) {
      if (club.category == 'Putter') continue;
      final diff = (club.carryYards - playsLike).abs();
      if (diff < minDiff) {
        minDiff = diff;
        bestClub = club;
      }
    }

    String notes;
    if (hole.par == 3) {
      notes = 'Par 3 approach. Focus on clean contact. Green center leaves a manageable two-putt.';
    } else if (hole.par == 5 && playsLike > 480) {
      notes = 'Three-shot strategy advised. Place layup at comfortable 100-yard wedge distance to avoid bunker clusters.';
    } else {
      notes = 'Target fairway landing zone. Take one extra club if gripping down for control.';
    }

    return CaddieRecommendation(
      recommendedClub: bestClub,
      rawYardage: rawYardage,
      playsLikeYardage: playsLike,
      windAdjustmentYards: windAdj,
      elevationAdjustmentYards: elevAdj,
      aimLineAdjustment: aimLine,
      strategyNotes: '$notes ${hole.hazardsDescription}',
      dispersionConeDegrees: 4.5,
    );
  }
}
