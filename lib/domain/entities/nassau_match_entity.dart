enum NassauSegment {
  front9,
  back9,
  overall,
  press,
}

class NassauSubMatch {
  final String id;
  final String label;
  final NassauSegment segment;
  final int startHole; // 1-based (e.g. 1, 10, 6)
  final int endHole;   // 1-based (e.g. 9, 18)
  final String player1Id;
  final String player2Id;
  final double stake;
  final int player1HolesWon;
  final int player2HolesWon;
  final int holesHalved;
  final int currentHoleEvaluated;
  final bool isCompleted;

  const NassauSubMatch({
    required this.id,
    required this.label,
    required this.segment,
    required this.startHole,
    required this.endHole,
    required this.player1Id,
    required this.player2Id,
    required this.stake,
    this.player1HolesWon = 0,
    this.player2HolesWon = 0,
    this.holesHalved = 0,
    this.currentHoleEvaluated = 0,
    this.isCompleted = false,
  });

  int get margin => player1HolesWon - player2HolesWon;

  String getStatusDisplay(String player1Name, String player2Name) {
    final diff = margin;
    final holesRemaining = endHole - currentHoleEvaluated;

    if (diff == 0) {
      return isCompleted ? 'Halved (Push)' : 'All Square';
    }

    final leaderName = diff > 0 ? player1Name : player2Name;
    final absDiff = diff.abs();

    if (isCompleted) {
      if (holesRemaining <= 0) {
        return '$leaderName won $absDiff UP';
      }
      return '$leaderName won $absDiff & $holesRemaining';
    }

    if (holesRemaining == absDiff) {
      return '$leaderName Dormie $absDiff UP';
    }

    return '$leaderName $absDiff UP';
  }

  String? getWinnerId() {
    if (!isCompleted && currentHoleEvaluated < endHole) return null;
    if (margin > 0) return player1Id;
    if (margin < 0) return player2Id;
    return null; // Halved
  }

  NassauSubMatch copyWith({
    String? id,
    String? label,
    NassauSegment? segment,
    int? startHole,
    int? endHole,
    String? player1Id,
    String? player2Id,
    double? stake,
    int? player1HolesWon,
    int? player2HolesWon,
    int? holesHalved,
    int? currentHoleEvaluated,
    bool? isCompleted,
  }) {
    return NassauSubMatch(
      id: id ?? this.id,
      label: label ?? this.label,
      segment: segment ?? this.segment,
      startHole: startHole ?? this.startHole,
      endHole: endHole ?? this.endHole,
      player1Id: player1Id ?? this.player1Id,
      player2Id: player2Id ?? this.player2Id,
      stake: stake ?? this.stake,
      player1HolesWon: player1HolesWon ?? this.player1HolesWon,
      player2HolesWon: player2HolesWon ?? this.player2HolesWon,
      holesHalved: holesHalved ?? this.holesHalved,
      currentHoleEvaluated: currentHoleEvaluated ?? this.currentHoleEvaluated,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class NassauLedgerPayment {
  final String debtorId;
  final String debtorName;
  final String creditorId;
  final String creditorName;
  final double amount;
  final String description;

  const NassauLedgerPayment({
    required this.debtorId,
    required this.debtorName,
    required this.creditorId,
    required this.creditorName,
    required this.amount,
    required this.description,
  });
}

class NassauMatchResult {
  final String player1Id;
  final String player2Id;
  final NassauSubMatch front9;
  final NassauSubMatch back9;
  final NassauSubMatch overall;
  final List<NassauSubMatch> presses;
  final double netPlayer1Winnings; // positive means player 1 won money, negative means player 2 won

  const NassauMatchResult({
    required this.player1Id,
    required this.player2Id,
    required this.front9,
    required this.back9,
    required this.overall,
    required this.presses,
    required this.netPlayer1Winnings,
  });

  List<NassauSubMatch> get allSubMatches => [front9, back9, overall, ...presses];
}
