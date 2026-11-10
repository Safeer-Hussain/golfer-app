import 'package:flutter/material.dart';

import '../../../data/models/player_model.dart';
import '../scorecard_controller.dart';

class LeaderboardDrawer extends StatelessWidget {
  final ScorecardController controller;

  const LeaderboardDrawer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final leaderboard = controller.getLeaderboard();

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            Row(
              children: [
                Icon(
                  Icons.leaderboard_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  'Flight Live Leaderboard',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${controller.course.name} • ${controller.activeScorecard.gameFormat}',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Divider(height: 24),
            ...leaderboard.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final data = entry.value;
              final player = data['player'] as PlayerModel;
              final gross = data['gross'] as int;
              final net = data['net'] as int;
              final points = data['points'] as int;
              final diffVsPar = data['diffVsPar'] as String;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: player.isCurrentDeviceUser
                        ? colorScheme.primary.withValues(alpha: 0.5)
                        : colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: rank == 1
                            ? colorScheme.secondary
                            : colorScheme.surfaceContainerHighest,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: rank == 1
                              ? colorScheme.onSecondary
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: AssetImage(player.avatarAsset),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            player.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Gross: $gross ($diffVsPar) • Net: $net',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$points Pts',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                controller.completeRound();
              },
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Verify & Archive Round to SQLite'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
