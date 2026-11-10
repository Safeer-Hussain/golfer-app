import 'package:flutter/material.dart';
import '../../../domain/entities/green_reading_entity.dart';

class PuttTrajectoryCard extends StatelessWidget {
  final PuttCalculationResult result;

  const PuttTrajectoryCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    IconData breakIcon;
    Color breakColor;
    String breakLabel;

    switch (result.breakDirection) {
      case GreenBreakDirection.leftToRight:
        breakIcon = Icons.turn_right_rounded;
        breakColor = colorScheme.error;
        breakLabel = 'Left-to-Right Break';
        break;
      case GreenBreakDirection.rightToLeft:
        breakIcon = Icons.turn_left_rounded;
        breakColor = colorScheme.primary;
        breakLabel = 'Right-to-Left Break';
        break;
      case GreenBreakDirection.straight:
        breakIcon = Icons.straight_rounded;
        breakColor = colorScheme.secondary;
        breakLabel = 'Straight Line Putt';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sports_golf_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Putt Physics & Aim',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: breakColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: breakColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(breakIcon, size: 14, color: breakColor),
                    const SizedBox(width: 4),
                    Text(
                      breakLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: breakColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2 Metric Tiles: Plays Like Distance + Lateral Aim Deflection
          Row(
            children: [
              // Plays Like Distance
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plays Like Distance',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            result.playsLikeDistanceFeet.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ft',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Actual: ${result.physicalDistanceFeet.toStringAsFixed(0)} ft (${result.distanceAdjustmentFeet >= 0 ? '+' : ''}${result.distanceAdjustmentFeet.toStringAsFixed(1)} ft)',
                        style: TextStyle(
                          fontSize: 11,
                          color: result.distanceAdjustmentFeet.abs() < 0.3
                              ? colorScheme.onSurfaceVariant
                              : (result.distanceAdjustmentFeet > 0
                                  ? colorScheme.error
                                  : colorScheme.secondary),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Lateral Aim Offset
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aim Offset',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            result.lateralBreakInches.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: breakColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'in',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${result.lateralBreakCups.toStringAsFixed(1)} cups ${result.breakDirection == GreenBreakDirection.leftToRight ? 'left' : (result.breakDirection == GreenBreakDirection.rightToLeft ? 'right' : '')}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Visual Aim Line & Trajectory Preview
          Container(
            height: 60,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: CustomPaint(
              painter: _PuttTrajectoryPainter(
                breakDirection: result.breakDirection,
                lateralBreakCups: result.lateralBreakCups,
                colorScheme: colorScheme,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Aim Description
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.gps_fixed_rounded,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.aimDescription,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Speed & Touch Recommendation
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.speedDescription,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Hole Capture Advice
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.flag_outlined,
                  size: 16,
                  color: colorScheme.tertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.captureSpeedAdvice,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PuttTrajectoryPainter extends CustomPainter {
  final GreenBreakDirection breakDirection;
  final double lateralBreakCups;
  final ColorScheme colorScheme;

  _PuttTrajectoryPainter({
    required this.breakDirection,
    required this.lateralBreakCups,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final startPoint = Offset(size.width * 0.1, size.height * 0.5);
    final cupPoint = Offset(size.width * 0.88, size.height * 0.5);

    // Draw straight reference line
    final refPaint = Paint()
      ..color = colorScheme.outlineVariant.withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(startPoint, cupPoint, refPaint);

    // Cup circle
    final cupPaint = Paint()
      ..color = colorScheme.onSurface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(cupPoint, 7, cupPaint);

    final flagPaint = Paint()
      ..color = colorScheme.secondary
      ..strokeWidth = 2.0;
    canvas.drawLine(cupPoint, Offset(cupPoint.dx, cupPoint.dy - 14), flagPaint);

    // Ball starting circle
    final ballPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(startPoint, 5, ballPaint);

    // Calculate curve control point based on break
    double curveOffset = 0.0;
    if (breakDirection == GreenBreakDirection.leftToRight) {
      // Aim left (up in canvas coordinates) then curve back to cup
      curveOffset = -(lateralBreakCups.clamp(0.2, 5.0) * 4.5);
    } else if (breakDirection == GreenBreakDirection.rightToLeft) {
      // Aim right (down in canvas coordinates) then curve back to cup
      curveOffset = lateralBreakCups.clamp(0.2, 5.0) * 4.5;
    }

    final path = Path();
    path.moveTo(startPoint.dx, startPoint.dy);
    final controlPoint = Offset(size.width * 0.5, (size.height * 0.5) + curveOffset);
    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, cupPoint.dx, cupPoint.dy);

    final trajectoryPaint = Paint()
      ..color = colorScheme.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, trajectoryPaint);
  }

  @override
  bool shouldRepaint(covariant _PuttTrajectoryPainter oldDelegate) {
    return oldDelegate.breakDirection != breakDirection ||
        oldDelegate.lateralBreakCups != lateralBreakCups ||
        oldDelegate.colorScheme != colorScheme;
  }
}
