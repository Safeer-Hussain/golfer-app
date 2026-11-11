import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../core/utils/app_feedback.dart';
import '../../domain/usecases/swing_tempo_usecase.dart';
import 'swing_tempo_controller.dart';
import 'widgets/tempo_arc_gauge.dart';
import 'widgets/tempo_calibrator_card.dart';
import 'widgets/tempo_preset_selector.dart';

class SwingTempoView extends StatefulWidget {
  const SwingTempoView({super.key});

  @override
  State<SwingTempoView> createState() => _SwingTempoViewState();
}

class _SwingTempoViewState extends State<SwingTempoView> {
  late final SwingTempoController _controller;
  late final SwingTempoUseCase _useCase;
  final ScrollController _portraitScrollController = ScrollController();
  final ScrollController _landscapeLeftController = ScrollController();
  final ScrollController _landscapeRightController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = GetIt.I<SwingTempoController>();
    _useCase = GetIt.I<SwingTempoUseCase>();
  }

  @override
  void dispose() {
    _portraitScrollController.dispose();
    _landscapeLeftController.dispose();
    _landscapeRightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Swing Tempo Metronome'),
        toolbarHeight: isLandscape ? 40 : kToolbarHeight,
        actions: [
          IconButton(
            icon: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) => Icon(
                _controller.soundEnabled
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                size: isLandscape ? 18 : 22,
                color: _controller.soundEnabled
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            tooltip: 'Toggle Metronome Audio',
            onPressed: _controller.toggleSound,
          ),
          IconButton(
            icon: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) => Icon(
                _controller.vibrationEnabled
                    ? Icons.vibration_rounded
                    : Icons.mobile_off_rounded,
                size: isLandscape ? 18 : 22,
                color: _controller.vibrationEnabled
                    ? colorScheme.secondary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            tooltip: 'Toggle Haptic Feedback',
            onPressed: _controller.toggleVibration,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final isPlaying = _controller.isPlaying;
          final currentPhase = _controller.currentPhase;
          final progress = _controller.phaseProgress;
          final preset = _controller.currentPreset;

          if (isLandscape) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Pane: Gauge + Metronome Play Button
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    controller: _landscapeLeftController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TempoArcGauge(
                          currentPhase: currentPhase,
                          progress: progress,
                          preset: preset,
                          isPlaying: isPlaying,
                        ),
                        const SizedBox(height: 12),
                        _buildPlayButton(context, isPlaying),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(width: 1, color: colorScheme.outlineVariant),
                // Right Pane: Presets + Tap Calibrator
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    controller: _landscapeRightController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TempoPresetSelector(
                          swingType: _controller.swingType,
                          currentPreset: _controller.currentPreset,
                          onSwingTypeChanged: _controller.setSwingType,
                          onPresetChanged: _controller.setPreset,
                          useCase: _useCase,
                        ),
                        const SizedBox(height: 12),
                        TempoCalibratorCard(
                          calibrationStep: _controller.calibrationStep,
                          calibrationResult: _controller.calibrationResult,
                          onTapRecord: _controller.recordCalibrationTap,
                          onReset: _controller.resetCalibration,
                          onApplyRecommendedPreset: (newPreset) {
                            _controller.setPreset(newPreset);
                            AppFeedback.showSuccess(
                              context,
                              'Applied ${newPreset.name} Tour Cadence',
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          // Portrait View
          return SingleChildScrollView(
            controller: _portraitScrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: TempoArcGauge(
                    currentPhase: currentPhase,
                    progress: progress,
                    preset: preset,
                    isPlaying: isPlaying,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPlayButton(context, isPlaying),
                const SizedBox(height: 16),
                TempoPresetSelector(
                  swingType: _controller.swingType,
                  currentPreset: _controller.currentPreset,
                  onSwingTypeChanged: _controller.setSwingType,
                  onPresetChanged: _controller.setPreset,
                  useCase: _useCase,
                ),
                const SizedBox(height: 16),
                TempoCalibratorCard(
                  calibrationStep: _controller.calibrationStep,
                  calibrationResult: _controller.calibrationResult,
                  onTapRecord: _controller.recordCalibrationTap,
                  onReset: _controller.resetCalibration,
                  onApplyRecommendedPreset: (newPreset) {
                    _controller.setPreset(newPreset);
                    AppFeedback.showSuccess(
                      context,
                      'Applied ${newPreset.name} Tour Cadence',
                    );
                  },
                ),
                const SizedBox(height: 28),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_swing_tempo_play',
        onPressed: _controller.togglePlay,
        backgroundColor: _controller.isPlaying
            ? colorScheme.error
            : colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: Icon(
          _controller.isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
        ),
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context, bool isPlaying) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _controller.togglePlay,
        icon: Icon(
          isPlaying
              ? Icons.stop_circle_outlined
              : Icons.play_circle_filled_rounded,
          size: 20,
        ),
        label: Text(
          isPlaying
              ? 'STOP METRONOME (Reps: ${_controller.repetitionCount})'
              : 'START TOUR METRONOME',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPlaying ? colorScheme.error : colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}
