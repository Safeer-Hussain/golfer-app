import 'hole_entity.dart';

class CourseEntity {
  final String id;
  final String name;
  final String location;
  final int par;
  final int totalYardage;
  final double rating;
  final int slope;
  final String imageAsset;
  final List<HoleEntity> holes;

  const CourseEntity({
    required this.id,
    required this.name,
    required this.location,
    required this.par,
    required this.totalYardage,
    required this.rating,
    required this.slope,
    required this.imageAsset,
    required this.holes,
  });

  int get totalPar => par;

  double ratingForTee(String teeBox) {
    switch (teeBox.toLowerCase()) {
      case 'black':
        return rating;
      case 'blue':
        return rating - 1.4;
      case 'white':
        return rating - 2.8;
      case 'red':
        return rating - 5.0;
      default:
        return rating;
    }
  }

  int slopeForTee(String teeBox) {
    switch (teeBox.toLowerCase()) {
      case 'black':
        return slope;
      case 'blue':
        return slope - 4;
      case 'white':
        return slope - 8;
      case 'red':
        return slope - 15;
      default:
        return slope;
    }
  }

  HoleEntity getHole(int holeNumber) {
    return holes.firstWhere(
      (h) => h.holeNumber == holeNumber,
      orElse: () => holes.first,
    );
  }
}
