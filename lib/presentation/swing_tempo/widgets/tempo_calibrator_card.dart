import 'package:flutter/material.dart';

import '../../../domain/entities/swing_tempo_entity.dart';

class TempoCalibratorCard extends StatelessWidget {
  final int calibrationStep;
  final TempoCalibrationResult? calibrationResult;
  final VoidCallback onTapRecord;
  final VoidCallback onReset;
  final ValueChanged<TempoPreset>? onApplyRecommendedPreset;

  const TempoCalibratorCard({
    super.key,
    required this.calibrationStep,
    required this.calibrationResult,
    required this.onTapRecord,
    required this.onReset,
    this.onApplyRecommendedPreset,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    String promptText;
    Color buttonColor;
    IconData promptIcon;

    switch (calibrationStep) {
      case 0:
        promptText = 'Tap to Start Takeaway';
        buttonColor = colorScheme.primary;
        promptIcon = Icons.touch_app_rounded;
        break;
      case 1:
        promptText = 'Tap at Top of Backswing!';
        buttonColor = colorScheme.error;
        promptIcon = Icons.arrow_upward_rounded;
        break;
      case 2:
        promptText = 'Tap at Ball Impact!';
        buttonColor = colorScheme.secondary;
        promptIcon = Icons.bolt_rounded;
        break;
      case 3:
      default:
        promptText = 'Calibrated! Tap to Measure Again';
        buttonColor = colorScheme.primary;
        promptIcon = Icons.check_circle_outline_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Rhythm Calibrator',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              if (calibrationStep > 0)
                TextButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.refresh_rounded, size: 14),
                  label: const Text('Reset', style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Big Interactive Tap Button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: onTapRecord,
              icon: Icon(promptIcon, size: 20),
              label: Text(
                promptText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),

          // Calibration Results Display
          if (calibrationResult != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Measured: ${calibrationResult!.measuredRatio.toStringAsFixed(1)}:1 Ratio',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${calibrationResult!.consistencyScore}% Tour Match',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Backswing: ${calibrationResult!.measuredBackswingMs}ms • Downswing: ${calibrationResult!.measuredDownswingMs}ms • Total: ${calibrationResult!.measuredTotalMs}ms',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    calibrationResult!.feedback,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onApplyRecommendedPreset != null
                          ? () => onApplyRecommendedPreset!(
                              calibrationResult!.closestPreset,
                            )
                          : null,
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: Text(
                        'Apply Recommended Cadence (${calibrationResult!.closestPreset.name})',
                        style: const TextStyle(fontSize: 11),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        side: BorderSide(
                          color: colorScheme.primary.withValues(alpha: 0.5),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
