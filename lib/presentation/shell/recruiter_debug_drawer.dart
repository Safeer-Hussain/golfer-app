import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/utils/app_feedback.dart';
import '../settings/settings_controller.dart';

class RecruiterDebugDrawer extends StatelessWidget {
  const RecruiterDebugDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = sl<SettingsController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: SafeArea(
        child: ListenableBuilder(
          listenable: settingsController,
          builder: (context, _) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Recruiter Debug Engine',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Simulate real-world field conditions, zero-cost latency, and offline SQLite resilience.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Divider(height: 24),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Simulate Network Latency',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Injects 400ms-800ms randomized server latency to verify async UI robustness.',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  value: settingsController.simulateLatency,
                  onChanged: (val) {
                    settingsController.toggleSimulateLatency(val);
                    AppFeedback.showInfo(
                      context,
                      val
                          ? 'Simulated latency active (400-800ms)'
                          : 'Simulated latency disabled',
                    );
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Force HTTP 503 Outage',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Forces mock network interceptor to reject requests with 503 Service Unavailable.',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  value: settingsController.simulateError,
                  onChanged: (val) {
                    settingsController.toggleSimulateError(val);
                    if (val) {
                      AppFeedback.showWarning(
                        context,
                        'HTTP 503 simulation enabled',
                      );
                    } else {
                      AppFeedback.showSuccess(
                        context,
                        'Network restored to normal',
                      );
                    }
                  },
                ),
                const Divider(height: 24),
                Text(
                  'Live Tournament Cloud Sync',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: settingsController.isLoadingTournament
                      ? null
                      : () => settingsController.testTournamentSync(),
                  icon: settingsController.isLoadingTournament
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.sync_rounded, size: 18),
                  label: Text(
                    settingsController.isLoadingTournament
                        ? 'Syncing Leaderboard...'
                        : 'Trigger Cloud Sync Request',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
                if (settingsController.tournamentError != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'Sync Error (Handled defensively):\n${settingsController.tournamentError}',
                      style: TextStyle(fontSize: 11, color: colorScheme.error),
                    ),
                  ),
                ],
                if (settingsController.liveTournamentData != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settingsController.liveTournamentData!['tournament']
                                  as String? ??
                              'Tournament',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          settingsController.liveTournamentData!['status']
                                  as String? ??
                              '',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...((settingsController.liveTournamentData!['leaders']
                                    as List<dynamic>?) ??
                                [])
                            .map(
                              (leader) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${leader['rank']}. ${leader['player']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      '${leader['score'] > 0 ? "+${leader['score']}" : (leader['score'] == 0 ? "E" : leader['score'])}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Architectural Notice',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This application operates with zero external paid APIs. Local persistence via SharedPreferences (active round) and SQLite (historical rounds, club calibrations, social feed) ensures 100% offline flight capability.',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
