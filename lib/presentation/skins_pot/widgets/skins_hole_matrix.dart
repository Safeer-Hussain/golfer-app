import 'package:flutter/material.dart';

import '../../../data/models/player_model.dart';
import '../../../domain/entities/skins_pot_entity.dart';

class SkinsHoleMatrix extends StatelessWidget {
  final List<HoleSkinResult> holeResults;
  final List<PlayerModel> players;
  final SkinsScoringMode mode;
  final void Function(String playerId, int holeIndex, int strokes)?
  onScoreChanged;

  const SkinsHoleMatrix({
    super.key,
    required this.holeResults,
    required this.players,
    required this.mode,
    this.onScoreChanged,
  });

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
          // Matrix Title
          Row(
            children: [
              Icon(
                Icons.grid_view_rounded,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hole-by-Hole Skins Ledger',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                mode == SkinsScoringMode.gross ? 'Gross Lowest' : 'Net Lowest',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Hole Cards List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: holeResults.length,
            separatorBuilder: (_, _) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final hole = holeResults[index];
              return _buildHoleCard(context, index, hole);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHoleCard(
    BuildContext context,
    int holeIndex,
    HoleSkinResult hole,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    Color badgeBg;
    Color badgeBorder;
    Color badgeFg;
    String badgeText;
    IconData badgeIcon;

    if (hole.isPending) {
      badgeBg = colorScheme.surfaceContainerHighest;
      badgeBorder = colorScheme.outlineVariant;
      badgeFg = colorScheme.onSurfaceVariant;
      badgeText = 'Unplayed';
      badgeIcon = Icons.hourglass_empty_rounded;
    } else if (hole.hasWinner) {
      badgeBg = colorScheme.primary.withValues(alpha: 0.15);
      badgeBorder = colorScheme.primary.withValues(alpha: 0.4);
      badgeFg = colorScheme.primary;
      final firstName = hole.winnerPlayerName?.split(' ').first ?? 'Won';
      badgeText = '$firstName (+${hole.skinsWonCount})';
      badgeIcon = Icons.check_circle_rounded;
    } else {
      badgeBg = colorScheme.tertiary.withValues(alpha: 0.15);
      badgeBorder = colorScheme.tertiary.withValues(alpha: 0.4);
      badgeFg = colorScheme.tertiary;
      badgeText = 'Tie (+1)';
      badgeIcon = Icons.sync_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: hole.hasWinner
            ? colorScheme.primary.withValues(alpha: 0.05)
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hole.hasWinner
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hole Meta Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#${hole.holeNumber}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'P${hole.par} • SI${hole.strokeIndex}',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: badgeBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(badgeIcon, size: 12, color: badgeFg),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: badgeFg,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Scores Row for all players
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: players.map((player) {
                final gross = hole.playerGrossScores[player.id] ?? 0;
                final net = hole.playerNetScores[player.id] ?? gross;
                final strokesRec = hole.playerStrokesReceived[player.id] ?? 0;
                final isWinner = hole.winnerPlayerId == player.id;

                final displayScore = mode == SkinsScoringMode.gross
                    ? '$gross'
                    : '$net';

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: onScoreChanged != null
                        ? () => onScoreChanged!(
                            player.id,
                            holeIndex,
                            gross >= 9
                                ? hole.par
                                : (gross <= 0 ? hole.par : gross + 1),
                          )
                        : null,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isWinner
                            ? colorScheme.primary.withValues(alpha: 0.18)
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isWinner
                              ? colorScheme.primary
                              : colorScheme.outlineVariant.withValues(
                                  alpha: 0.5,
                                ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            player.name.split(' ').first,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isWinner
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isWinner
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            displayScore,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isWinner
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                            ),
                          ),
                          if (mode == SkinsScoringMode.net &&
                              strokesRec > 0) ...[
                            Text(
                              '(-$strokesRec)',
                              style: TextStyle(
                                fontSize: 9,
                                color: colorScheme.secondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
