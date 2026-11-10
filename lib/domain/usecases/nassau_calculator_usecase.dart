import '../../core/utils/handicap_calculator.dart';
import '../../data/models/hole_score_model.dart';
import '../../data/models/player_model.dart';
import '../entities/course_entity.dart';
import '../entities/nassau_match_entity.dart';

class NassauCalculatorUseCase {
  NassauMatchResult evaluatePairingMatch({
    required String player1Id,
    required String player2Id,
    required List<HoleScoreModel> player1Scores,
    required List<HoleScoreModel> player2Scores,
    required CourseEntity course,
    required int player1CourseHandicap,
    required int player2CourseHandicap,
    double baseStake = 10.0,
    bool autoPress = true,
    double pressStake = 10.0,
    bool useNetScore = true,
  }) {
    NassauSubMatch front9 = NassauSubMatch(
      id: 'f9_${player1Id}_$player2Id',
      label: 'Front 9 Match',
      segment: NassauSegment.front9,
      startHole: 1,
      endHole: 9,
      player1Id: player1Id,
      player2Id: player2Id,
      stake: baseStake,
    );

    NassauSubMatch back9 = NassauSubMatch(
      id: 'b9_${player1Id}_$player2Id',
      label: 'Back 9 Match',
      segment: NassauSegment.back9,
      startHole: 10,
      endHole: 18,
      player1Id: player1Id,
      player2Id: player2Id,
      stake: baseStake,
    );

    NassauSubMatch overall = NassauSubMatch(
      id: 'ov_${player1Id}_$player2Id',
      label: '18-Hole Match',
      segment: NassauSegment.overall,
      startHole: 1,
      endHole: 18,
      player1Id: player1Id,
      player2Id: player2Id,
      stake: baseStake,
    );

    final List<NassauSubMatch> presses = [];
    final Set<int> spawnedPressHoles = {};

    // Map scores by hole number
    final p1Map = {for (var s in player1Scores) s.holeNumber: s};
    final p2Map = {for (var s in player2Scores) s.holeNumber: s};

    for (int holeNum = 1; holeNum <= 18; holeNum++) {
      final s1 = p1Map[holeNum];
      final s2 = p2Map[holeNum];

      if (s1 == null || s2 == null) continue;

      final hole = course.getHole(holeNum);

      final val1 = useNetScore
          ? HandicapCalculator.calculateNetScore(
              grossStrokes: s1.strokes,
              holeStrokeIndex: hole.strokeIndex,
              courseHandicap: player1CourseHandicap,
            )
          : s1.strokes;

      final val2 = useNetScore
          ? HandicapCalculator.calculateNetScore(
              grossStrokes: s2.strokes,
              holeStrokeIndex: hole.strokeIndex,
              courseHandicap: player2CourseHandicap,
            )
          : s2.strokes;

      int p1Won = 0;
      int p2Won = 0;
      int halved = 0;

      if (val1 < val2) {
        p1Won = 1;
      } else if (val2 < val1) {
        p2Won = 1;
      } else {
        halved = 1;
      }

      // Update Overall
      overall = overall.copyWith(
        player1HolesWon: overall.player1HolesWon + p1Won,
        player2HolesWon: overall.player2HolesWon + p2Won,
        holesHalved: overall.holesHalved + halved,
        currentHoleEvaluated: holeNum,
        isCompleted: holeNum == 18,
      );

      // Update Front 9
      if (holeNum <= 9) {
        front9 = front9.copyWith(
          player1HolesWon: front9.player1HolesWon + p1Won,
          player2HolesWon: front9.player2HolesWon + p2Won,
          holesHalved: front9.holesHalved + halved,
          currentHoleEvaluated: holeNum,
          isCompleted: holeNum == 9,
        );

        // Automatic 2-Down Press Detection for Front 9
        if (autoPress &&
            front9.margin.abs() >= 2 &&
            holeNum < 9 &&
            !spawnedPressHoles.contains(holeNum)) {
          spawnedPressHoles.add(holeNum);
          presses.add(
            NassauSubMatch(
              id: 'press_f9_h${holeNum + 1}_${player1Id}_$player2Id',
              label: 'Front 9 Press (Holes ${holeNum + 1}-9)',
              segment: NassauSegment.press,
              startHole: holeNum + 1,
              endHole: 9,
              player1Id: player1Id,
              player2Id: player2Id,
              stake: pressStake,
            ),
          );
        }
      }

      // Update Back 9
      if (holeNum >= 10) {
        back9 = back9.copyWith(
          player1HolesWon: back9.player1HolesWon + p1Won,
          player2HolesWon: back9.player2HolesWon + p2Won,
          holesHalved: back9.holesHalved + halved,
          currentHoleEvaluated: holeNum,
          isCompleted: holeNum == 18,
        );

        // Automatic 2-Down Press Detection for Back 9
        if (autoPress &&
            back9.margin.abs() >= 2 &&
            holeNum < 18 &&
            !spawnedPressHoles.contains(holeNum)) {
          spawnedPressHoles.add(holeNum);
          presses.add(
            NassauSubMatch(
              id: 'press_b9_h${holeNum + 1}_${player1Id}_$player2Id',
              label: 'Back 9 Press (Holes ${holeNum + 1}-18)',
              segment: NassauSegment.press,
              startHole: holeNum + 1,
              endHole: 18,
              player1Id: player1Id,
              player2Id: player2Id,
              stake: pressStake,
            ),
          );
        }
      }

      // Update any active presses
      for (int i = 0; i < presses.length; i++) {
        final p = presses[i];
        if (holeNum >= p.startHole && holeNum <= p.endHole) {
          presses[i] = p.copyWith(
            player1HolesWon: p.player1HolesWon + p1Won,
            player2HolesWon: p.player2HolesWon + p2Won,
            holesHalved: p.holesHalved + halved,
            currentHoleEvaluated: holeNum,
            isCompleted: holeNum == p.endHole,
          );
        }
      }
    }

    // Calculate Net Balance for Player 1 vs Player 2
    double netP1 = 0.0;

    void tallySubMatch(NassauSubMatch sub) {
      if (sub.margin > 0) {
        netP1 += sub.stake;
      } else if (sub.margin < 0) {
        netP1 -= sub.stake;
      }
    }

    tallySubMatch(front9);
    tallySubMatch(back9);
    tallySubMatch(overall);
    for (final p in presses) {
      tallySubMatch(p);
    }

    return NassauMatchResult(
      player1Id: player1Id,
      player2Id: player2Id,
      front9: front9,
      back9: back9,
      overall: overall,
      presses: presses,
      netPlayer1Winnings: netP1,
    );
  }

