import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'green_reading_controller.dart';
import 'widgets/bubble_level_indicator.dart';
import 'widgets/putt_trajectory_card.dart';
import 'widgets/stimp_selector.dart';

class GreenReadingView extends StatefulWidget {
  const GreenReadingView({super.key});

  @override
  State<GreenReadingView> createState() => _GreenReadingViewState();
}

class _GreenReadingViewState extends State<GreenReadingView> {
  late final GreenReadingController _controller;
  final ScrollController _portraitScrollController = ScrollController();
  final ScrollController _landscapeLeftController = ScrollController();
  final ScrollController _landscapeRightController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = GetIt.I<GreenReadingController>();
  }

  @override
  void dispose() {
    _portraitScrollController.dispose();
    _landscapeLeftController.dispose();
    _landscapeRightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Green Reading & Stimpmeter'),
        toolbarHeight: isLandscape ? 40 : kToolbarHeight,
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Reset Level',
            onPressed: () {
              _controller.applyPreset(
                slopeDegrees: 1.5,
                fallLineHeading: 90.0,
                stimpSpeed: 10.5,
                puttDistance: 15.0,
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final reading = _controller.reading;
          final result = _controller.calculationResult;

          if (isLandscape) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Master Pane: Level & Slope controls
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    controller: _landscapeLeftController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        BubbleLevelIndicator(
                          slopeDegrees: reading.slopeDegrees,
                          fallLineHeadingDegrees: reading.fallLineHeadingDegrees,
                        ),
                        const SizedBox(height: 12),
                        _buildSlopeControls(context, reading),
                        const SizedBox(height: 12),
                        _buildHeadingControls(context, reading),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(width: 1, color: colorScheme.outlineVariant),
                // Right Detail Pane: Presets, Distance, Stimp & Trajectory
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    controller: _landscapeRightController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildPresetChips(context),
                        const SizedBox(height: 12),
                        _buildDistanceSelector(context, reading),
                        const SizedBox(height: 12),
                        StimpSelector(
                          currentStimp: reading.stimpSpeed,
                          onStimpChanged: _controller.setStimpSpeed,
                        ),
                        const SizedBox(height: 12),
                        PuttTrajectoryCard(result: result),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          // Portrait Single-Column
          return SingleChildScrollView(
            controller: _portraitScrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPresetChips(context),
                const SizedBox(height: 16),
                Center(
                  child: BubbleLevelIndicator(
                    slopeDegrees: reading.slopeDegrees,
                    fallLineHeadingDegrees: reading.fallLineHeadingDegrees,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSlopeControls(context, reading),
                const SizedBox(height: 12),
                _buildHeadingControls(context, reading),
                const SizedBox(height: 16),
                _buildDistanceSelector(context, reading),
                const SizedBox(height: 16),
                StimpSelector(
                  currentStimp: reading.stimpSpeed,
                  onStimpChanged: _controller.setStimpSpeed,
                ),
                const SizedBox(height: 16),
                PuttTrajectoryCard(result: result),
                const SizedBox(height: 28),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPresetChips(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final presets = [
      {'label': 'Flat (0.5°)', 'slope': 0.5, 'fall': 90.0, 'stimp': 10.0},
      {'label': 'Moderate (1.5°)', 'slope': 1.5, 'fall': 90.0, 'stimp': 10.5},
      {'label': 'Championship (2.5°)', 'slope': 2.5, 'fall': 120.0, 'stimp': 11.5},
      {'label': 'False Front (4.0°)', 'slope': 4.0, 'fall': 0.0, 'stimp': 12.0},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: presets.map((preset) {
          final slope = preset['slope'] as double;
          final isSelected = (_controller.reading.slopeDegrees - slope).abs() < 0.2;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(preset['label'] as String),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _controller.applyPreset(
                    slopeDegrees: slope,
                    fallLineHeading: preset['fall'] as double,
                    stimpSpeed: preset['stimp'] as double,
                  );
                }
              },
              selectedColor: colorScheme.primaryContainer,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSlopeControls(BuildContext context, dynamic reading) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Green Incline (Slope)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                '${reading.slopeDegrees.toStringAsFixed(1)}° (${reading.slopePercent.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor: colorScheme.surfaceContainerHighest,
              thumbColor: colorScheme.primary,
              trackHeight: 3,
            ),
            child: Slider(
              value: reading.slopeDegrees,
              min: 0.0,
              max: 5.5,
              divisions: 55,
              onChanged: _controller.setSlopeDegrees,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadingControls(BuildContext context, dynamic reading) {
    final colorScheme = Theme.of(context).colorScheme;

    String getHeadingCardinal(double deg) {
      if (deg >= 337.5 || deg < 22.5) return 'Downhill N (0°)';
      if (deg >= 22.5 && deg < 67.5) return 'Downhill NE (45°)';
      if (deg >= 67.5 && deg < 112.5) return 'Downhill E (90°)';
      if (deg >= 112.5 && deg < 157.5) return 'Downhill SE (135°)';
      if (deg >= 157.5 && deg < 202.5) return 'Downhill S (180°)';
      if (deg >= 202.5 && deg < 247.5) return 'Downhill SW (225°)';
      if (deg >= 247.5 && deg < 292.5) return 'Downhill W (270°)';
      return 'Downhill NW (315°)';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Fall Line Orientation',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                getHeadingCardinal(reading.fallLineHeadingDegrees),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colorScheme.secondary,
              inactiveTrackColor: colorScheme.surfaceContainerHighest,
              thumbColor: colorScheme.secondary,
              trackHeight: 3,
            ),
            child: Slider(
              value: reading.fallLineHeadingDegrees,
              min: 0.0,
              max: 350.0,
              divisions: 35,
              onChanged: _controller.setFallLineHeading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceSelector(BuildContext context, dynamic reading) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Putt Distance',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                '${reading.puttDistanceFeet.toStringAsFixed(0)} Feet',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor: colorScheme.surfaceContainerHighest,
              thumbColor: colorScheme.primary,
              trackHeight: 3,
            ),
            child: Slider(
              value: reading.puttDistanceFeet,
              min: 4.0,
              max: 50.0,
              divisions: 46,
              onChanged: _controller.setPuttDistance,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [6.0, 10.0, 15.0, 25.0, 40.0].map((dist) {
              final isSelected = (reading.puttDistanceFeet - dist).abs() < 1.0;
              return InkWell(
                onTap: () => _controller.setPuttDistance(dist),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${dist.toInt()}ft',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
