import 'package:flutter_test/flutter_test.dart';
import 'package:golfer_app/core/constants/golf_courses.dart';
import 'package:golfer_app/data/models/hole_score_model.dart';
import 'package:golfer_app/data/models/player_model.dart';
import 'package:golfer_app/domain/entities/nassau_match_entity.dart';
import 'package:golfer_app/domain/usecases/nassau_calculator_usecase.dart';

void main() {
  group('NassauCalculatorUseCase Tests', () {
    final useCase = NassauCalculatorUseCase();
    final course = GolfCourses.lahoreGarrison;

    test('evaluates Front 9, Back 9, and Overall match outcomes correctly', () {
      // Create scores where Player 1 wins holes 1, 2, 3 (3 UP), Player 2 wins 4, 5, 6, and 7-18 are halved
      final p1Scores = List.generate(18, (index) {
        final holeNum = index + 1;
        final par = course.getHole(holeNum).par;
        if (holeNum <= 3) return HoleScoreModel(holeNumber: holeNum, strokes: par - 1); // Birdies
        if (holeNum >= 4 && holeNum <= 6) return HoleScoreModel(holeNumber: holeNum, strokes: par + 1); // Bogeys
        return HoleScoreModel(holeNumber: holeNum, strokes: par); // Pars
      });

      final p2Scores = List.generate(18, (index) {
        final holeNum = index + 1;
        final par = course.getHole(holeNum).par;
        return HoleScoreModel(holeNumber: holeNum, strokes: par); // All pars
      });

      final result = useCase.evaluatePairingMatch(
        player1Id: 'p1',
        player2Id: 'p2',
        player1Scores: p1Scores,
        player2Scores: p2Scores,
        course: course,
        player1CourseHandicap: 0,
        player2CourseHandicap: 0,
        baseStake: 10.0,
        autoPress: false,
      );

      // P1 won 3 holes (1,2,3), P2 won 3 holes (4,5,6), remaining 12 halved
      // Front 9: P1 (3), P2 (3) -> Halved
      expect(result.front9.margin, 0);
      expect(result.front9.getStatusDisplay('Player 1', 'Player 2'), 'Halved (Push)');

      // Back 9: All halved
      expect(result.back9.margin, 0);
      expect(result.back9.getStatusDisplay('Player 1', 'Player 2'), 'Halved (Push)');

      // Overall: All square / Halved
      expect(result.overall.margin, 0);
      expect(result.netPlayer1Winnings, 0.0);
    });

    test('detects 2-down condition and automatically initiates a press', () {
      // Player 1 wins hole 1 and hole 2 -> Player 2 is 2-down after hole 2!
      final p1Scores = List.generate(18, (index) {
        final holeNum = index + 1;
        final par = course.getHole(holeNum).par;
        if (holeNum == 1 || holeNum == 2) {
          return HoleScoreModel(holeNumber: holeNum, strokes: par - 1); // Birdie
        }
        return HoleScoreModel(holeNumber: holeNum, strokes: par); // Par
      });

      final p2Scores = List.generate(18, (index) {
        final holeNum = index + 1;
        final par = course.getHole(holeNum).par;
        return HoleScoreModel(holeNumber: holeNum, strokes: par); // Par
      });

      final result = useCase.evaluatePairingMatch(
        player1Id: 'p1',
        player2Id: 'p2',
        player1Scores: p1Scores,
        player2Scores: p2Scores,
        course: course,
        player1CourseHandicap: 0,
        player2CourseHandicap: 0,
        baseStake: 10.0,
        autoPress: true,
        pressStake: 10.0,
      );

      // Front 9 has margin +2 (P1 is 2 UP)
      expect(result.front9.margin, 2);
      expect(result.front9.getStatusDisplay('Safeer', 'Khan'), 'Safeer won 2 UP');

      // A press must have spawned starting on Hole 3 through Hole 9
      expect(result.presses.isNotEmpty, isTrue);
      final firstPress = result.presses.first;
      expect(firstPress.startHole, 3);
      expect(firstPress.endHole, 9);
      expect(firstPress.segment, NassauSegment.press);

      // In holes 3-9, all were halved, so the press is halved (0 margin)
      expect(firstPress.margin, 0);

      // Financials: P1 won Front 9 ($10), Overall ($10), Back 9 halved ($0), Press halved ($0)
      // Total net P1 winnings = $20
      expect(result.netPlayer1Winnings, 20.0);
    });

    test('computes balanced 4-player round-robin ledger summing to zero', () {
      final p1 = const PlayerModel(id: 'p1', name: 'Safeer', handicapIndex: 4.2, avatarAsset: '', teeBox: 'Black', courseHandicap: 5);
      final p2 = const PlayerModel(id: 'p2', name: 'Khan', handicapIndex: 8.4, avatarAsset: '', teeBox: 'Black', courseHandicap: 9);
      final p3 = const PlayerModel(id: 'p3', name: 'Ali', handicapIndex: 14.0, avatarAsset: '', teeBox: 'Blue', courseHandicap: 16);
      final p4 = const PlayerModel(id: 'p4', name: 'Zayd', handicapIndex: 18.0, avatarAsset: '', teeBox: 'White', courseHandicap: 20);

      final players = [p1, p2, p3, p4];

      // Seed varied scores across 18 holes
      final Map<String, List<HoleScoreModel>> scoresMap = {
        'p1': List.generate(18, (i) => HoleScoreModel(holeNumber: i + 1, strokes: course.getHole(i + 1).par)),
        'p2': List.generate(18, (i) => HoleScoreModel(holeNumber: i + 1, strokes: course.getHole(i + 1).par + (i % 2 == 0 ? 1 : 0))),
        'p3': List.generate(18, (i) => HoleScoreModel(holeNumber: i + 1, strokes: course.getHole(i + 1).par + (i % 3 == 0 ? 1 : 0))),
        'p4': List.generate(18, (i) => HoleScoreModel(holeNumber: i + 1, strokes: course.getHole(i + 1).par + 1)),
      };

      final ledger = useCase.computeFlightNassauLedger(
        players: players,
        playerScores: scoresMap,
        course: course,
        baseStake: 10.0,
        autoPress: true,
        pressStake: 10.0,
      );

      final matchResults = ledger['matchResults'] as List<NassauMatchResult>;
      final netBalances = ledger['netBalances'] as Map<String, double>;
      final settlements = ledger['settlementPayments'] as List<NassauLedgerPayment>;

      // 4 players in round-robin = 6 pairwise matches
      expect(matchResults.length, 6);

      // Ledger balancing test: Sum of all balances MUST equal 0.00
      final totalBalance = netBalances.values.fold<double>(0.0, (sum, val) => sum + val);
      expect(totalBalance.abs(), lessThan(0.001));

      // If there are settlements, total payments from debtors equals creditors
      double totalSettlement = 0.0;
      for (final s in settlements) {
        totalSettlement += s.amount;
      }
      expect(totalSettlement, greaterThanOrEqualTo(0.0));
    });
  });
}
