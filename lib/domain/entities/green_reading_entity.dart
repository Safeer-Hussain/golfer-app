enum GreenBreakDirection { straight, leftToRight, rightToLeft }

class GreenSlopeReading {
  final double slopeDegrees;
  final double
  fallLineHeadingDegrees; // 0° North, 90° East, 180° South, 270° West
  final double stimpSpeed; // 8.0 to 13.0
  final double puttDistanceFeet; // e.g. 10.0 to 50.0 ft
  final double puttHeadingDegrees; // Heading from ball to cup

  const GreenSlopeReading({
    required this.slopeDegrees,
    required this.fallLineHeadingDegrees,
    this.stimpSpeed = 10.5,
    this.puttDistanceFeet = 15.0,
    this.puttHeadingDegrees = 0.0,
  });

  double get slopePercent =>
      slopeDegrees * 1.7455; // tan(theta) * 100 for small angles

  GreenSlopeReading copyWith({
    double? slopeDegrees,
    double? fallLineHeadingDegrees,
    double? stimpSpeed,
    double? puttDistanceFeet,
    double? puttHeadingDegrees,
  }) {
    return GreenSlopeReading(
      slopeDegrees: slopeDegrees ?? this.slopeDegrees,
      fallLineHeadingDegrees:
          fallLineHeadingDegrees ?? this.fallLineHeadingDegrees,
      stimpSpeed: stimpSpeed ?? this.stimpSpeed,
      puttDistanceFeet: puttDistanceFeet ?? this.puttDistanceFeet,
      puttHeadingDegrees: puttHeadingDegrees ?? this.puttHeadingDegrees,
    );
  }
}

class PuttCalculationResult {
  final double physicalDistanceFeet;
  final double playsLikeDistanceFeet;
  final double distanceAdjustmentFeet;
  final double lateralBreakInches;
  final double lateralBreakCups;
  final GreenBreakDirection breakDirection;
  final double relativeAngleDegrees;
  final String aimDescription;
  final String speedDescription;
  final String captureSpeedAdvice;

  const PuttCalculationResult({
    required this.physicalDistanceFeet,
    required this.playsLikeDistanceFeet,
    required this.distanceAdjustmentFeet,
    required this.lateralBreakInches,
    required this.lateralBreakCups,
    required this.breakDirection,
    required this.relativeAngleDegrees,
    required this.aimDescription,
    required this.speedDescription,
    required this.captureSpeedAdvice,
  });
}
