import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/golf_courses.dart';
import '../../core/di/service_locator.dart';
import '../../data/repositories/flight_repository.dart';
import '../scorecard/scorecard_controller.dart';
import 'flight_setup_controller.dart';
import 'widgets/add_player_modal.dart';
import 'widgets/player_card.dart';
import 'widgets/tee_box_selector.dart';

class FlightSetupView extends StatelessWidget {
  final VoidCallback onStartRound;

  const FlightSetupView({
    super.key,
    required this.onStartRound,
  });

  void _showAddCustomPlayer(BuildContext context, FlightSetupController controller) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      builder: (ctx) => AddPlayerModal(
        onAddPlayer: ({required name, required handicap, required teeBox}) {
          controller.addCustomPlayer(
            name: name,
            handicap: handicap,
            teeBox: teeBox,
          );
        },
      ),
    );
  }

  void _showAddMemberModal(BuildContext context, FlightSetupController controller) {
    final colorScheme = Theme.of(context).colorScheme;
    final available = FlightRepository.availableClubMembers.where(
      (m) => !controller.flightPlayers.any((p) => p.id == m.id),
    ).toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surfaceContainer,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Club Member',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              if (available.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'All club members already in flight.',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                )
              else
                ...available.map((member) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(member.avatarAsset),
                      ),
                      title: Text(
                        member.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        'Handicap Index: ${member.handicapIndex}',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          controller.addMemberPlayer(member);
                          Navigator.of(ctx).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                        child: const Text('Add'),
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftPane(BuildContext context, FlightSetupController controller) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Championship Course',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 145,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: GolfCourses.allCourses.length,
              itemBuilder: (context, index) {
                final c = GolfCourses.allCourses[index];
                final isSelected = c.id == controller.selectedCourse.id;

                return GestureDetector(
                  onTap: () => controller.selectCourse(c),
                  child: Container(
                    width: 210,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                c.imageAsset,
                                fit: BoxFit.cover,
                              ),
                              if (isSelected)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      size: 14,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Par ${c.par} • ${c.totalYardage} yds • Slope ${c.slope}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          TeeBoxSelector(
            course: controller.selectedCourse,
            selectedTee: controller.selectedTee,
            onTeeSelected: controller.selectTee,
          ),
          const SizedBox(height: 16),
          Text(
            'Game Format',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppConstants.formatStrokePlay,
              AppConstants.formatStableford,
              AppConstants.formatMatchPlay,
              AppConstants.formatScramble,
            ].map((f) {
              final isSel = f == controller.selectedFormat;
              return ChoiceChip(
                label: Text(
                  f,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    color: isSel ? colorScheme.onPrimary : colorScheme.onSurface,
                  ),
                ),
                selected: isSel,
                selectedColor: colorScheme.primary,
                backgroundColor: colorScheme.surfaceContainer,
                onSelected: (_) => controller.selectFormat(f),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPane(BuildContext context, FlightSetupController controller) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                'Active Flight Roster (${controller.flightPlayers.length}/4)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              if (controller.canAddMorePlayers)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showAddMemberModal(context, controller),
                      icon: const Icon(Icons.group_add_outlined, size: 16),
                      label: const Text('Member', style: TextStyle(fontSize: 11)),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.secondary,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddCustomPlayer(context, controller),
                      icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
                      label: const Text('Custom', style: TextStyle(fontSize: 11)),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 6),
          ...controller.flightPlayers.map(
            (player) => PlayerCard(
              player: player,
              canRemove: controller.flightPlayers.length > 1,
              onRemove: () => controller.removePlayer(player.id),
              onTeeChanged: (tee) => controller.updatePlayerTee(player.id, tee),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.sports_golf_rounded, color: colorScheme.secondary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Flight Ready to Tee Off',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '18-hole scorecards auto-configured with World Handicap System slope adjustments.',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await controller.saveAndStartRound();
                sl<ScorecardController>().initializeWithFlight(controller.getCurrentFlightModel());
                onStartRound();
              },
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: const Text(
                'Tee Off / Resume Active Round',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 70), // Spacing for floating button
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = sl<FlightSetupController>();
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Scaffold(
          body: isLandscape
              ? Row(
                  children: [
                    Expanded(child: _buildLeftPane(context, controller)),
                    VerticalDivider(width: 1, color: Theme.of(context).colorScheme.outlineVariant),
                    Expanded(child: _buildRightPane(context, controller)),
                  ],
                )
              : SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildLeftPane(context, controller),
                      const Divider(height: 1),
                      _buildRightPane(context, controller),
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_flight_start',
            onPressed: () async {
              await controller.saveAndStartRound();
              sl<ScorecardController>().initializeWithFlight(controller.getCurrentFlightModel());
              onStartRound();
            },
            icon: const Icon(Icons.sports_golf_rounded),
            label: const Text('Start 18 Holes'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
        );
      },
    );
  }
}
