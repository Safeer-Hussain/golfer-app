import 'hole_score_model.dart';

class RoundScorecardModel {
  final String id;
  final String courseId;
  final String courseName;
  final String teeBox;
  final String gameFormat;
  final DateTime playedAt;
  final Map<String, List<HoleScoreModel>> playerScores; // playerId -> 18 hole scores
  final bool isCompleted;

  const RoundScorecardModel({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.teeBox,
    required this.gameFormat,
    required this.playedAt,
    required this.playerScores,
    this.isCompleted = false,
  });

  RoundScorecardModel copyWith({
    String? id,
    String? courseId,
    String? courseName,
    String? teeBox,
    String? gameFormat,
    DateTime? playedAt,
    Map<String, List<HoleScoreModel>>? playerScores,
    bool? isCompleted,
  }) {
    return RoundScorecardModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      teeBox: teeBox ?? this.teeBox,
      gameFormat: gameFormat ?? this.gameFormat,
      playedAt: playedAt ?? this.playedAt,
      playerScores: playerScores ?? this.playerScores,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  int getGrossTotalForPlayer(String playerId) {
    final scores = playerScores[playerId];
    if (scores == null || scores.isEmpty) return 0;
    return scores.fold<int>(0, (sum, item) => sum + item.strokes);
  }

  int getFront9GrossForPlayer(String playerId) {
    final scores = playerScores[playerId];
    if (scores == null || scores.isEmpty) return 0;
    return scores
        .where((s) => s.holeNumber <= 9)
        .fold<int>(0, (sum, item) => sum + item.strokes);
  }

  int getBack9GrossForPlayer(String playerId) {
    final scores = playerScores[playerId];
    if (scores == null || scores.isEmpty) return 0;
    return scores
        .where((s) => s.holeNumber >= 10 && s.holeNumber <= 18)
        .fold<int>(0, (sum, item) => sum + item.strokes);
  }

  int getTotalPuttsForPlayer(String playerId) {
    final scores = playerScores[playerId];
    if (scores == null || scores.isEmpty) return 0;
    return scores.fold<int>(0, (sum, item) => sum + item.putts);
  }

  int getGirCountForPlayer(String playerId) {
    final scores = playerScores[playerId];
    if (scores == null || scores.isEmpty) return 0;
    return scores.where((s) => s.gir).length;
  }

  int getFirCountForPlayer(String playerId) {
    final scores = playerScores[playerId];
    if (scores == null || scores.isEmpty) return 0;
    return scores.where((s) => s.fir == 'center').length;
  }

  Map<String, dynamic> toJson() {
    final serializedScores = <String, dynamic>{};
    playerScores.forEach((key, value) {
      serializedScores[key] = value.map((h) => h.toJson()).toList();
    });

    return {
      'id': id,
      'courseId': courseId,
      'courseName': courseName,
      'teeBox': teeBox,
      'gameFormat': gameFormat,
      'playedAt': playedAt.toIso8601String(),
      'playerScores': serializedScores,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory RoundScorecardModel.fromJson(Map<String, dynamic> json) {
    final rawScores = json['playerScores'] as Map<String, dynamic>? ?? {};
    final parsedScores = <String, List<HoleScoreModel>>{};

    rawScores.forEach((key, value) {
      if (value is List) {
        parsedScores[key] = value
            .map((item) => HoleScoreModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    });

    return RoundScorecardModel(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      courseName: json['courseName'] as String,
      teeBox: json['teeBox'] as String,
      gameFormat: json['gameFormat'] as String,
      playedAt: DateTime.parse(json['playedAt'] as String),
      playerScores: parsedScores,
      isCompleted: (json['isCompleted'] == 1 || json['isCompleted'] == true),
    );
  }
}
