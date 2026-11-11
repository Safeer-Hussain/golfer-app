import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/entities/swing_tempo_entity.dart';

class TempoArcGauge extends StatelessWidget {
  final SwingPhase currentPhase;
  final double progress;
  final TempoPreset preset;
  final bool isPlaying;

  const TempoArcGauge({
    super.key,
    required this.currentPhase,
    required this.progress,
    required this.preset,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    String phaseText;
    Color phaseColor;
    IconData phaseIcon;

    switch (currentPhase) {
      case SwingPhase.address:
        phaseText = isPlaying ? 'ADDRESS' : 'READY TO START';
        phaseColor = colorScheme.onSurfaceVariant;
        phaseIcon = Icons.sports_golf_rounded;
        break;
      case SwingPhase.takeaway:
        phaseText = '1. TAKEAWAY';
        phaseColor = colorScheme.primary;
        phaseIcon = Icons.arrow_upward_rounded;
        break;
      case SwingPhase.topOfBackswing:
        phaseText = '2. TOP OF SWING';
        phaseColor = colorScheme.error;
        phaseIcon = Icons.change_circle_outlined;
        break;
      case SwingPhase.impact:
        phaseText = '3. IMPACT';
        phaseColor = colorScheme.secondary;
        phaseIcon = Icons.bolt_rounded;
        break;
      case SwingPhase.followThrough:
        phaseText = 'RESET TO ADDRESS';
        phaseColor = colorScheme.tertiary;
        phaseIcon = Icons.refresh_rounded;
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 210,
          height: 210,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Circular background track
              CustomPaint(
                size: const Size(200, 200),
                painter: _TempoGaugePainter(
                  currentPhase: currentPhase,
                  progress: progress,
                  colorScheme: colorScheme,
                  isPlaying: isPlaying,
                ),
              ),
              // Center Phase Indicator Card
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surfaceContainer,
                  border: Border.all(
                    color: isPlaying ? phaseColor : colorScheme.outlineVariant,
                    width: isPlaying ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isPlaying
                          ? phaseColor.withValues(alpha: 0.25)
                          : colorScheme.surface.withValues(alpha: 0.5),
                      blurRadius: isPlaying ? 12 : 4,
                      spreadRadius: isPlaying ? 2 : 0,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(phaseIcon, size: 24, color: phaseColor),
                    const SizedBox(height: 6),
                    Text(
                      phaseText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: phaseColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${preset.backswingFrames}/${preset.downswingFrames} frames',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Beat Duration Chips
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            _buildMetricPill(
              context,
              label: 'Backswing',
              value: '${preset.backswingMs}ms',
              color: colorScheme.primary,
            ),
            _buildMetricPill(
              context,
              label: 'Downswing',
              value: '${preset.downswingMs}ms',
              color: colorScheme.secondary,
            ),
            _buildMetricPill(
              context,
              label: 'Ratio',
              value: '${preset.ratio.toStringAsFixed(1)}:1',
              color: colorScheme.tertiary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricPill(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TempoGaugePainter extends CustomPainter {
  final SwingPhase currentPhase;
  final double progress;
  final ColorScheme colorScheme;
  final bool isPlaying;

  _TempoGaugePainter({
    required this.currentPhase,
    required this.progress,
    required this.colorScheme,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background track arc (from 135° to 405° = 270° sweep)
    const startAngle = 135 * (math.pi / 180);
    const sweepAngle = 270 * (math.pi / 180);

    final trackPaint = Paint()
      ..color = colorScheme.surfaceContainerHighest
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Three Stage Markers along the track:
    // Angle 1: Start (135°) = Address/Takeaway
    // Angle 2: Top (337.5° = 135° + 202.5°, 75% of 270° for 3:1 ratio)
    // Angle 3: Impact (405° = End)
    final backswingSweep = sweepAngle * 0.75;
    final topAngle = startAngle + backswingSweep;
    final impactAngle = startAngle + sweepAngle;

    _drawMarker(canvas, center, radius, startAngle, colorScheme.primary);
    _drawMarker(canvas, center, radius, topAngle, colorScheme.error);
    _drawMarker(canvas, center, radius, impactAngle, colorScheme.secondary);

    if (!isPlaying) return;

    // Active sweep calculation
    double activeSweep;
    Color activeColor;

    if (currentPhase == SwingPhase.takeaway) {
      activeSweep = backswingSweep * progress;
      activeColor = colorScheme.primary;
    } else if (currentPhase == SwingPhase.topOfBackswing ||
        currentPhase == SwingPhase.impact) {
      final downswingSweep = sweepAngle * 0.25;
      activeSweep = backswingSweep + (downswingSweep * progress);
      activeColor = colorScheme.secondary;
    } else {
      activeSweep = sweepAngle * (1.0 - progress);
      activeColor = colorScheme.tertiary.withValues(alpha: 0.5);
    }

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      activeSweep.clamp(0.01, sweepAngle),
      false,
      activePaint,
    );

    // Indicator head circle
    final currentAngle = startAngle + activeSweep;
    final indicatorOffset = Offset(
      center.dx + radius * math.cos(currentAngle),
      center.dy + radius * math.sin(currentAngle),
    );

    final indicatorPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(indicatorOffset, 7, indicatorPaint);
  }

  void _drawMarker(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    Color color,
  ) {
    final offset = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(offset, 4.5, paint);
  }

  @override
  bool shouldRepaint(covariant _TempoGaugePainter oldDelegate) {
    return oldDelegate.currentPhase != currentPhase ||
        oldDelegate.progress != progress ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.colorScheme != colorScheme;
  }
}
