import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../core/utils/app_feedback.dart';
import 'skins_pot_controller.dart';
import 'widgets/skins_hole_matrix.dart';
import 'widgets/skins_payout_ledger_card.dart';
import 'widgets/skins_rules_modal.dart';
import 'widgets/skins_summary_cockpit_card.dart';

class SkinsPotView extends StatefulWidget {
  const SkinsPotView({super.key});

  @override
  State<SkinsPotView> createState() => _SkinsPotViewState();
}

class _SkinsPotViewState extends State<SkinsPotView> {
  late final SkinsPotController _controller;
  final ScrollController _portraitScrollController = ScrollController();
  final ScrollController _landscapeLeftController = ScrollController();
  final ScrollController _landscapeRightController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = GetIt.I<SkinsPotController>();
  }

  @override
  void dispose() {
    _portraitScrollController.dispose();
    _landscapeLeftController.dispose();
    _landscapeRightController.dispose();
    super.dispose();
  }

  void _showRulesModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SkinsRulesModal(),
    );
  }

  void _sharePayoutLedger(BuildContext context) {
    final result = _controller.gameResult;
    final leader = result.leadingPlayer;
    final leaderText = leader != null
        ? 'Winner: ${leader.playerName} (${leader.skinsWonCount} skins, +\$${leader.netBalance.toStringAsFixed(0)})'
        : 'Skins Pot in progress';

    AppFeedback.showSuccess(
      context,
      'Skins Payout Ledger exported: \$${result.totalPot.toStringAsFixed(0)} Pot. $leaderText',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Tournament Skins Pot'),
        toolbarHeight: isLandscape ? 40 : kToolbarHeight,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Skins Game Rules',
            onPressed: () => _showRulesModal(context),
          ),
          IconButton(
            icon: Icon(
              _controller.useSimulatedScores
                  ? Icons.casino_rounded
                  : Icons.casino_outlined,
            ),
            tooltip: 'Toggle Simulation Demo',
            onPressed: _controller.toggleSimulatedScores,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final result = _controller.gameResult;

          if (isLandscape) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Pane: Summary Cockpit & Payout Ledger
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    controller: _landscapeLeftController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SkinsSummaryCockpitCard(
                          result: result,
                          onModeChanged: _controller.setMode,
                          onStakeChanged: _controller.setStakePerHole,
                        ),
                        const SizedBox(height: 12),
                        SkinsPayoutLedgerCard(
                          result: result,
                          onRuleChanged: _controller.setHole18Rule,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(width: 1, color: colorScheme.outlineVariant),
                // Right Pane: Hole-by-Hole Skins Ledger
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    controller: _landscapeRightController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SkinsHoleMatrix(
                          holeResults: result.holeResults,
                          players: _controller.players,
                          mode: _controller.mode,
                          onScoreChanged: _controller.updatePlayerHoleScore,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          // Portrait View
          return SingleChildScrollView(
            controller: _portraitScrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SkinsSummaryCockpitCard(
                  result: result,
                  onModeChanged: _controller.setMode,
                  onStakeChanged: _controller.setStakePerHole,
                ),
                const SizedBox(height: 14),
                SkinsPayoutLedgerCard(
                  result: result,
                  onRuleChanged: _controller.setHole18Rule,
                ),
                const SizedBox(height: 14),
                SkinsHoleMatrix(
                  holeResults: result.holeResults,
                  players: _controller.players,
                  mode: _controller.mode,
                  onScoreChanged: _controller.updatePlayerHoleScore,
                ),
                const SizedBox(height: 28),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_skins_share',
        onPressed: () => _sharePayoutLedger(context),
        icon: const Icon(Icons.share_rounded, size: 18),
        label: const Text('SHARE PAYOUTS'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }
}
