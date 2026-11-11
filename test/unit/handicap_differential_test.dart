import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golfer_app/core/constants/golf_courses.dart';
import 'package:golfer_app/core/di/service_locator.dart';
import 'package:golfer_app/domain/entities/handicap_differential_entity.dart';
import 'package:golfer_app/domain/usecases/handicap_differential_usecase.dart';
import 'package:golfer_app/presentation/handicap_differential/handicap_differential_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late HandicapDifferentialUseCase useCase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/connectivity'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'check') {
              return ['wifi'];
            }
            return null;
          },
        );
  });

  setUp(() {
    useCase = HandicapDifferentialUseCase();
  });

  group('HandicapDifferentialUseCase - Net Double Bogey', () {
    test('Calculates Net Double Bogey correctly for various pars and strokes received', () {
      // Par 4 with 0 strokes received -> 6
      expect(
        useCase.calculateNetDoubleBogey(par: 4, strokesReceived: 0),
        equals(6),
      );
      // Par 5 with 1 stroke received -> 8
      expect(
        useCase.calculateNetDoubleBogey(par: 5, strokesReceived: 1),
        equals(8),
      );
      // Par 3 with 2 strokes received -> 7
      expect(
        useCase.calculateNetDoubleBogey(par: 3, strokesReceived: 2),
        equals(7),
      );
    });
  });

  group('HandicapDifferentialUseCase - Score Differential & ESC', () {
    final holes = GolfCourses.lahoreGarrison.holes.take(4).toList();

    test(
      'Truncates blowup hole scores to Net Double Bogey and shaves strokes',
      () {
        // Hole 1: Par 4, SI 7
        // Hole 2: Par 5, SI 3
        // Hole 3: Par 3, SI 17
        // Hole 4: Par 4, SI 9
        // Course Handicap 3: strokes received on SI 3, 7, 9 (Holes 1, 2, 4 get 1 stroke; Hole 3 gets 0 strokes)
        // Hole 1: Par 4, rec 0 -> max NDB = 6. Raw = 10 -> adj = 6 (4 shaved)
        // Hole 2: Par 5, rec 1 -> max NDB = 8. Raw = 5 -> adj = 5 (0 shaved)
        // Hole 3: Par 3, rec 0 -> max NDB = 5. Raw = 8 -> adj = 5 (3 shaved)
        // Hole 4: Par 4, rec 1 -> max NDB = 7. Raw = 5 -> adj = 5 (0 shaved)
        final rawStrokes = [
          10,
          5,
          8,
          5,
        ]; // raw total = 28, adj total = 6+5+5+5 = 21

        final result = useCase.calculateScoreDifferential(
          holes: holes,
          rawHoleStrokes: rawStrokes,
          courseHandicap: 3,
          courseRating: 72.0,
          slopeRating: 113,
          pcc: 0.0,
        );

        expect(result.rawGrossScore, equals(28));
        expect(result.adjustedGrossScore, equals(21));
        expect(result.totalStrokesShaved, equals(7));
        expect(result.holesAdjustedCount, equals(2));
        expect(result.holeAdjustments[0].wasTruncated, isTrue);
        expect(result.holeAdjustments[0].adjustedStrokes, equals(6));
        expect(result.holeAdjustments[2].wasTruncated, isTrue);
        expect(result.holeAdjustments[2].adjustedStrokes, equals(5));
        expect(result.holeAdjustments[1].wasTruncated, isFalse);
        expect(result.holeAdjustments[3].wasTruncated, isFalse);
      },
    );

    test('Calculates WHS Score Differential with 113 slope rating baseline and PCC', () {
      final courseHoles = GolfCourses.lahoreGarrison.holes;
      final rawStrokes = courseHoles.map((h) => h.par).toList();
      final totalPar = courseHoles.fold<int>(0, (acc, h) => acc + h.par);

      final result = useCase.calculateScoreDifferential(
        holes: courseHoles,
        rawHoleStrokes: rawStrokes,
        courseHandicap: 0,
        courseRating: 72.0,
        slopeRating: 113,
        pcc: 0.0,
      );

      // (113 / 113) * (72 - 72.0 - 0.0) = 0.0
      expect(result.scoreDifferential, equals(0.0));
      expect(result.rawGrossScore, equals(totalPar));
      expect(result.adjustedGrossScore, equals(totalPar));
      expect(result.totalStrokesShaved, equals(0));

      // With PCC = +1.0 (harder conditions) -> (72 - 72.0 - 1.0) = -1.0
      final resultPcc = useCase.calculateScoreDifferential(
        holes: courseHoles,
        rawHoleStrokes: rawStrokes,
        courseHandicap: 0,
        courseRating: 72.0,
        slopeRating: 113,
        pcc: 1.0,
      );
      expect(resultPcc.scoreDifferential, equals(-1.0));
    });

    test('Exceptional Score Reduction triggers at 7.0 and 10.0 thresholds', () {
      final courseHoles = GolfCourses.lahoreGarrison.holes;
      final rawStrokes = courseHoles.map((h) => h.par).toList();

      // Case 1: Player index is 12.0, differential is 4.0 -> drop is 8.0 >= 7.0 -> ESR -1.0
      final esr1 = useCase.calculateScoreDifferential(
        holes: courseHoles,
        rawHoleStrokes: rawStrokes,
        courseHandicap: 10,
        courseRating: 68.0,
        slopeRating: 113,
        playerHandicapIndex: 12.0,
      );
      expect(esr1.isExceptionalScore, isTrue);
      expect(esr1.esrAdjustment, equals(-1.0));

      // Case 2: Player index is 15.0, differential is 4.0 -> drop is 11.0 >= 10.0 -> ESR -2.0
      final esr2 = useCase.calculateScoreDifferential(
        holes: courseHoles,
        rawHoleStrokes: rawStrokes,
        courseHandicap: 10,
        courseRating: 68.0,
        slopeRating: 113,
        playerHandicapIndex: 15.0,
      );
      expect(esr2.isExceptionalScore, isTrue);
      expect(esr2.esrAdjustment, equals(-2.0));

      // Case 3: Player index is 9.0, differential is 4.0 -> drop is 5.0 < 7.0 -> Normal
      final normal = useCase.calculateScoreDifferential(
        holes: courseHoles,
        rawHoleStrokes: rawStrokes,
        courseHandicap: 10,
        courseRating: 68.0,
        slopeRating: 113,
        playerHandicapIndex: 9.0,
      );
      expect(normal.isExceptionalScore, isFalse);
      expect(normal.esrAdjustment, equals(0.0));
    });
  });

  group('HandicapDifferentialUseCase - 8-of-20 Index & Caps', () {
    test('Calculates average of 8 lowest differentials from 20 rounds', () {
      final rounds = List.generate(20, (i) {
        return HistoricalRoundScore(
          id: 'r_$i',
          date: DateTime.now().subtract(Duration(days: i * 5)),
          courseName: 'Course $i',
          teeBox: 'White',
          rawGross: 75 + i,
          adjustedGross: 75 + i,
          differential: (i + 1).toDouble(), // 1.0, 2.0, ... 20.0
        );
      });

      final result = useCase.calculateHandicapIndexFromRounds(rounds);

      expect(result.totalRoundsSubmitted, equals(20));
      expect(result.countingRoundsCount, equals(8));
      // Lowest 8 are 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0. Sum = 36. Average = 4.5
      expect(result.finalHandicapIndex, equals(4.5));
      expect(result.softCapApplied, isFalse);
      expect(result.hardCapApplied, isFalse);
      expect(
        result.rankedRounds.where((r) => r.isCountedInBest8).length,
        equals(8),
      );
    });

    test(
      'Applies Soft Cap when index exceeds Low HI 365d by more than 3.0',
      () {
        final rounds = List.generate(20, (i) {
          return HistoricalRoundScore(
            id: 'r_$i',
            date: DateTime.now(),
            courseName: 'Course $i',
            teeBox: 'White',
            rawGross: 82,
            adjustedGross: 82,
            differential: 10.0,
          );
        });

        final result = useCase.calculateHandicapIndexFromRounds(
          rounds,
          lowHandicapIndex365: 5.0,
        );

        expect(result.softCapApplied, isTrue);
        expect(result.hardCapApplied, isFalse);
        expect(result.finalHandicapIndex, equals(9.0));
      },
    );

    test('Applies Hard Cap when index would exceed Low HI 365d by 5.0', () {
      final rounds = List.generate(20, (i) {
        return HistoricalRoundScore(
          id: 'r_$i',
          date: DateTime.now(),
          courseName: 'Course $i',
          teeBox: 'White',
          rawGross: 90,
          adjustedGross: 90,
          differential: 16.0,
        );
      });

      final result = useCase.calculateHandicapIndexFromRounds(
        rounds,
        lowHandicapIndex365: 5.0,
      );

      expect(result.softCapApplied, isTrue);
      expect(result.hardCapApplied, isTrue);
      expect(result.finalHandicapIndex, equals(10.0));
    });

    test('Returns zero calculation gracefully when rounds list is empty', () {
      final result = useCase.calculateHandicapIndexFromRounds([]);
      expect(result.totalRoundsSubmitted, equals(0));
      expect(result.countingRoundsCount, equals(0));
      expect(result.finalHandicapIndex, equals(0.0));
      expect(result.rankedRounds, isEmpty);
    });
  });

  group('HandicapDifferentialController Tests', () {
    late HandicapDifferentialController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await setupServiceLocator();
      controller = sl<HandicapDifferentialController>();
    });

    test('Initializes with active scorecard course and seeded 20 rounds', () {
      expect(controller.course.name, equals(GolfCourses.lahoreGarrison.name));
      expect(controller.historicalRounds.length, equals(20));
      expect(controller.whsCalculation.totalRoundsSubmitted, equals(20));
      expect(controller.whsCalculation.countingRoundsCount, equals(8));
      expect(controller.pcc, equals(0.0));
    });

    test(
      'PCC updates trigger notifyListeners and recalculate differential',
      () {
        var notified = false;
        controller.addListener(() => notified = true);

        final initialDiff = controller.differentialResult.scoreDifferential;
        controller.setPcc(2.0);

        expect(notified, isTrue);
        expect(controller.pcc, equals(2.0));
        expect(controller.differentialResult.pcc, equals(2.0));
        expect(
          controller.differentialResult.scoreDifferential,
          lessThan(initialDiff),
        );
      },
    );

    test('Hole stroke modification updates raw gross and ESC truncation', () {
      controller.updateHoleStroke(0, 12); // Hole 1 to 12 strokes
      final result = controller.differentialResult;

      expect(result.holeAdjustments[0].rawStrokes, equals(12));
      expect(result.holeAdjustments[0].wasTruncated, isTrue);
      expect(result.totalStrokesShaved, greaterThan(0));
    });

    test('setPlayer updates active player and handicap index', () {
      controller.setPlayer('p2', 12.4);
      expect(controller.selectedPlayerId, equals('p2'));
      expect(controller.playerHandicapIndex, equals(12.4));
    });
  });
}
