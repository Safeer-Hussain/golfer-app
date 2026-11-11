enum SwingType { fullSwing, putting }

enum SwingPhase { address, takeaway, topOfBackswing, impact, followThrough }

class TempoPreset {
  final String id;
  final String name;
  final int backswingFrames;
  final int downswingFrames;
  final SwingType swingType;
  final String proExample;
  final String description;

  const TempoPreset({
    required this.id,
    required this.name,
    required this.backswingFrames,
    required this.downswingFrames,
    required this.swingType,
    required this.proExample,
    required this.description,
  });

  int get totalFrames => backswingFrames + downswingFrames;

  // Assuming standard 30 fps video capture standard for Tour Tempo
  int get backswingMs => (backswingFrames * 1000 / 30).round();
  int get downswingMs => (downswingFrames * 1000 / 30).round();
  int get totalMs => backswingMs + downswingMs;

  double get ratio => backswingFrames / downswingFrames;

  double get bpm => 60000 / totalMs;
}

class TempoCalibrationResult {
  final int measuredBackswingMs;
  final int measuredDownswingMs;
  final int measuredTotalMs;
  final double measuredRatio;
  final double ratioDeviationFromIdeal;
  final TempoPreset closestPreset;
  final int consistencyScore; // 0 to 100
  final String feedback;

  const TempoCalibrationResult({
    required this.measuredBackswingMs,
    required this.measuredDownswingMs,
    required this.measuredTotalMs,
    required this.measuredRatio,
    required this.ratioDeviationFromIdeal,
    required this.closestPreset,
    required this.consistencyScore,
    required this.feedback,
  });
}
