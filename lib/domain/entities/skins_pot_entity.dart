enum SkinsScoringMode { gross, net }

enum Hole18CarryoverRule { carryoverPush, noPayout, splitTiedPlayers }

class HoleSkinResult {
  final int holeNumber;
  final int par;
  final int strokeIndex;
  final Map<String, int> playerGrossScores;
  final Map<String, int> playerNetScores;
  final Map<String, int> playerStrokesReceived;
  final String? winnerPlayerId;
  final String? winnerPlayerName;
  final int winningScore;
  final bool isTie;
  final bool isPending;
  final int carryoverIn;
  final int skinsWonCount;
  final double potWon;

  const HoleSkinResult({
    required this.holeNumber,
    required this.par,
    required this.strokeIndex,
    required this.playerGrossScores,
    required this.playerNetScores,
    required this.playerStrokesReceived,
    this.winnerPlayerId,
    this.winnerPlayerName,
    required this.winningScore,
    required this.isTie,
    this.isPending = false,
    required this.carryoverIn,
    required this.skinsWonCount,
    required this.potWon,
  });

  bool get hasWinner => winnerPlayerId != null;
}

class PlayerSkinPayout {
  final String playerId;
  final String playerName;
  final int courseHandicap;
  final int skinsWonCount;
  final List<int> holesWon;
  final double totalBuyIn;
  final double totalPayout;
  final double netBalance; // totalPayout - totalBuyIn

  const PlayerSkinPayout({
    required this.playerId,
    required this.playerName,
    required this.courseHandicap,
    required this.skinsWonCount,
    required this.holesWon,
    required this.totalBuyIn,
    required this.totalPayout,
    required this.netBalance,
  });

  PlayerSkinPayout copyWith({
    String? playerId,
    String? playerName,
    int? courseHandicap,
    int? skinsWonCount,
    List<int>? holesWon,
    double? totalBuyIn,
    double? totalPayout,
    double? netBalance,
  }) {
    return PlayerSkinPayout(
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      courseHandicap: courseHandicap ?? this.courseHandicap,
      skinsWonCount: skinsWonCount ?? this.skinsWonCount,
      holesWon: holesWon ?? this.holesWon,
      totalBuyIn: totalBuyIn ?? this.totalBuyIn,
      totalPayout: totalPayout ?? this.totalPayout,
      netBalance: netBalance ?? this.netBalance,
    );
  }
}

class SkinsGameResult {
  final SkinsScoringMode mode;
  final double stakePerHole;
  final double totalPot;
  final int totalHolesCount;
  final int completedHolesCount;
  final int totalSkinsAwarded;
  final int activeCarryoverSkins;
  final double activeCarryoverPot;
  final List<HoleSkinResult> holeResults;
  final List<PlayerSkinPayout> playerPayouts;
  final Hole18CarryoverRule hole18Rule;

  const SkinsGameResult({
    required this.mode,
    required this.stakePerHole,
    required this.totalPot,
    required this.totalHolesCount,
    required this.completedHolesCount,
    required this.totalSkinsAwarded,
    required this.activeCarryoverSkins,
    required this.activeCarryoverPot,
    required this.holeResults,
    required this.playerPayouts,
    required this.hole18Rule,
  });

  PlayerSkinPayout? get leadingPlayer {
    if (playerPayouts.isEmpty) return null;
    final sorted = List<PlayerSkinPayout>.from(playerPayouts)
      ..sort((a, b) => b.totalPayout.compareTo(a.totalPayout));
    return sorted.first.totalPayout > 0 ? sorted.first : null;
  }
}
