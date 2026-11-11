import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/swing_tempo_entity.dart';
import '../../domain/usecases/swing_tempo_usecase.dart';

class SwingTempoController extends ChangeNotifier {
  final SwingTempoUseCase _useCase;

  SwingType _swingType = SwingType.fullSwing;
  late TempoPreset _currentPreset;

  bool _isPlaying = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  SwingPhase _currentPhase = SwingPhase.address;
  double _phaseProgress = 0.0; // 0.0 to 1.0 within active cycle
  int _repetitionCount = 0;

  Timer? _tickerTimer;
  final Stopwatch _stopwatch = Stopwatch();

  // Tap-to-Calibrate State
  int _calibrationStep = 0; // 0: Ready, 1: At takeaway, 2: At top, 3: Completed
  DateTime? _tapTakeaway;
  DateTime? _tapTop;
  DateTime? _tapImpact;
  TempoCalibrationResult? _calibrationResult;

  SwingTempoController(this._useCase) {
    _currentPreset = _useCase.getPresets(_swingType)[1]; // Default to 21/7
  }

  SwingType get swingType => _swingType;
  TempoPreset get currentPreset => _currentPreset;
  bool get isPlaying => _isPlaying;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  SwingPhase get currentPhase => _currentPhase;
  double get phaseProgress => _phaseProgress;
  int get repetitionCount => _repetitionCount;

  int get calibrationStep => _calibrationStep;
  TempoCalibrationResult? get calibrationResult => _calibrationResult;

  void setSwingType(SwingType type) {
    if (_swingType != type) {
      _swingType = type;
      _currentPreset = _useCase.getPresets(type).first;
      if (_isPlaying) {
        _restartMetronome();
      }
      notifyListeners();
    }
  }

  void setPreset(TempoPreset preset) {
    _currentPreset = preset;
    if (_isPlaying) {
      _restartMetronome();
    }
    notifyListeners();
  }

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    notifyListeners();
  }

  void toggleVibration() {
    _vibrationEnabled = !_vibrationEnabled;
    notifyListeners();
  }

  void togglePlay() {
    if (_isPlaying) {
      stop();
    } else {
      start();
    }
  }

  void start() {
    _isPlaying = true;
    _repetitionCount = 0;
    _currentPhase = SwingPhase.takeaway;
    _phaseProgress = 0.0;
    _stopwatch.reset();
    _stopwatch.start();
    _triggerBeatFeedback(SwingPhase.takeaway);

    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(milliseconds: 25), _onTick);
    notifyListeners();
  }

  void stop() {
    _isPlaying = false;
    _tickerTimer?.cancel();
    _tickerTimer = null;
    _stopwatch.stop();
    _currentPhase = SwingPhase.address;
    _phaseProgress = 0.0;
    notifyListeners();
  }

  void _restartMetronome() {
    _stopwatch.reset();
    _stopwatch.start();
    _currentPhase = SwingPhase.takeaway;
    _phaseProgress = 0.0;
    _triggerBeatFeedback(SwingPhase.takeaway);
  }

  void _onTick(Timer timer) {
    if (!_isPlaying) return;

    final elapsedMs = _stopwatch.elapsedMilliseconds;
    final backswingMs = _currentPreset.backswingMs;
    final totalSwingMs = _currentPreset.totalMs;
    // 500ms follow-through / reset buffer before the next swing repetition
    const resetBufferMs = 500;
    final fullCycleMs = totalSwingMs + resetBufferMs;

    final currentCycleMs = elapsedMs % fullCycleMs;

    SwingPhase newPhase;
    double progress;

    if (currentCycleMs < backswingMs) {
      newPhase = SwingPhase.takeaway;
      progress = currentCycleMs / backswingMs;
    } else if (currentCycleMs < totalSwingMs) {
      newPhase = currentCycleMs - backswingMs < 60
          ? SwingPhase.topOfBackswing
          : SwingPhase.impact;
      final downswingProgress =
          (currentCycleMs - backswingMs) / _currentPreset.downswingMs;
      progress = downswingProgress;
    } else {
      newPhase = SwingPhase.followThrough;
      progress = (currentCycleMs - totalSwingMs) / resetBufferMs;
    }

    // Trigger feedback on phase transitions
    if (newPhase != _currentPhase) {
      if (newPhase == SwingPhase.takeaway) {
        _repetitionCount++;
        _triggerBeatFeedback(SwingPhase.takeaway);
      } else if (newPhase == SwingPhase.topOfBackswing) {
        _triggerBeatFeedback(SwingPhase.topOfBackswing);
      } else if (newPhase == SwingPhase.impact) {
        _triggerBeatFeedback(SwingPhase.impact);
      }
    }

    _currentPhase = newPhase;
    _phaseProgress = progress.clamp(0.0, 1.0);
    notifyListeners();
  }

  void _triggerBeatFeedback(SwingPhase phase) {
    if (_soundEnabled) {
      try {
        SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
    if (_vibrationEnabled) {
      try {
        switch (phase) {
          case SwingPhase.takeaway:
            HapticFeedback.lightImpact();
            break;
          case SwingPhase.topOfBackswing:
            HapticFeedback.mediumImpact();
            break;
          case SwingPhase.impact:
            HapticFeedback.heavyImpact();
            break;
          default:
            break;
        }
      } catch (_) {}
    }
  }

  // Tap-to-Calibrate Methods
  void recordCalibrationTap() {
    final now = DateTime.now();
    if (_calibrationStep == 0) {
      // Step 1: Takeaway
      _tapTakeaway = now;
      _calibrationStep = 1;
      _triggerBeatFeedback(SwingPhase.takeaway);
      notifyListeners();
    } else if (_calibrationStep == 1) {
      // Step 2: Top of swing
      _tapTop = now;
      _calibrationStep = 2;
      _triggerBeatFeedback(SwingPhase.topOfBackswing);
      notifyListeners();
    } else if (_calibrationStep == 2) {
      // Step 3: Impact
      _tapImpact = now;
      _calibrationStep = 3;
      _triggerBeatFeedback(SwingPhase.impact);

      if (_tapTakeaway != null && _tapTop != null && _tapImpact != null) {
        final backswingMs = _tapTop!.difference(_tapTakeaway!).inMilliseconds;
        final downswingMs = _tapImpact!.difference(_tapTop!).inMilliseconds;

        _calibrationResult = _useCase.calibrateSwing(
          measuredBackswingMs: backswingMs,
          measuredDownswingMs: downswingMs,
          swingType: _swingType,
        );
      }
      notifyListeners();
    } else {
      // Reset and start new calibration tap sequence
      resetCalibration();
      _tapTakeaway = now;
      _calibrationStep = 1;
      _triggerBeatFeedback(SwingPhase.takeaway);
      notifyListeners();
    }
  }

  void resetCalibration() {
    _calibrationStep = 0;
    _tapTakeaway = null;
    _tapTop = null;
    _tapImpact = null;
    _calibrationResult = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }
}
