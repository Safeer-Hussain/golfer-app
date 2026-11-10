import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../core/di/service_locator.dart';
import '../../core/utils/app_feedback.dart';
import '../scorecard/scorecard_controller.dart';
import 'rangefinder_controller.dart';
import 'widgets/gps_crosshair_card.dart';
import 'widgets/shot_tracker_modal.dart';
import 'widgets/wind_elevation_badge.dart';

class RangefinderView extends StatefulWidget {
  const RangefinderView({super.key});

  @override
  State<RangefinderView> createState() => _RangefinderViewState();
}

class _RangefinderViewState extends State<RangefinderView> {
  final MapController _mapController = MapController();

  void _openShotTrackerModal(
    BuildContext context,
    RangefinderController controller,
    int distance,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      builder: (ctx) =>
          ShotTrackerModal(measuredDistance: distance, controller: controller),
    );
  }

  Widget _buildMap(BuildContext context, RangefinderController controller) {
    final colorScheme = Theme.of(context).colorScheme;
    final hole = controller.currentHole;

    final markers = <Marker>[
      // Tee Box Marker
      Marker(
        point: hole.teeLocation,
        width: 36,
        height: 36,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.onSurface, width: 2),
            boxShadow: [
              BoxShadow(
                color: colorScheme.surface.withValues(alpha: 0.5),
                blurRadius: 6,
              ),
            ],
          ),
          child: Icon(
            Icons.golf_course_rounded,
            color: colorScheme.onSurface,
            size: 20,
          ),
        ),
      ),
      // Target Crosshair Marker
      Marker(
        point: controller.targetLocation,
        width: 44,
        height: 44,
        child: GestureDetector(
          onPanUpdate: (details) {
            // Drag target
          },
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.primary, width: 2.5),
            ),
            child: Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
      // Center Pin Marker
      Marker(
        point: hole.greenLocation,
        width: 36,
        height: 36,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.onSecondary, width: 2),
            boxShadow: [
              BoxShadow(
                color: colorScheme.secondary.withValues(alpha: 0.4),
                blurRadius: 6,
              ),
            ],
          ),
          child: Icon(
            Icons.flag_rounded,
            color: colorScheme.onSecondary,
            size: 20,
          ),
        ),
      ),
    ];

    final polylines = <Polyline>[
      // Tee to Target line
      Polyline(
        points: [hole.teeLocation, controller.targetLocation],
        strokeWidth: 3.0,
        color: colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      // Target to Pin line
      Polyline(
        points: [controller.targetLocation, hole.greenLocation],
        strokeWidth: 3.5,
        color: colorScheme.primary,
      ),
    ];

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: hole.targetLocation,
            initialZoom: 16.2,
            onTap: (tapPosition, point) {
              controller.updateTargetLocation(point);
              if (controller.isTrackingShot) {
                final dist = controller.markShotEndAndCalculate(point);
                _openShotTrackerModal(context, controller, dist);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.golfer_app',
            ),
            PolylineLayer(polylines: polylines),
            MarkerLayer(markers: markers),
          ],
        ),
        // Top Badges
        Positioned(
          top: 10,
          left: 12,
          right: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Text(
                  'Hole ${hole.holeNumber} • Par ${hole.par}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              WindElevationBadge(
                windDirection: hole.windDirection,
                windSpeedMph: hole.windSpeedMph,
                elevationFeet: hole.elevationChangeFeet,
              ),
            ],
          ),
        ),
        // If tracking shot banner
        if (controller.isTrackingShot)
          Positioned(
            top: 56,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.gps_fixed_rounded,
                    color: colorScheme.onSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tap anywhere on the course to mark shot landing point.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: colorScheme.onSecondary,
                      size: 18,
                    ),
                    onPressed: () => controller.cancelShotTracking(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        // Bottom Telemetry HUD
        Positioned(
          bottom: 12,
          left: 12,
          right: 12,
          child: GpsCrosshairCard(
            teeToTargetYards: controller.getDistanceTeeToTargetYards(),
            targetToPinYards: controller.getDistanceTargetToPinYards(),
            frontPinYards: controller.getDistanceToFrontPinYards(),
            backPinYards: controller.getDistanceToBackPinYards(),
            playsLikeYards: controller.getPlaysLikeDistanceYards(),
            unitSystem: controller.unitSystem,
            onResetTarget: controller.resetTargetToCenter,
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeSideDetail(
    BuildContext context,
    RangefinderController controller,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final hole = controller.currentHole;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hole ${hole.holeNumber} GPS Telemetry',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${controller.course.name} • Par ${hole.par} • SI ${hole.strokeIndex}',
            style: TextStyle(fontSize: 11, color: colorScheme.secondary),
          ),
          const Divider(height: 16),
          GpsCrosshairCard(
            teeToTargetYards: controller.getDistanceTeeToTargetYards(),
            targetToPinYards: controller.getDistanceTargetToPinYards(),
            frontPinYards: controller.getDistanceToFrontPinYards(),
            backPinYards: controller.getDistanceToBackPinYards(),
            playsLikeYards: controller.getPlaysLikeDistanceYards(),
            unitSystem: controller.unitSystem,
            onResetTarget: controller.resetTargetToCenter,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Hazard & Course Vectors',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  hole.hazardsDescription,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () {
              controller.startShotTracking(null);
              AppFeedback.showInfo(
                context,
                'Shot tracking started from tee box. Tap map landing spot.',
              );
            },
            icon: const Icon(Icons.gps_fixed_rounded, size: 18),
            label: const Text('Track Live Shot'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              minimumSize: const Size.fromHeight(42),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = sl<RangefinderController>();
    final scorecardController = sl<ScorecardController>();
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Sync hole with scorecard
    controller.syncWithHole(
      scorecardController.course,
      scorecardController.currentHoleIndex,
      scorecardController.activeScorecard.teeBox,
    );

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Scaffold(
          body: isLandscape
              ? Row(
                  children: [
                    Expanded(flex: 3, child: _buildMap(context, controller)),
                    VerticalDivider(
                      width: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    Expanded(
                      flex: 2,
                      child: _buildLandscapeSideDetail(context, controller),
                    ),
                  ],
                )
              : _buildMap(context, controller),
          floatingActionButton: isLandscape
              ? null
              : FloatingActionButton.extended(
                  heroTag: 'fab_gps_shot_track',
                  onPressed: () {
                    controller.startShotTracking(null);
                    AppFeedback.showInfo(
                      context,
                      'Shot tracking started from tee box. Tap map landing spot.',
                    );
                  },
                  icon: const Icon(Icons.gps_fixed_rounded),
                  label: const Text('Track Shot'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
        );
      },
    );
  }
}
