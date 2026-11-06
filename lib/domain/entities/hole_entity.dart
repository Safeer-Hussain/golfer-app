import 'package:latlong2/latlong.dart';

class HoleEntity {
  final int holeNumber;
  final int par;
  final int strokeIndex;
  final int yardageBlack;
  final int yardageBlue;
  final int yardageWhite;
  final int yardageRed;
  final LatLng teeLocation;
  final LatLng targetLocation;
  final LatLng greenLocation;
  final LatLng frontPinLocation;
  final LatLng backPinLocation;
  final int elevationChangeFeet;
  final double windSpeedMph;
  final String windDirection;
  final String hazardsDescription;

  const HoleEntity({
    required this.holeNumber,
    required this.par,
    required this.strokeIndex,
    required this.yardageBlack,
    required this.yardageBlue,
    required this.yardageWhite,
    required this.yardageRed,
    required this.teeLocation,
    required this.targetLocation,
    required this.greenLocation,
    required this.frontPinLocation,
    required this.backPinLocation,
    this.elevationChangeFeet = 0,
    this.windSpeedMph = 10.0,
    this.windDirection = 'NW 10 mph',
    this.hazardsDescription = 'Fairway bunker right, green guarded by sand.',
  });

  int yardageForTee(String tee) {
    if (tee.contains('Black')) return yardageBlack;
    if (tee.contains('Blue')) return yardageBlue;
    if (tee.contains('White')) return yardageWhite;
    return yardageRed;
  }
}
