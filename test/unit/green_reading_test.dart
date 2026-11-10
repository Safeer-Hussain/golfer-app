import 'package:flutter_test/flutter_test.dart';
import 'package:golfer_app/domain/entities/green_reading_entity.dart';
import 'package:golfer_app/domain/usecases/green_reading_usecase.dart';
import 'package:golfer_app/presentation/green_reading/green_reading_controller.dart';

void main() {
  late GreenReadingUseCase useCase;

  setUp(() {
    useCase = GreenReadingUseCase();
  });

  group('GreenReadingUseCase Physics Tests', () {
    test('Uphill putt increases plays-like distance (requires firmer stroke)', () {
      // Putt North (0°), Fall Line South (180°) -> Straight uphill
      final result = useCase.calculatePuttBreak(
        slopeDegrees: 2.0,
        fallLineHeadingDegrees: 180.0,
        stimpSpeed: 10.0,
        puttDistanceFeet: 20.0,
        puttHeadingDegrees: 0.0,
      );

      expect(result.breakDirection, equals(GreenBreakDirection.straight));
      expect(result.playsLikeDistanceFeet, greaterThan(result.physicalDistanceFeet));
      expect(result.distanceAdjustmentFeet, greaterThan(0));
      expect(result.lateralBreakInches, lessThan(0.5));
      expect(result.speedDescription, contains('Uphill'));
    });

    test('Downhill putt decreases plays-like distance (requires softer touch)', () {
      // Putt North (0°), Fall Line North (0°) -> Straight downhill
      final result = useCase.calculatePuttBreak(
        slopeDegrees: 2.0,
        fallLineHeadingDegrees: 0.0,
        stimpSpeed: 10.0,
        puttDistanceFeet: 20.0,
        puttHeadingDegrees: 0.0,
      );

      expect(result.breakDirection, equals(GreenBreakDirection.straight));
      expect(result.playsLikeDistanceFeet, lessThan(result.physicalDistanceFeet));
      expect(result.distanceAdjustmentFeet, lessThan(0));
      expect(result.speedDescription, contains('Downhill'));
    });

    test('Cross-slope East fall line produces left-to-right break with left aim', () {
      // Putt North (0°), Fall Line East (90°) -> Cross slope falling right
      // Ball breaks to the right (leftToRight); aim must be left of cup
      final result = useCase.calculatePuttBreak(
        slopeDegrees: 2.5,
        fallLineHeadingDegrees: 90.0,
        stimpSpeed: 10.5,
        puttDistanceFeet: 15.0,
        puttHeadingDegrees: 0.0,
      );

      expect(result.breakDirection, equals(GreenBreakDirection.leftToRight));
      expect(result.lateralBreakInches, greaterThan(0));
      expect(result.lateralBreakCups, greaterThan(0));
      expect(result.aimDescription, contains('left of cup'));
    });

    test('Cross-slope West fall line produces right-to-left break with right aim', () {
      // Putt North (0°), Fall Line West (270°) -> Cross slope falling left
      // Ball breaks to the left (rightToLeft); aim must be right of cup
      final result = useCase.calculatePuttBreak(
        slopeDegrees: 2.5,
        fallLineHeadingDegrees: 270.0,
        stimpSpeed: 10.5,
        puttDistanceFeet: 15.0,
        puttHeadingDegrees: 0.0,
      );

      expect(result.breakDirection, equals(GreenBreakDirection.rightToLeft));
      expect(result.lateralBreakInches, greaterThan(0));
      expect(result.lateralBreakCups, greaterThan(0));
      expect(result.aimDescription, contains('right of cup'));
    });

    test('Higher Stimp speed increases lateral break deflection', () {
      final slowGreen = useCase.calculatePuttBreak(
        slopeDegrees: 2.0,
        fallLineHeadingDegrees: 90.0,
        stimpSpeed: 9.0,
        puttDistanceFeet: 20.0,
        puttHeadingDegrees: 0.0,
      );

      final fastGreen = useCase.calculatePuttBreak(
        slopeDegrees: 2.0,
        fallLineHeadingDegrees: 90.0,
        stimpSpeed: 13.0,
        puttDistanceFeet: 20.0,
        puttHeadingDegrees: 0.0,
      );

      expect(fastGreen.lateralBreakInches, greaterThan(slowGreen.lateralBreakInches));
      expect(fastGreen.lateralBreakCups, greaterThan(slowGreen.lateralBreakCups));
      expect(fastGreen.captureSpeedAdvice, contains('Fast green'));
    });

    test('Standard cup width is 4.25 inches in conversion', () {
      final result = useCase.calculatePuttBreak(
        slopeDegrees: 1.5,
        fallLineHeadingDegrees: 90.0,
        stimpSpeed: 10.0,
        puttDistanceFeet: 10.0,
        puttHeadingDegrees: 0.0,
      );

      final expectedCups = result.lateralBreakInches / 4.25;
      expect(result.lateralBreakCups, closeTo(expectedCups, 0.001));
    });
  });

  group('GreenReadingController State Tests', () {
    late GreenReadingController controller;

    setUp(() {
      controller = GreenReadingController(useCase);
    });

    test('Initial reading defaults to country club standard', () {
      expect(controller.reading.slopeDegrees, equals(1.5));
      expect(controller.reading.stimpSpeed, equals(10.5));
      expect(controller.reading.puttDistanceFeet, equals(15.0));
      expect(controller.calculationResult, isNotNull);
    });

    test('applyPreset updates all values and notifies listeners', () {
      var notified = false;
      controller.addListener(() => notified = true);

      controller.applyPreset(
        slopeDegrees: 3.5,
        fallLineHeading: 180.0,
        stimpSpeed: 12.0,
        puttDistance: 25.0,
      );

      expect(notified, isTrue);
      expect(controller.reading.slopeDegrees, equals(3.5));
      expect(controller.reading.fallLineHeadingDegrees, equals(180.0));
      expect(controller.reading.stimpSpeed, equals(12.0));
      expect(controller.reading.puttDistanceFeet, equals(25.0));
    });

    test('Input clamping prevents invalid slope, stimp and distance values', () {
      controller.setSlopeDegrees(10.0);
      expect(controller.reading.slopeDegrees, equals(6.0));

      controller.setSlopeDegrees(-2.0);
      expect(controller.reading.slopeDegrees, equals(0.0));

      controller.setStimpSpeed(16.0);
      expect(controller.reading.stimpSpeed, equals(13.5));

      controller.setStimpSpeed(5.0);
      expect(controller.reading.stimpSpeed, equals(8.0));

      controller.setPuttDistance(100.0);
      expect(controller.reading.puttDistanceFeet, equals(60.0));

      controller.setPuttDistance(1.0);
      expect(controller.reading.puttDistanceFeet, equals(3.0));
    });
  });
}
