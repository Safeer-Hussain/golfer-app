import 'dart:math' as math;

import '../entities/swing_tempo_entity.dart';

class SwingTempoUseCase {
  static const List<TempoPreset> defaultFullSwingPresets = [
    TempoPreset(
      id: 'tour_18_6',
      name: 'Tour Ultra Fast (18/6)',
      backswingFrames: 18,
      downswingFrames: 6,
      swingType: SwingType.fullSwing,
      proExample: 'Nick Price / Fred Funk',
      description:
          'Quick takeaway with explosive, compact transition. 3:1 ratio.',
    ),
    TempoPreset(
      id: 'tour_21_7',
      name: 'Tour Fast (21/7)',
      backswingFrames: 21,
      downswingFrames: 7,
      swingType: SwingType.fullSwing,
      proExample: 'Tiger Woods / Rory McIlroy',
      description:
          'Modern championship standard. Athletic, crisp rhythm. 3:1 ratio.',
    ),
    TempoPreset(
      id: 'tour_24_8',
      name: 'Tour Standard (24/8)',
      backswingFrames: 24,
      downswingFrames: 8,
      swingType: SwingType.fullSwing,
      proExample: 'Ernie Els / Davis Love III',
      description: 'The Big Easy rhythm. Smooth takeaway, effortless release. 3:1 ratio.',
    ),
    TempoPreset(
      id: 'tour_27_9',
      name: 'Tour Smooth (27/9)',
      backswingFrames: 27,
      downswingFrames: 9,
      swingType: SwingType.fullSwing,
      proExample: 'Inbee Park / Colin Montgomerie',
      description: 'Deliberate, rhythmic takeaway with patient transition at top. 3:1 ratio.',
    ),
    TempoPreset(
      id: 'training_30_10',
      name: 'Training Rhythm (30/10)',
      backswingFrames: 30,
      downswingFrames: 10,
      swingType: SwingType.fullSwing,
      proExample: 'Amateur Rhythm Baseline',
      description: 'Ideal pacing for eliminating rushed backswings and quick transitions.',
    ),
  ];

  static const List<TempoPreset> defaultPuttingPresets = [
    TempoPreset(
      id: 'putt_14_7',
      name: 'Putting Crisp (14/7)',
      backswingFrames: 14,
      downswingFrames: 7,
      swingType: SwingType.putting,
      proExample: 'Fast Bentgrass Greens',
      description: 'Short pendulum stroke with immediate forward acceleration. 2:1 ratio.',
    ),
    TempoPreset(
      id: 'putt_16_8',
      name: 'Putting Standard (16/8)',
      backswingFrames: 16,
      downswingFrames: 8,
      swingType: SwingType.putting,
      proExample: 'Brad Faxon / Tiger Woods',
      description:
          'Tour average putting rhythm. Balanced pendulum stroke. 2:1 ratio.',
    ),
    TempoPreset(
      id: 'putt_18_9',
      name: 'Putting Smooth (18/9)',
      backswingFrames: 18,
      downswingFrames: 9,
      swingType: SwingType.putting,
      proExample: 'Lag Putting Mastery',
      description: 'Smooth, expansive stroke ideal for distance control on 30+ ft putts.',
    ),
  ];

  List<TempoPreset> getPresets(SwingType swingType) {
    return swingType == SwingType.fullSwing
        ? defaultFullSwingPresets
        : defaultPuttingPresets;
  }

  TempoCalibrationResult calibrateSwing({
    required int measuredBackswingMs,
    required int measuredDownswingMs,
    required SwingType swingType,
  }) {
    final clampedBackswing = math.max(150, math.min(2500, measuredBackswingMs));
    final clampedDownswing = math.max(80, math.min(1000, measuredDownswingMs));
    final totalMs = clampedBackswing + clampedDownswing;

    final ratio = clampedBackswing / clampedDownswing;
    final idealRatio = swingType == SwingType.fullSwing ? 3.0 : 2.0;
    final ratioDeviation = (ratio - idealRatio).abs();

    // Match closest preset based on total duration and ratio
    final presets = getPresets(swingType);
    TempoPreset closest = presets.first;
    double smallestDiff = double.infinity;

    for (final preset in presets) {
      final durationDiff = (preset.totalMs - totalMs).abs() / preset.totalMs;
      final ratioDiff = (preset.ratio - ratio).abs();
      final compositeDiff = (durationDiff * 0.6) + (ratioDiff * 0.4);

      if (compositeDiff < smallestDiff) {
        smallestDiff = compositeDiff;
        closest = preset;
      }
    }

    // Consistency score out of 100
    final ratioErrorPct = (ratioDeviation / idealRatio) * 100;
    final score = math.max(10, (100 - (ratioErrorPct * 1.5)).round());

    String feedback;
    if (ratioDeviation < 0.25) {
      feedback =
          'Outstanding Tour Tempo: Perfect ${ratio.toStringAsFixed(1)}:1 ratio matching ${closest.proExample}.';
    } else if (ratio < idealRatio) {
      feedback =
          'Rushed Backswing: Ratio ${ratio.toStringAsFixed(1)}:1 indicates hurried takeaway relative to downswing acceleration.';
    } else {
      feedback =
          'Hesitant Transition: Ratio ${ratio.toStringAsFixed(1)}:1 indicates excessive pause at top or slow downswing through impact.';
    }

    return TempoCalibrationResult(
      measuredBackswingMs: clampedBackswing,
      measuredDownswingMs: clampedDownswing,
      measuredTotalMs: totalMs,
      measuredRatio: ratio,
      ratioDeviationFromIdeal: ratioDeviation,
      closestPreset: closest,
      consistencyScore: score,
      feedback: feedback,
    );
  }
}