  Map<String, dynamic> computeFlightNassauLedger({
    required List<PlayerModel> players,
    required Map<String, List<HoleScoreModel>> playerScores,
    required CourseEntity course,
    double baseStake = 10.0,
    bool autoPress = true,
    double pressStake = 10.0,
    bool useNetScore = true,
  }) {
    final Map<String, double> netBalances = {for (var p in players) p.id: 0.0};
    final List<NassauMatchResult> matchResults = [];

    // Pairwise Round-Robin
    for (int i = 0; i < players.length; i++) {
      for (int j = i + 1; j < players.length; j++) {
        final p1 = players[i];
        final p2 = players[j];

        final result = evaluatePairingMatch(
          player1Id: p1.id,
          player2Id: p2.id,
          player1Scores: playerScores[p1.id] ?? [],
          player2Scores: playerScores[p2.id] ?? [],
          course: course,
          player1CourseHandicap: p1.courseHandicap,
          player2CourseHandicap: p2.courseHandicap,
          baseStake: baseStake,
          autoPress: autoPress,
          pressStake: pressStake,
          useNetScore: useNetScore,
        );

        matchResults.add(result);

        netBalances[p1.id] =
            (netBalances[p1.id] ?? 0.0) + result.netPlayer1Winnings;
        netBalances[p2.id] =
            (netBalances[p2.id] ?? 0.0) - result.netPlayer1Winnings;
      }
    }

    // Compute Balanced Settlement Payments
    final List<NassauLedgerPayment> settlementPayments = [];
    final debtors = <MapEntry<String, double>>[];
    final creditors = <MapEntry<String, double>>[];

    netBalances.forEach((playerId, balance) {
      if (balance < -0.01) {
        debtors.add(MapEntry(playerId, -balance));
      } else if (balance > 0.01) {
        creditors.add(MapEntry(playerId, balance));
      }
    });

    final playerMap = {for (var p in players) p.id: p};

    int dIdx = 0;
    int cIdx = 0;
    final debCopy = debtors.map((e) => MapEntry(e.key, e.value)).toList();
    final credCopy = creditors.map((e) => MapEntry(e.key, e.value)).toList();

    while (dIdx < debCopy.length && cIdx < credCopy.length) {
      final debtor = debCopy[dIdx];
      final creditor = credCopy[cIdx];

      final settleAmount = debtor.value < creditor.value
          ? debtor.value
          : creditor.value;

      if (settleAmount > 0.01) {
        final dPlayer = playerMap[debtor.key];
        final cPlayer = playerMap[creditor.key];

        settlementPayments.add(
          NassauLedgerPayment(
            debtorId: debtor.key,
            debtorName: dPlayer?.name ?? 'Player',
            creditorId: creditor.key,
            creditorName: cPlayer?.name ?? 'Player',
            amount: settleAmount,
            description:
                '${dPlayer?.name ?? "Player"} pays ${cPlayer?.name ?? "Player"}',
          ),
        );
      }

      debCopy[dIdx] = MapEntry(debtor.key, debtor.value - settleAmount);
      credCopy[cIdx] = MapEntry(creditor.key, creditor.value - settleAmount);

      if (debCopy[dIdx].value < 0.01) dIdx++;
      if (credCopy[cIdx].value < 0.01) cIdx++;
    }

    return {
      'matchResults': matchResults,
      'netBalances': netBalances,
      'settlementPayments': settlementPayments,
    };
  }
}
