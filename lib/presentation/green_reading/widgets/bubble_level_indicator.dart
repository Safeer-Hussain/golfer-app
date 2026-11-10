import 'dart:math' as math;
import 'package:flutter/material.dart';

class BubbleLevelIndicator extends StatelessWidget {
  final double slopeDegrees;
  final double fallLineHeadingDegrees; // 0° North, 90° East, etc.
  final ValueChanged<double>? onHeadingChanged;
  final ValueChanged<double>? onSlopeChanged;

  const BubbleLevelIndicator({
    super.key,
    required this.slopeDegrees,
    required this.fallLineHeadingDegrees,
    this.onHeadingChanged,
    this.onSlopeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final slopePercent = slopeDegrees * 1.7455;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Circular Gauge Background
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surfaceContainer,
                  border: Border.all(color: colorScheme.outlineVariant, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.surface.withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              // Concentric Degree Rings (1°, 2°, 3°, 4°)
              ...[1.0, 2.0, 3.0, 4.0].map((deg) {
                final radius = (deg / 4.5) * 85;
                return Container(
                  width: radius * 2,
                  height: radius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                );
              }),
              // Crosshair Lines
              Container(
                width: 170,
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
              Container(
                width: 1,
                height: 170,
                color: colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
              // Fall Line Downhill Arrow
              Transform.rotate(
                angle: (fallLineHeadingDegrees - 90.0) * (math.pi / 180.0),
                child: SizedBox(
                  width: 160,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Animated Bubble Level representing inclination
              Builder(
                builder: (context) {
                  final maxOffset = 80.0;
                  final normSlope = (slopeDegrees / 4.5).clamp(0.0, 1.0);
                  final rad = (fallLineHeadingDegrees - 90.0) * (math.pi / 180.0);
                  final offsetX = math.cos(rad) * normSlope * maxOffset;
                  final offsetY = math.sin(rad) * normSlope * maxOffset;

                  return Transform.translate(
                    offset: Offset(offsetX, offsetY),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary.withValues(alpha: 0.35),
                        border: Border.all(color: colorScheme.primary, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Center Bullseye Marker
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Degree & Grade Readout
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Text(
                '${slopeDegrees.toStringAsFixed(1)}° Tilt',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Text(
                '${slopePercent.toStringAsFixed(1)}% Grade',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Fall: ${fallLineHeadingDegrees.toInt()}°',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
