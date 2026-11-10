import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import 'clubhouse_controller.dart';
import 'widgets/club_bag_calibrator_tab.dart';
import 'widgets/clubhouse_feed_tab.dart';
import 'widgets/handicap_analytics_tab.dart';
import 'widgets/post_milestone_modal.dart';

class ClubhouseAnalyticsView extends StatefulWidget {
  const ClubhouseAnalyticsView({super.key});

  @override
  State<ClubhouseAnalyticsView> createState() => _ClubhouseAnalyticsViewState();
}

class _ClubhouseAnalyticsViewState extends State<ClubhouseAnalyticsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openPostMilestoneModal(
    BuildContext context,
    ClubhouseController controller,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      builder: (ctx) => PostMilestoneModal(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = sl<ClubhouseController>();
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(46),
            child: Container(
              color: colorScheme.surface,
              child: TabBar(
                controller: _tabController,
                indicatorColor: colorScheme.primary,
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                ),
                tabs: const [
                  Tab(text: 'Analytics'),
                  Tab(text: '14-Club Bag'),
                  Tab(text: 'Clubhouse Feed'),
                ],
              ),
            ),
          ),
          body: isLandscape
              ? Row(
                  children: [
                    const Expanded(flex: 3, child: HandicapAnalyticsTab()),
                    VerticalDivider(
                      width: 1,
                      color: colorScheme.outlineVariant,
                    ),
                    Expanded(
                      flex: 4,
                      child: _tabController.index == 1
                          ? ClubBagCalibratorTab(controller: controller)
                          : ClubhouseFeedTab(controller: controller),
                    ),
                  ],
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    const HandicapAnalyticsTab(),
                    ClubBagCalibratorTab(controller: controller),
                    ClubhouseFeedTab(controller: controller),
                  ],
                ),
          floatingActionButton: _tabController.index == 2
              ? FloatingActionButton.extended(
                  heroTag: 'fab_clubhouse_post',
                  onPressed: () => _openPostMilestoneModal(context, controller),
                  icon: const Icon(Icons.add_comment_rounded),
                  label: const Text('Post Milestone'),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                )
              : null,
        );
      },
    );
  }
}
