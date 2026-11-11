import 'package:flutter_test/flutter_test.dart';
import 'package:golfer_app/domain/entities/swing_tempo_entity.dart';
import 'package:golfer_app/domain/usecases/swing_tempo_usecase.dart';
import 'package:golfer_app/presentation/swing_tempo/swing_tempo_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SwingTempoUseCase useCase;

  setUp(() {
    useCase = SwingTempoUseCase();
  });

  group('SwingTempoUseCase Tests', () {
    test('Full swing presets all maintain exact 3:1 ratio', () {
      final presets = useCase.getPresets(SwingType.fullSwing);
      expect(presets.length, greaterThanOrEqualTo(5));

      for (final preset in presets) {
        expect(preset.ratio, equals(3.0));
        expect(preset.swingType, equals(SwingType.fullSwing));
        expect(
          preset.totalFrames,
          equals(preset.backswingFrames + preset.downswingFrames),
        );
        expect(preset.totalMs, equals(preset.backswingMs + preset.downswingMs));
        expect(preset.bpm, greaterThan(0));
      }
    });

    test('Putting presets all maintain exact 2:1 ratio', () {
      final presets = useCase.getPresets(SwingType.putting);
      expect(presets.length, greaterThanOrEqualTo(3));

      for (final preset in presets) {
        expect(preset.ratio, equals(2.0));
        expect(preset.swingType, equals(SwingType.putting));
        expect(
          preset.totalFrames,
          equals(preset.backswingFrames + preset.downswingFrames),
        );
        expect(preset.totalMs, equals(preset.backswingMs + preset.downswingMs));
      }
    });

    test(
      'calibrateSwing matches perfect 3:1 full swing to 21/7 Tour preset',
      () {
        final result = useCase.calibrateSwing(
          measuredBackswingMs: 700,
          measuredDownswingMs: 233,
          swingType: SwingType.fullSwing,
        );

        expect(result.measuredRatio, closeTo(3.0, 0.05));
        expect(result.consistencyScore, greaterThanOrEqualTo(95));
        expect(result.closestPreset.id, equals('tour_21_7'));
        expect(result.feedback, contains('Outstanding Tour Tempo'));
      },
    );

    test('calibrateSwing detects rushed backswing and low ratio', () {
      final result = useCase.calibrateSwing(
        measuredBackswingMs: 450,
        measuredDownswingMs: 250,
        swingType: SwingType.fullSwing,
      );

      expect(result.measuredRatio, closeTo(1.8, 0.05));
      expect(result.ratioDeviationFromIdeal, greaterThan(1.0));
      expect(result.feedback, contains('Rushed Backswing'));
    });

    test('calibrateSwing detects hesitant transition and high ratio', () {
      final result = useCase.calibrateSwing(
        measuredBackswingMs: 1200,
        measuredDownswingMs: 250,
        swingType: SwingType.fullSwing,
      );

      expect(result.measuredRatio, closeTo(4.8, 0.05));
      expect(result.ratioDeviationFromIdeal, greaterThan(1.5));
      expect(result.feedback, contains('Hesitant Transition'));
    });
  });

  group('SwingTempoController Tests', () {
    late SwingTempoController controller;

    setUp(() {
      controller = SwingTempoController(useCase);
    });

    tearDown(() {
      controller.dispose();
    });

    test('Initializes with default 21/7 Tour preset in stopped state', () {
      expect(controller.isPlaying, isFalse);
      expect(controller.currentPreset.id, equals('tour_21_7'));
      expect(controller.swingType, equals(SwingType.fullSwing));
      expect(controller.currentPhase, equals(SwingPhase.address));
      expect(controller.soundEnabled, isTrue);
      expect(controller.vibrationEnabled, isTrue);
    });

    test('start and stop transition state cleanly', () {
      var notified = false;
      controller.addListener(() => notified = true);

      controller.start();
      expect(controller.isPlaying, isTrue);
      expect(controller.currentPhase, equals(SwingPhase.takeaway));
      expect(notified, isTrue);

      controller.stop();
      expect(controller.isPlaying, isFalse);
      expect(controller.currentPhase, equals(SwingPhase.address));
    });

    test('setSwingType switches presets and resets current selection', () {
      controller.setSwingType(SwingType.putting);
      expect(controller.swingType, equals(SwingType.putting));
      expect(controller.currentPreset.swingType, equals(SwingType.putting));
      expect(controller.currentPreset.ratio, equals(2.0));
    });

    test('toggleSound and toggleVibration flip boolean state and notify', () {
      var notifiedCount = 0;
      controller.addListener(() => notifiedCount++);

      controller.toggleSound();
      expect(controller.soundEnabled, isFalse);

      controller.toggleVibration();
      expect(controller.vibrationEnabled, isFalse);

      expect(notifiedCount, equals(2));
    });

    test(
      'Tap-to-measure sequences 3 steps and produces calibration result',
      () {
        expect(controller.calibrationStep, equals(0));

        controller.recordCalibrationTap(); // Takeaway
        expect(controller.calibrationStep, equals(1));

        controller.recordCalibrationTap(); // Top
        expect(controller.calibrationStep, equals(2));

        controller.recordCalibrationTap(); // Impact
        expect(controller.calibrationStep, equals(3));
        expect(controller.calibrationResult, isNotNull);

        controller.resetCalibration();
        expect(controller.calibrationStep, equals(0));
        expect(controller.calibrationResult, isNull);
      },
    );
  });
}
