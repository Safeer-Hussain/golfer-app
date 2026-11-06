class HoleScoreModel {
  final int holeNumber;
  final int strokes;
  final int putts;
  final String fir; // 'left', 'center', 'right', 'miss', 'none'
  final bool gir;
  final bool bunker;
  final bool penalty;

  const HoleScoreModel({
    required this.holeNumber,
    required this.strokes,
    this.putts = 2,
    this.fir = 'center',
    this.gir = true,
    this.bunker = false,
    this.penalty = false,
  });

  HoleScoreModel copyWith({
    int? holeNumber,
    int? strokes,
    int? putts,
    String? fir,
    bool? gir,
    bool? bunker,
    bool? penalty,
  }) {
    return HoleScoreModel(
      holeNumber: holeNumber ?? this.holeNumber,
      strokes: strokes ?? this.strokes,
      putts: putts ?? this.putts,
      fir: fir ?? this.fir,
      gir: gir ?? this.gir,
      bunker: bunker ?? this.bunker,
      penalty: penalty ?? this.penalty,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'holeNumber': holeNumber,
      'strokes': strokes,
      'putts': putts,
      'fir': fir,
      'gir': gir,
      'bunker': bunker,
      'penalty': penalty,
    };
  }

  factory HoleScoreModel.fromJson(Map<String, dynamic> json) {
    return HoleScoreModel(
      holeNumber: json['holeNumber'] as int,
      strokes: json['strokes'] as int,
      putts: json['putts'] as int? ?? 2,
      fir: json['fir'] as String? ?? 'center',
      gir: json['gir'] as bool? ?? true,
      bunker: json['bunker'] as bool? ?? false,
      penalty: json['penalty'] as bool? ?? false,
    );
  }
}
