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

  HoleEntity getHole(int holeNumber) {
    return holes.firstWhere(
      (h) => h.holeNumber == holeNumber,
      orElse: () => holes.first,
    );
  }
}
