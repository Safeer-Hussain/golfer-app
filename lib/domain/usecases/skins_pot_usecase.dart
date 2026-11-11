import '../../core/utils/handicap_calculator.dart';
import '../../data/models/player_model.dart';
import '../entities/hole_entity.dart';
import '../entities/skins_pot_entity.dart';

class SkinsPotUseCase {
  SkinsGameResult evaluateSkinsGame({
    required List<HoleEntity> holes,
    required List<PlayerModel> players,
    required Map<String, List<int>> playerScores,
    required Map<String, int> playerCourseHandicaps,
    SkinsScoringMode mode = SkinsScoringMode.gross,
    double stakePerHole = 5.0,
    Hole18CarryoverRule hole18Rule = Hole18CarryoverRule.carryoverPush,
  }) {
    if (players.isEmpty || holes.isEmpty) {
      return SkinsGameResult(
        mode: mode,
        stakePerHole: stakePerHole,
        totalPot: 0.0,
        totalHolesCount: holes.length,
        completedHolesCount: 0,
        totalSkinsAwarded: 0,
        activeCarryoverSkins: 0,
        activeCarryoverPot: 0.0,
        holeResults: const [],
        playerPayouts: const [],
        hole18Rule: hole18Rule,
      );
    }

    final holeResults = <HoleSkinResult>[];
    final skinsWonByPlayer = <String, int>{};
    final holesWonByPlayer = <String, List<int>>{};
    final payoutByPlayer = <String, double>{};

    for (final player in players) {
      skinsWonByPlayer[player.id] = 0;
      holesWonByPlayer[player.id] = [];
      payoutByPlayer[player.id] = 0.0;
    }

    int carryover = 0;
    int completedHoles = 0;
    int totalSkinsAwarded = 0;
    List<String> lastHoleTiedPlayers = [];

    final potPerSkin = stakePerHole * players.length;

    for (var i = 0; i < holes.length; i++) {
      final hole = holes[i];
      final playerGross = <String, int>{};
      final playerNet = <String, int>{};
      final playerStrokes = <String, int>{};

      var holeHasAllScores = true;

      for (final player in players) {
        final scores = playerScores[player.id];
        final gross = (scores != null && i < scores.length) ? scores[i] : 0;
        if (gross <= 0) {
          holeHasAllScores = false;
        }

        final courseHandicap = playerCourseHandicaps[player.id] ?? 0;
        final strokesRec = HandicapCalculator.calculateStrokesReceived(
          holeStrokeIndex: hole.strokeIndex,
          courseHandicap: courseHandicap,
        );

        final net = gross - strokesRec;

        playerGross[player.id] = gross;
        playerNet[player.id] = net;
        playerStrokes[player.id] = strokesRec;
      }

      if (!holeHasAllScores) {
        holeResults.add(
          HoleSkinResult(
            holeNumber: hole.holeNumber,
            par: hole.par,
            strokeIndex: hole.strokeIndex,
            playerGrossScores: playerGross,
            playerNetScores: playerNet,
            playerStrokesReceived: playerStrokes,
            winningScore: 0,
            isTie: false,
            isPending: true,
            carryoverIn: carryover,
            skinsWonCount: 0,
            potWon: 0.0,
          ),
        );
        continue;
      }

      completedHoles++;

      // Evaluate winner based on scoring mode
      int minScore = 9999;
      final playersWithMin = <String>[];

      for (final player in players) {
        final score = mode == SkinsScoringMode.gross
            ? playerGross[player.id]!
            : playerNet[player.id]!;

        if (score < minScore) {
          minScore = score;
          playersWithMin.clear();
          playersWithMin.add(player.id);
        } else if (score == minScore) {
          playersWithMin.add(player.id);
        }
      }

      final isTie = playersWithMin.length != 1;
      final carryoverIn = carryover;

      if (isTie) {
        carryover++;
        lastHoleTiedPlayers = List<String>.from(playersWithMin);

        holeResults.add(
          HoleSkinResult(
            holeNumber: hole.holeNumber,
            par: hole.par,
            strokeIndex: hole.strokeIndex,
            playerGrossScores: playerGross,
            playerNetScores: playerNet,
            playerStrokesReceived: playerStrokes,
            winningScore: minScore,
            isTie: true,
            isPending: false,
            carryoverIn: carryoverIn,
            skinsWonCount: 0,
            potWon: 0.0,
          ),
        );
      } else {
        final winnerId = playersWithMin.first;
        final winner = players.firstWhere((p) => p.id == winnerId);
        final skinsWon = carryoverIn + 1;
        final potWon = skinsWon * potPerSkin;

        carryover = 0;
        totalSkinsAwarded += skinsWon;
        lastHoleTiedPlayers.clear();

        skinsWonByPlayer[winnerId] =
            (skinsWonByPlayer[winnerId] ?? 0) + skinsWon;
        holesWonByPlayer[winnerId]?.add(hole.holeNumber);
        payoutByPlayer[winnerId] = (payoutByPlayer[winnerId] ?? 0.0) + potWon;

        holeResults.add(
          HoleSkinResult(
            holeNumber: hole.holeNumber,
            par: hole.par,
            strokeIndex: hole.strokeIndex,
            playerGrossScores: playerGross,
            playerNetScores: playerNet,
            playerStrokesReceived: playerStrokes,
            winnerPlayerId: winnerId,
            winnerPlayerName: winner.name,
            winningScore: minScore,
            isTie: false,
            isPending: false,
            carryoverIn: carryoverIn,
            skinsWonCount: skinsWon,
            potWon: potWon,
          ),
        );
      }
    }

    // Resolve leftover carryover on round completion (if all 18 holes played and carryover remains)
    if (completedHoles == holes.length && carryover > 0) {
      final unawardedPot = carryover * potPerSkin;
      if (hole18Rule == Hole18CarryoverRule.carryoverPush) {
        final pushEach = unawardedPot / players.length;
        for (final player in players) {
          payoutByPlayer[player.id] =
              (payoutByPlayer[player.id] ?? 0.0) + pushEach;
        }
      } else if (hole18Rule == Hole18CarryoverRule.splitTiedPlayers &&
          lastHoleTiedPlayers.isNotEmpty) {
        final splitEach = unawardedPot / lastHoleTiedPlayers.length;
        for (final playerId in lastHoleTiedPlayers) {
          payoutByPlayer[playerId] =
              (payoutByPlayer[playerId] ?? 0.0) + splitEach;
        }
      }
    }

    final buyInPerPlayer = stakePerHole * completedHoles;
    final totalPot = buyInPerPlayer * players.length;

    final playerPayouts = players.map((player) {
      final skinsCount = skinsWonByPlayer[player.id] ?? 0;
      final holesWon = holesWonByPlayer[player.id] ?? [];
      final grossPayout = payoutByPlayer[player.id] ?? 0.0;
      final roundedPayout = (grossPayout * 100).round() / 100.0;
      final netBalance =
          ((roundedPayout - buyInPerPlayer) * 100).round() / 100.0;

      return PlayerSkinPayout(
        playerId: player.id,
        playerName: player.name,
        courseHandicap: playerCourseHandicaps[player.id] ?? 0,
        skinsWonCount: skinsCount,
        holesWon: holesWon,
        totalBuyIn: buyInPerPlayer,
        totalPayout: roundedPayout,
        netBalance: netBalance,
      );
    }).toList();

    return SkinsGameResult(
      mode: mode,
      stakePerHole: stakePerHole,
      totalPot: totalPot,
      totalHolesCount: holes.length,
      completedHolesCount: completedHoles,
      totalSkinsAwarded: totalSkinsAwarded,
      activeCarryoverSkins: carryover,
      activeCarryoverPot: carryover * potPerSkin,
      holeResults: holeResults,
      playerPayouts: playerPayouts,
      hole18Rule: hole18Rule,
    );
  }
}
