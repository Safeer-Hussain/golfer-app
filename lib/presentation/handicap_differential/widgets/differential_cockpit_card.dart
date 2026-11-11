import 'package:flutter/material.dart';

import '../../../domain/entities/handicap_differential_entity.dart';

class DifferentialCockpitCard extends StatelessWidget {
  final ScoreDifferentialResult result;
  final double pcc;
  final ValueChanged<double> onPccChanged;

  const DifferentialCockpitCard({
    super.key,
    required this.result,
    required this.pcc,
    required this.onPccChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
          // Header with Differential Metric
          Row(
            children: [
              Icon(
                Icons.calculate_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'WHS Score Differential',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      result.scoreDifferential >= 0 ? '+' : '',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      result.scoreDifferential.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3 Metric Pills: Adjusted Gross, Raw Gross, Strokes Shaved
          Row(
            children: [
              Expanded(
                child: _buildMetricBox(
                  context,
                  label: 'Adjusted Gross',
                  value: '${result.adjustedGrossScore}',
                  color: colorScheme.primary,
                  subtitle: '${result.holesAdjustedCount} holes capped',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricBox(
                  context,
                  label: 'Raw Gross',
                  value: '${result.rawGrossScore}',
                  color: colorScheme.onSurface,
                  subtitle: 'Uncapped strokes',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricBox(
                  context,
                  label: 'ESC Shaved',
                  value: '-${result.totalStrokesShaved}',
                  color: result.totalStrokesShaved > 0
                      ? colorScheme.secondary
                      : colorScheme.onSurfaceVariant,
                  subtitle: 'Net Dbl Bogey',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Exceptional Score Alert (ESR)
          if (result.isExceptionalScore) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.stars_rounded, size: 18, color: colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Exceptional Score Reduction (ESR): Automatic ${result.esrAdjustment.toStringAsFixed(1)} index adjustment applied (Differential >= 7.0 lower than player index).',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Course Rating & Slope Formula Breakdown
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Differential Formula: (113 / Slope) x (Adjusted Gross - Rating - PCC)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '(113 / ${result.slopeRating}) x (${result.adjustedGrossScore} - ${result.courseRating.toStringAsFixed(1)} - ${pcc >= 0 ? '+' : ''}${pcc.toStringAsFixed(1)}) = ${result.scoreDifferential.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // PCC (Playing Conditions Calculation) Adjustment Selector
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Playing Conditions Calculation (PCC)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [-1.0, 0.0, 1.0, 2.0, 3.0].map((val) {
                  final isSelected = (pcc - val).abs() < 0.2;
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: InkWell(
                      onTap: () => onPccChanged(val),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outlineVariant,
                          ),
                        ),
                        child: Text(
                          val >= 0 ? '+${val.toInt()}' : '${val.toInt()}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBox(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 9, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
