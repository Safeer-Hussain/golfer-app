import 'package:flutter/material.dart';

import '../../../data/models/player_model.dart';
import '../../../data/models/round_scorecard_model.dart';
import '../../../domain/entities/course_entity.dart';

class RoundSummaryTabs extends StatelessWidget {
  final CourseEntity course;
  final RoundScorecardModel scorecard;
  final List<PlayerModel> players;
  final String teeBox;

  const RoundSummaryTabs({
    super.key,
    required this.course,
    required this.scorecard,
    required this.players,
    required this.teeBox,
  });

  Widget _buildScoreCell(BuildContext context, int strokes, int par) {
    final colorScheme = Theme.of(context).colorScheme;
    final diff = strokes - par;

    Color color = colorScheme.onSurface;
    if (diff <= -1) color = colorScheme.primary;
    if (diff >= 1) color = colorScheme.secondary;

    return Center(
      child: Text(
        '$strokes',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMatrixTable(
    BuildContext context,
    int startHole,
    int endHole,
    String title,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final holesInRange = course.holes
        .where((h) => h.holeNumber >= startHole && h.holeNumber <= endHole)
        .toList();

    final parTotal = holesInRange.fold<int>(0, (sum, h) => sum + h.par);
    final ydsTotal = holesInRange.fold<int>(
      0,
      (sum, h) => sum + h.yardageForTee(teeBox),
    );

    return Card(
      color: colorScheme.surfaceContainer,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
                ),
                Text(
                  'Par: $parTotal  •  $ydsTotal YDS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: Table(
                defaultColumnWidth: const FixedColumnWidth(42),
                columnWidths: const {0: FixedColumnWidth(110)},
                border: TableBorder.all(
                  color: colorScheme.outlineVariant,
                  width: 0.5,
                ),
                children: [
                  // Hole Headers
                  TableRow(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          'HOLE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      ...holesInRange.map(
                        (h) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              '${h.holeNumber}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(
                            'TOT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Par Row
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          'PAR',
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      ...holesInRange.map(
                        (h) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              '${h.par}',
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(
                            '$parTotal',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Player Rows
                  ...players.map((player) {
                    final scores = scorecard.playerScores[player.id] ?? [];
                    int subtotal = 0;
                    final cells = <Widget>[];

                    for (final h in holesInRange) {
                      final match = scores.where(
                        (s) => s.holeNumber == h.holeNumber,
                      );
                      final strokes = match.isNotEmpty
                          ? match.first.strokes
                          : h.par;
                      subtotal += strokes;
                      cells.add(_buildScoreCell(context, strokes, h.par));
                    }

                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(
                            player.name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: player.isCurrentDeviceUser
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ...cells,
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              '$subtotal',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMatrixTable(context, 1, 9, 'FRONT 9 (OUT)'),
        _buildMatrixTable(context, 10, 18, 'BACK 9 (IN)'),
        _buildMatrixTable(context, 1, 18, '18-HOLE CHAMPIONSHIP TOTAL'),
      ],
    );
  }
}
