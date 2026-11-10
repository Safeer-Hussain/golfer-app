import 'package:flutter/material.dart';

import '../../../core/utils/handicap_calculator.dart';
import '../../../data/models/hole_score_model.dart';
import '../../../data/models/player_model.dart';
import '../../../domain/entities/hole_entity.dart';

class PlayerHoleRow extends StatelessWidget {
  final PlayerModel player;
  final HoleEntity hole;
  final HoleScoreModel score;
  final Function(int delta) onStrokesChanged;
  final Function(int delta) onPuttsChanged;
  final Function(String fir) onFirChanged;
  final VoidCallback onToggleGir;
  final VoidCallback onToggleBunker;
  final VoidCallback onTogglePenalty;

  const PlayerHoleRow({
    super.key,
    required this.player,
    required this.hole,
    required this.score,
    required this.onStrokesChanged,
    required this.onPuttsChanged,
    required this.onFirChanged,
    required this.onToggleGir,
    required this.onToggleBunker,
    required this.onTogglePenalty,
  });

  Color _getScoreBadgeColor(BuildContext context, int diff) {
    final colorScheme = Theme.of(context).colorScheme;
    if (diff <= -2) return colorScheme.secondary; // Eagle
    if (diff == -1) return colorScheme.primary; // Birdie
    if (diff == 0) return colorScheme.surfaceContainerHighest; // Par
    if (diff == 1) return colorScheme.secondary; // Bogey
    return colorScheme.error; // Double bogey+
  }

  Widget _buildScoreSymbol(BuildContext context, int strokes, int par) {
    final colorScheme = Theme.of(context).colorScheme;
    final diff = strokes - par;
    final badgeColor = _getScoreBadgeColor(context, diff);

    String label = '$strokes';
    BoxDecoration decoration;

    if (diff <= -2) {
      // Double circle
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        color: badgeColor.withValues(alpha: 0.2),
        border: Border.all(color: badgeColor, width: 2),
      );
    } else if (diff == -1) {
      // Single circle
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        color: badgeColor.withValues(alpha: 0.2),
        border: Border.all(color: badgeColor, width: 1.5),
      );
    } else if (diff == 0) {
      // Par: simple rounded rect
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: badgeColor,
      );
    } else if (diff == 1) {
      // Bogey: single square
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: badgeColor, width: 1.5),
      );
    } else {
      // Double bogey+: double square / filled error
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: badgeColor.withValues(alpha: 0.15),
        border: Border.all(color: badgeColor, width: 2),
      );
    }

    return Container(
      width: 38,
      height: 38,
      decoration: decoration,
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final netScore = HandicapCalculator.calculateNetScore(
      grossStrokes: score.strokes,
      holeStrokeIndex: hole.strokeIndex,
      courseHandicap: player.courseHandicap,
    );

    final stableford = HandicapCalculator.calculateStablefordPoints(
      grossStrokes: score.strokes,
      par: hole.par,
      holeStrokeIndex: hole.strokeIndex,
      courseHandicap: player.courseHandicap,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: player.isCurrentDeviceUser
              ? colorScheme.primary.withValues(alpha: 0.4)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          // Header: Player Name + Net + Stableford
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundImage: AssetImage(player.avatarAsset),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  player.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Net: $netScore',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$stableford Pts',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Interactive Controls Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Stroke Stepper
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () => onStrokesChanged(-1),
                    icon: const Icon(Icons.remove, size: 16),
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(34, 34),
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildScoreSymbol(context, score.strokes, hole.par),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () => onStrokesChanged(1),
                    icon: const Icon(Icons.add, size: 16),
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(34, 34),
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
              // Putts Stepper
              Row(
                children: [
                  Text(
                    'Putts: ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                    onPressed: () => onPuttsChanged(-1),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: colorScheme.onSurfaceVariant,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '${score.putts}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    onPressed: () => onPuttsChanged(1),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 12),
          // Badges: FIR, GIR, Sand, Hazard
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // FIR Options (only if Par 4 or 5)
              if (hole.par > 3) ...[
                Row(
                  children: [
                    Text(
                      'FIR: ',
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    ...['left', 'center', 'right', 'miss'].map((direction) {
                      final isSelected = score.fir == direction;
                      IconData ic;
                      if (direction == 'left') {
                        ic = Icons.arrow_back;
                      } else if (direction == 'center') {
                        ic = Icons.check;
                      } else if (direction == 'right') {
                        ic = Icons.arrow_forward;
                      } else {
                        ic = Icons.close;
                      }

                      return GestureDetector(
                        onTap: () => onFirChanged(direction),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerHighest,
                          ),
                          child: Icon(
                            ic,
                            size: 11,
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ] else ...[
                Text(
                  'Par 3 (No FIR)',
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              // Quick toggles: GIR, Sand, Pen
              Row(
                children: [
                  FilterChip(
                    label: const Text('GIR', style: TextStyle(fontSize: 10)),
                    selected: score.gir,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    selectedColor: colorScheme.primary.withValues(alpha: 0.2),
                    checkmarkColor: colorScheme.primary,
                    onSelected: (_) => onToggleGir(),
                  ),
                  const SizedBox(width: 4),
                  FilterChip(
                    label: const Text('Sand', style: TextStyle(fontSize: 10)),
                    selected: score.bunker,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    selectedColor: colorScheme.secondary.withValues(alpha: 0.2),
                    checkmarkColor: colorScheme.secondary,
                    onSelected: (_) => onToggleBunker(),
                  ),
                  const SizedBox(width: 4),
                  FilterChip(
                    label: const Text('Pen', style: TextStyle(fontSize: 10)),
                    selected: score.penalty,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    selectedColor: colorScheme.error.withValues(alpha: 0.2),
                    checkmarkColor: colorScheme.error,
                    onSelected: (_) => onTogglePenalty(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
