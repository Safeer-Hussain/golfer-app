import 'package:flutter/material.dart';

import '../../../data/models/club_model.dart';
import '../clubhouse_controller.dart';

class ClubBagCalibratorTab extends StatelessWidget {
  final ClubhouseController controller;

  const ClubBagCalibratorTab({super.key, required this.controller});

  void _showCalibrationDialog(BuildContext context, ClubModel club) {
    final colorScheme = Theme.of(context).colorScheme;
    double carry = club.carryYards.toDouble();
    double total = club.totalYards.toDouble();

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: colorScheme.surfaceContainer,
            title: Row(
              children: [
                Image.asset(club.imageAsset, width: 26, height: 26),
                const SizedBox(width: 10),
                Text(
                  'Calibrate ${club.name}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loft: ${club.loft} • Recorded GPS Shots: ${club.recordedShotsCount}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Carry Distance',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${carry.round()} Yds',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: carry,
                  min: 30,
                  max: 330,
                  divisions: 300,
                  activeColor: colorScheme.primary,
                  onChanged: (val) {
                    setState(() {
                      carry = val;
                      if (total < carry) total = carry + 10;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Distance',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${total.round()} Yds',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: total,
                  min: 30,
                  max: 350,
                  divisions: 320,
                  activeColor: colorScheme.secondary,
                  onChanged: (val) {
                    setState(() {
                      total = val;
                      if (carry > total) carry = total;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  controller.updateClubCalibration(
                    club,
                    carry.round(),
                    total.round(),
                  );
                  Navigator.of(ctx).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: const Text('Save Calibration'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      itemCount: controller.clubs.length + 1,
      itemBuilder: (context, index) {
        if (index == controller.clubs.length) {
          return const SizedBox(height: 76);
        }

        final club = controller.clubs[index];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Image.asset(club.imageAsset, width: 34, height: 34),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          club.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            club.loft,
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Carry: ${club.carryYards}y  •  Total: ${club.totalYards}y  •  ${club.recordedShotsCount} shots tracked',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
                tooltip: 'Calibrate Club',
                onPressed: () => _showCalibrationDialog(context, club),
              ),
            ],
          ),
        );
      },
    );
  }
}
