import 'package:flutter/material.dart';

import '../../../core/utils/app_feedback.dart';
import '../rangefinder_controller.dart';

class ShotTrackerModal extends StatefulWidget {
  final int measuredDistance;
  final RangefinderController controller;

  const ShotTrackerModal({
    super.key,
    required this.measuredDistance,
    required this.controller,
  });

  @override
  State<ShotTrackerModal> createState() => _ShotTrackerModalState();
}

class _ShotTrackerModalState extends State<ShotTrackerModal> {
  String? _selectedClubId;
  late int _finalDistance;

  @override
  void initState() {
    super.initState();
    _finalDistance = widget.measuredDistance > 0
        ? widget.measuredDistance
        : 255;
    if (widget.controller.availableClubs.isNotEmpty) {
      _selectedClubId = widget.controller.availableClubs.first.id;
    }
  }

  void _saveShot() async {
    if (_selectedClubId == null) return;
    await widget.controller.saveRecordedShot(_selectedClubId!, _finalDistance);

    if (!mounted) return;
    final club = widget.controller.availableClubs.firstWhere(
      (c) => c.id == _selectedClubId,
    );
    Navigator.of(context).pop();
    AppFeedback.showSuccess(
      context,
      'Logged ${_finalDistance}y shot for ${club.name} into Bag Calibrator.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Log Live Shot Telemetry',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      'MEASURED SHOT CARRY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_finalDistance YDS',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Club Used',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedClubId,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.sports_golf_rounded),
                ),
                items: widget.controller.availableClubs.map((club) {
                  return DropdownMenuItem(
                    value: club.id,
                    child: Text(
                      '${club.name} (${club.loft}) - Avg: ${club.carryYards}y',
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedClubId = val);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveShot,
                icon: const Icon(Icons.save_rounded, size: 18),
                label: const Text('Save to 14-Club Calibration Database'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
