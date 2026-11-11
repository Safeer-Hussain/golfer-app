import 'package:flutter/material.dart';

import '../../../domain/entities/handicap_differential_entity.dart';

class WhsHistoryCard extends StatelessWidget {
  final HandicapIndexCalculation calculation;

  const WhsHistoryCard({super.key, required this.calculation});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
          // Header
          Row(
            children: [
              Icon(Icons.history_rounded, size: 18, color: colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'WHS 8-of-20 Index',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'Index: ${calculation.finalHandicapIndex.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Cap & Average Status Pills
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildStatusChip(
                context,
                label: 'Counting',
                value:
                    '${calculation.countingRoundsCount} of ${calculation.totalRoundsSubmitted}',
                color: colorScheme.primary,
              ),
              _buildStatusChip(
                context,
                label: 'Best 8 Avg',
                value: calculation.bestAverage.toStringAsFixed(1),
                color: colorScheme.secondary,
              ),
              _buildStatusChip(
                context,
                label: 'Low HI 365d',
                value: calculation.lowHandicapIndex365.toStringAsFixed(1),
                color: colorScheme.tertiary,
              ),
              if (calculation.softCapApplied)
                _buildStatusChip(
                  context,
                  label: 'Soft Cap',
                  value: 'Active (-50%)',
                  color: colorScheme.error,
                ),
              if (calculation.hardCapApplied)
                _buildStatusChip(
                  context,
                  label: 'Hard Cap',
                  value: '+5.0 Max',
                  color: colorScheme.error,
                ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            'Recent 20 Submissions (Starred rounds count toward Index):',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),

          // Scrollable Rounds List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: calculation.rankedRounds.length,
            separatorBuilder: (_, _) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final round = calculation.rankedRounds[index];

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: round.isCountedInBest8
                      ? colorScheme.primary.withValues(alpha: 0.1)
                      : colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: round.isCountedInBest8
                        ? colorScheme.primary.withValues(alpha: 0.35)
                        : colorScheme.outlineVariant.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      round.isCountedInBest8
                          ? Icons.star_rounded
                          : Icons.circle_outlined,
                      size: 16,
                      color: round.isCountedInBest8
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            round.courseName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: round.isCountedInBest8
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '${round.teeBox} Tees • Gross: ${round.rawGross} • Adj: ${round.adjustedGross}',
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: round.isCountedInBest8
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Diff: ${round.differential.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: round.isCountedInBest8
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
