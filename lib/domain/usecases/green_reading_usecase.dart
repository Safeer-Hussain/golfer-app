import 'dart:math' as math;
import '../entities/green_reading_entity.dart';

class GreenReadingUseCase {
  static const double standardCupDiameterInches = 4.25;

  PuttCalculationResult calculatePuttBreak({
    required double slopeDegrees,
    required double fallLineHeadingDegrees,
    required double stimpSpeed,
    required double puttDistanceFeet,
    required double puttHeadingDegrees,
  }) {
    // Relative angle between fall line and putt trajectory
    // 0° = straight downhill along fall line
    // 180° = straight uphill against fall line
    // 90° = cross-slope with fall line to the right (left-to-right break)
    // -90° (or 270°) = cross-slope with fall line to the left (right-to-left break)
    double rawAngleDiff = fallLineHeadingDegrees - puttHeadingDegrees;
    while (rawAngleDiff > 180.0) {
      rawAngleDiff -= 360.0;
    }
    while (rawAngleDiff < -180.0) {
      rawAngleDiff += 360.0;
    }

    final rad = rawAngleDiff * math.pi / 180.0;
    final slopePercent = slopeDegrees * 1.7455; // tan(slope) * 100 approx

    // Longitudinal elevation factor: cos(0) = 1 (downhill), cos(pi) = -1 (uphill)
    final longitudinalComponent = math.cos(rad);
    // Lateral cross-slope factor: sin(pi/2) = 1 (L to R), sin(-pi/2) = -1 (R to L)
    final lateralComponent = math.sin(rad);

    // Stimp scaling factor normalized around country club average of 10.0 stimp
    final stimpFactor = stimpSpeed / 10.0;

    // 1. Longitudinal Distance Adjustment (Plays Like)
    // Downhill putts roll farther (plays shorter); uphill putts roll shorter (plays longer)
    final gradeEffect = (slopePercent / 100.0) * stimpFactor * 2.2;
    double playsLike = puttDistanceFeet * (1.0 - (longitudinalComponent * gradeEffect));
    // Physical safety clamp: cannot play less than 35% of distance even on severe slopes
    if (playsLike < puttDistanceFeet * 0.35) {
      playsLike = puttDistanceFeet * 0.35;
    }

    final distanceAdjustment = playsLike - puttDistanceFeet;

    // 2. Lateral Break Calculation (inches of deflection from cup center)
    // Deflection increases with slope%, cross-factor, stimp speed, and non-linearly with distance
    final distancePowerFactor = math.pow(puttDistanceFeet / 10.0, 1.35).toDouble();
    final rawBreakInches = slopePercent * lateralComponent.abs() * stimpFactor * distancePowerFactor * 2.6;
    final breakCups = rawBreakInches / standardCupDiameterInches;

    GreenBreakDirection direction;
    if (lateralComponent > 0.04) {
      direction = GreenBreakDirection.leftToRight;
    } else if (lateralComponent < -0.04) {
      direction = GreenBreakDirection.rightToLeft;
    } else {
      direction = GreenBreakDirection.straight;
    }

    // 3. Technical Caddie Recommendations
    String aimDesc;
    if (direction == GreenBreakDirection.leftToRight) {
      aimDesc = 'Aim ${rawBreakInches.toStringAsFixed(1)} in (${breakCups.toStringAsFixed(1)} cups) left of cup center.';
    } else if (direction == GreenBreakDirection.rightToLeft) {
      aimDesc = 'Aim ${rawBreakInches.toStringAsFixed(1)} in (${breakCups.toStringAsFixed(1)} cups) right of cup center.';
    } else {
      aimDesc = 'Dead center flagstick line. Zero lateral break.';
    }

    String speedDesc;
    if (distanceAdjustment > 0.3) {
      speedDesc = 'Uphill putt: Hit with ${playsLike.toStringAsFixed(1)} ft speed (+${distanceAdjustment.toStringAsFixed(1)} ft effort).';
    } else if (distanceAdjustment < -0.3) {
      speedDesc = 'Downhill putt: Hit with ${playsLike.toStringAsFixed(1)} ft speed (${distanceAdjustment.toStringAsFixed(1)} ft touch).';
    } else {
      speedDesc = 'Level elevation: Hit with standard ${puttDistanceFeet.toStringAsFixed(1)} ft roll speed.';
    }

    String captureAdvice;
    if (stimpSpeed >= 12.0) {
      captureAdvice = 'Fast green (${stimpSpeed.toStringAsFixed(1)} stimp): Prioritize die-in speed to maximize 360-degree hole capture width.';
    } else if (distanceAdjustment < -2.0) {
      captureAdvice = 'Steep downhill: Favor low side safety margin; an aggressive stroke risks a 4-foot return putt.';
    } else if (distanceAdjustment > 2.0) {
      captureAdvice = 'Uphill stroke: Firm acceleration through impact into back cup wall eliminates subtle grain breaks.';
    } else {
      captureAdvice = 'Target 12-18 inches rollout past hole for optimum capture probability.';
    }

    return PuttCalculationResult(
      physicalDistanceFeet: puttDistanceFeet,
      playsLikeDistanceFeet: playsLike,
      distanceAdjustmentFeet: distanceAdjustment,
      lateralBreakInches: rawBreakInches,
      lateralBreakCups: breakCups,
      breakDirection: direction,
      relativeAngleDegrees: rawAngleDiff,
      aimDescription: aimDesc,
      speedDescription: speedDesc,
      captureSpeedAdvice: captureAdvice,
    );
  }
}
