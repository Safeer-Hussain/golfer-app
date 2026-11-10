import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../green_reading/green_reading_view.dart';
import 'scorecard_controller.dart';
import 'widgets/hole_stepper_cockpit.dart';
import 'widgets/leaderboard_drawer.dart';
import 'widgets/nassau_press_modal.dart';
import 'widgets/player_hole_row.dart';
import 'widgets/round_summary_tabs.dart';
import 'widgets/share_scorecard_sheet.dart';

class ScorecardView extends StatefulWidget {
  final VoidCallback? onOpenRangefinder;
  final VoidCallback? onOpenAiCaddie;

  const ScorecardView({
    super.key,
    this.onOpenRangefinder,
    this.onOpenAiCaddie,
  });

  @override
  State<ScorecardView> createState() => _ScorecardViewState();
}

class _ScorecardViewState extends State<ScorecardView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _viewMode = 0; // 0: Hole Cockpit, 1: Round Matrix

  void _openShareSheet(BuildContext context, ScorecardController controller) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      builder: (ctx) => ShareScorecardSheet(controller: controller),
    );
  }

  void _openNassauModal(BuildContext context, ScorecardController controller) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      builder: (ctx) => NassauPressModal(controller: controller),
    );
  }

  void _openGreenReading(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const GreenReadingView(),
      ),
    );
  }

  Widget _buildCockpitPane(BuildContext context, ScorecardController controller) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 76),
      child: Column(
        children: [
          HoleStepperCockpit(
            hole: controller.currentHole,
            currentHoleIndex: controller.currentHoleIndex,
            teeBox: controller.activeScorecard.teeBox,
            onSelectHole: controller.setHoleIndex,
            onPrev: controller.previousHole,
            onNext: controller.nextHole,
          ),
          // Quick actions banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onOpenRangefinder,
                    icon: const Icon(Icons.my_location_rounded, size: 15),
                    label: const Text('Pin (GPS)', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openGreenReading(context),
                    icon: const Icon(Icons.speed_rounded, size: 15),
                    label: const Text('Green Reading', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.tertiary,
                      side: BorderSide(color: colorScheme.tertiary.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onOpenAiCaddie,
                    icon: const Icon(Icons.smart_toy_rounded, size: 15),
                    label: const Text('Strategy', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.secondary,
                      side: BorderSide(color: colorScheme.secondary.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...controller.players.map((player) {
            final score = controller.getScoreForPlayer(
              player.id,
              controller.currentHole.holeNumber,
            );

            return PlayerHoleRow(
              player: player,
              hole: controller.currentHole,
              score: score,
              onStrokesChanged: (delta) => controller.updateStrokes(
                player.id,
                controller.currentHole.holeNumber,
                delta,
              ),
              onPuttsChanged: (delta) => controller.updatePutts(
                player.id,
                controller.currentHole.holeNumber,
                delta,
              ),
              onFirChanged: (fir) => controller.updateFir(
                player.id,
                controller.currentHole.holeNumber,
                fir,
              ),
              onToggleGir: () => controller.toggleGir(
                player.id,
                controller.currentHole.holeNumber,
              ),
              onToggleBunker: () => controller.toggleBunker(
                player.id,
                controller.currentHole.holeNumber,
              ),
              onTogglePenalty: () => controller.togglePenalty(
                player.id,
                controller.currentHole.holeNumber,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMatrixPane(BuildContext context, ScorecardController controller) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 76),
      child: RoundSummaryTabs(
        course: controller.course,
        scorecard: controller.activeScorecard,
        players: controller.players,
        teeBox: controller.activeScorecard.teeBox,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = sl<ScorecardController>();
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Scaffold(
          key: _scaffoldKey,
          endDrawer: LeaderboardDrawer(controller: controller),
          body: Column(
            children: [
              // View toggle bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                color: colorScheme.surface,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!isLandscape)
                      SegmentedButton<int>(
                        segments: const [
                          ButtonSegment<int>(value: 0, label: Text('Cockpit', style: TextStyle(fontSize: 11))),
                          ButtonSegment<int>(value: 1, label: Text('Matrix', style: TextStyle(fontSize: 11))),
                        ],
                        selected: {_viewMode},
                        onSelectionChanged: (set) => setState(() => _viewMode = set.first),
                        style: ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                    else
                      Text(
                        'Cockpit & Full 18 Matrix',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.speed_rounded, size: 20, color: colorScheme.tertiary),
                          tooltip: 'Green Reading & Stimpmeter',
                          onPressed: () => _openGreenReading(context),
                        ),
                        IconButton(
                          icon: Icon(Icons.handshake_outlined, size: 20, color: colorScheme.secondary),
                          tooltip: 'Nassau Side-Bets',
                          onPressed: () => _openNassauModal(context, controller),
                        ),
                        IconButton(
                          icon: Icon(Icons.share_outlined, size: 20, color: colorScheme.onSurfaceVariant),
                          tooltip: 'Share Scorecard',
                          onPressed: () => _openShareSheet(context, controller),
                        ),
                        IconButton(
                          icon: Icon(Icons.leaderboard_outlined, size: 20, color: colorScheme.primary),
                          tooltip: 'Live Leaderboard',
                          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: isLandscape
                    ? Row(
                        children: [
                          Expanded(child: _buildCockpitPane(context, controller)),
                          VerticalDivider(width: 1, color: colorScheme.outlineVariant),
                          Expanded(child: _buildMatrixPane(context, controller)),
                        ],
                      )
                    : (_viewMode == 0
                        ? _buildCockpitPane(context, controller)
                        : _buildMatrixPane(context, controller)),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_scorecard_quick_log',
            onPressed: () {
              if (controller.currentHoleIndex < 17) {
                controller.nextHole();
              } else {
                _scaffoldKey.currentState?.openEndDrawer();
              }
            },
            icon: Icon(controller.currentHoleIndex < 17 ? Icons.arrow_forward : Icons.done_all_rounded),
            label: Text(controller.currentHoleIndex < 17 ? 'Hole ${controller.currentHoleIndex + 2}' : 'Verify Round'),
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
        );
      },
    );
  }
}
