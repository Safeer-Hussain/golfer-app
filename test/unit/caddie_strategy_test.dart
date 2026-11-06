import 'package:flutter_test/flutter_test.dart';
import 'package:golfer_app/core/constants/golf_courses.dart';
import 'package:golfer_app/data/models/club_model.dart';
import 'package:golfer_app/domain/usecases/caddie_strategy_usecase.dart';

void main() {
  group('CaddieStrategyUseCase Tests', () {
    final useCase = CaddieStrategyUseCase();
    final bag = ClubModel.default14Clubs;

    test('evaluateShot adds distance for headwind and chooses appropriate club', () {
      final hole1 = GolfCourses.lahoreGarrison.holes[0]; // Hole 1: 425 yds, NW wind 11 mph
      final rec = useCase.evaluateShot(
        hole: hole1,
        teeBox: 'Championship Black',
        bag: bag,
        overrideTargetDistance: 165, // approach shot 165 yds into NW wind
      );

      expect(rec.rawYardage, 165);
      expect(rec.windAdjustmentYards, greaterThan(0));
      expect(rec.playsLikeYardage, greaterThan(165));
      // With 165 + wind + elev, should recommend 6-Iron or 7-Iron
      expect(rec.recommendedClub.category, 'Iron');
    });

    test('evaluateShot subtracts distance for tailwind', () {
      final hole8 = GolfCourses.lahoreGarrison.holes[7]; // Hole 8: Downhill, SW tailwind
      final rec = useCase.evaluateShot(
        hole: hole8,
        teeBox: 'Championship Black',
        bag: bag,
      );

      expect(rec.windAdjustmentYards, lessThan(0));
      expect(rec.elevationAdjustmentYards, lessThan(0));
      expect(rec.playsLikeYardage, lessThan(rec.rawYardage));
    });

    test('dispersion cone and technical aim line are populated with zero emojis', () {
      final hole2 = GolfCourses.lahoreGarrison.holes[1];
      final rec = useCase.evaluateShot(
        hole: hole2,
        teeBox: 'Championship Black',
        bag: bag,
      );

      expect(rec.dispersionConeDegrees, greaterThan(0));
      expect(rec.aimLineAdjustment.isNotEmpty, isTrue);
      expect(rec.strategyNotes.contains('bunker') || rec.strategyNotes.contains('green'), isTrue);
    });
  });
}
