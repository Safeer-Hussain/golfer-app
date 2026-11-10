import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/theme_controller.dart';
import '../ai_caddie/ai_caddie_view.dart';
import '../clubhouse_analytics/clubhouse_analytics_view.dart';
import '../flight_setup/flight_setup_view.dart';
import '../rangefinder/rangefinder_view.dart';
import '../scorecard/scorecard_view.dart';
import '../settings/settings_view.dart';
import 'offline_banner.dart';
import 'recruiter_debug_drawer.dart';

class AdaptiveScaffold extends StatefulWidget {
  final int initialIndex;

  const AdaptiveScaffold({super.key, this.initialIndex = 0});

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  late int _currentIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void onNavigate(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return FlightSetupView(onStartRound: () => onNavigate(1));
      case 1:
        return ScorecardView(
          onOpenRangefinder: () => onNavigate(2),
          onOpenAiCaddie: () => onNavigate(3),
        );
      case 2:
        return const RangefinderView();
      case 3:
        return const AiGolfCaddieView();
      case 4:
        return const ClubhouseAnalyticsView();
      case 5:
        return const SettingsView();
      default:
        return FlightSetupView(onStartRound: () => onNavigate(1));
    }
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Flight Setup';
      case 1:
        return 'Digital Scorecard';
      case 2:
        return 'GPS Rangefinder';
      case 3:
        return 'AI Golf Caddie';
      case 4:
        return 'Clubhouse & Analytics';
      case 5:
        return 'Settings & Calibrations';
      default:
        return 'Golfer';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeController = sl<ThemeController>();
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: colorScheme.surface,
        endDrawer: const RecruiterDebugDrawer(),
        appBar: AppBar(
          toolbarHeight: isLandscape ? 38 : 52,
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Center(
              child: Container(
                width: isLandscape ? 26 : 32,
                height: isLandscape ? 26 : 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary, width: 1.5),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/icons/app_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          title: Text(
            _getTitle(),
            style: TextStyle(
              fontSize: isLandscape ? 13 : 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
              color: colorScheme.onSurface,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                themeController.isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                size: isLandscape ? 18 : 22,
                color: colorScheme.onSurfaceVariant,
              ),
              tooltip: 'Toggle Dark/Light Mode',
              onPressed: () => themeController.toggleTheme(),
            ),
            IconButton(
              icon: Icon(
                Icons.settings_outlined,
                size: isLandscape ? 18 : 22,
                color: _currentIndex == 5
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              tooltip: 'Settings',
              onPressed: () => onNavigate(5),
            ),
            IconButton(
              icon: Icon(
                Icons.tune_rounded,
                size: isLandscape ? 18 : 22,
                color: colorScheme.secondary,
              ),
              tooltip: 'Recruiter Debug Engine',
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: isLandscape
                  ? Row(
                      children: [
                        SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: IntrinsicHeight(
                            child: NavigationRail(
                              minWidth: 56,
                              selectedIndex: _currentIndex > 4
                                  ? 0
                                  : _currentIndex,
                              onDestinationSelected: onNavigate,
                              labelType: NavigationRailLabelType.none,
                              backgroundColor: colorScheme.surfaceContainer,
                              indicatorColor: colorScheme.primary.withValues(
                                alpha: 0.2,
                              ),
                              destinations: [
                                NavigationRailDestination(
                                  icon: Icon(
                                    Icons.group_outlined,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  selectedIcon: Icon(
                                    Icons.group_rounded,
                                    color: colorScheme.primary,
                                  ),
                                  label: const Text('Flight'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(
                                    Icons.format_list_numbered_outlined,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  selectedIcon: Icon(
                                    Icons.format_list_numbered_rounded,
                                    color: colorScheme.primary,
                                  ),
                                  label: const Text('Scorecard'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(
                                    Icons.my_location_outlined,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  selectedIcon: Icon(
                                    Icons.my_location_rounded,
                                    color: colorScheme.primary,
                                  ),
                                  label: const Text('Rangefinder'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(
                                    Icons.smart_toy_outlined,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  selectedIcon: Icon(
                                    Icons.smart_toy_rounded,
                                    color: colorScheme.primary,
                                  ),
                                  label: const Text('Caddie'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(
                                    Icons.military_tech_outlined,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  selectedIcon: Icon(
                                    Icons.military_tech_rounded,
                                    color: colorScheme.primary,
                                  ),
                                  label: const Text('Clubhouse'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: colorScheme.outlineVariant,
                        ),
                        Expanded(child: _buildBody()),
                      ],
                    )
                  : _buildBody(),
            ),
          ],
        ),
        bottomNavigationBar: isLandscape
            ? null
            : NavigationBar(
                selectedIndex: _currentIndex > 4 ? 0 : _currentIndex,
                onDestinationSelected: onNavigate,
                backgroundColor: colorScheme.surfaceContainer,
                indicatorColor: colorScheme.primary.withValues(alpha: 0.2),
                height: 64,
                elevation: 3,
                destinations: [
                  NavigationDestination(
                    icon: Icon(
                      Icons.group_outlined,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    selectedIcon: Icon(
                      Icons.group_rounded,
                      color: colorScheme.primary,
                    ),
                    label: 'Flight',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.format_list_numbered_outlined,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    selectedIcon: Icon(
                      Icons.format_list_numbered_rounded,
                      color: colorScheme.primary,
                    ),
                    label: 'Scorecard',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.my_location_outlined,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    selectedIcon: Icon(
                      Icons.my_location_rounded,
                      color: colorScheme.primary,
                    ),
                    label: 'GPS Map',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.smart_toy_outlined,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    selectedIcon: Icon(
                      Icons.smart_toy_rounded,
                      color: colorScheme.primary,
                    ),
                    label: 'AI Caddie',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.military_tech_outlined,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    selectedIcon: Icon(
                      Icons.military_tech_rounded,
                      color: colorScheme.primary,
                    ),
                    label: 'Clubhouse',
                  ),
                ],
              ),
      ),
    );
  }
}
