import 'player_model.dart';
import '../../core/constants/app_constants.dart';

class FlightModel {
  final String courseId;
  final String courseName;
  final String defaultTeeBox;
  final String gameFormat;
  final List<PlayerModel> players;
  final DateTime startedAt;

  const FlightModel({
    required this.courseId,
    required this.courseName,
    required this.defaultTeeBox,
    required this.gameFormat,
    required this.players,
    required this.startedAt,
  });

  FlightModel copyWith({
    String? courseId,
    String? courseName,
    String? defaultTeeBox,
    String? gameFormat,
    List<PlayerModel>? players,
    DateTime? startedAt,
  }) {
    return FlightModel(
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      defaultTeeBox: defaultTeeBox ?? this.defaultTeeBox,
      gameFormat: gameFormat ?? this.gameFormat,
      players: players ?? this.players,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'defaultTeeBox': defaultTeeBox,
      'gameFormat': gameFormat,
      'players': players.map((p) => p.toJson()).toList(),
      'startedAt': startedAt.toIso8601String(),
    };
  }

  factory FlightModel.fromJson(Map<String, dynamic> json) {
    return FlightModel(
      courseId: json['courseId'] as String? ?? 'lahore_garrison',
      courseName: json['courseName'] as String? ?? 'Lahore Garrison Golf & CC',
      defaultTeeBox: json['defaultTeeBox'] as String? ?? AppConstants.teeBlack,
      gameFormat:
          json['gameFormat'] as String? ?? AppConstants.formatStrokePlay,
      players:
          (json['players'] as List<dynamic>?)
              ?.map((p) => PlayerModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : DateTime.now(),
    );
  }
}
