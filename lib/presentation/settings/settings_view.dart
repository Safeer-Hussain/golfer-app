import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/utils/app_feedback.dart';
import '../shell/recruiter_debug_drawer.dart';
import 'settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = sl<SettingsController>();
    final themeController = sl<ThemeController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: ListenableBuilder(
        listenable: Listenable.merge([settingsController, themeController]),
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              Text(
                'Player & Unit Preferences',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.straighten_rounded, color: colorScheme.primary),
                      title: Text(
                        'Distance Unit System',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                      ),
                      subtitle: Text(
                        settingsController.unitSystem == 'yards'
                            ? 'Yards (Imperial Championship Standard)'
                            : 'Meters (Metric Standard)',
                        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                      ),
                      trailing: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment<String>(value: 'yards', label: Text('Yards', style: TextStyle(fontSize: 11))),
                          ButtonSegment<String>(value: 'meters', label: Text('Meters', style: TextStyle(fontSize: 11))),
                        ],
                        selected: {settingsController.unitSystem},
                        onSelectionChanged: (set) => settingsController.setUnitSystem(set.first),
                        style: ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        themeController.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: colorScheme.secondary,
                      ),
                      title: Text(
                        'Appearance Palette',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                      ),
                      subtitle: Text(
                        themeController.isDarkMode
                            ? 'Augusta Emerald Dark'
                            : 'Crisp Fairway Light',
                        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                      ),
                      trailing: Switch.adaptive(
                        value: themeController.isDarkMode,
                        activeTrackColor: colorScheme.primary,
                        onChanged: (_) => themeController.toggleTheme(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Offline & Engine Diagnostics',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        settingsController.isOffline ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
                        color: settingsController.isOffline ? colorScheme.secondary : colorScheme.primary,
                      ),
                      title: Text(
                        'Course Connection Status',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                      ),
                      subtitle: Text(
                        settingsController.isOffline
                            ? 'Offline Course Mode • Local SQLite & SharedPreferences active'
                            : 'Connected • Background telemetry ready',
                        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.bug_report_outlined, color: colorScheme.secondary),
                      title: Text(
                        'Recruiter Debug Drawer',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                      ),
                      subtitle: Text(
                        'Test simulated latency, HTTP 503 errors, and tournament sync',
                        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      onTap: () {
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (ctx) => const RecruiterDebugDrawer(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // App Version & Long-Press Easter Egg
              Center(
                child: GestureDetector(
                  onLongPress: () {
                    AppFeedback.showSuccess(context, 'Recruiter Debug Drawer unlocked.');
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (ctx) => const RecruiterDebugDrawer(),
                    );
                  },
                  child: Column(
                    children: [
                      Text(
                        '${AppConstants.appName} v${AppConstants.appVersion}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Long press for Recruiter Field Testing Console',
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
