import 'package:flutter/material.dart';

import '../../../domain/entities/swing_tempo_entity.dart';
import '../../../domain/usecases/swing_tempo_usecase.dart';

class TempoPresetSelector extends StatelessWidget {
  final SwingType swingType;
  final TempoPreset currentPreset;
  final ValueChanged<SwingType> onSwingTypeChanged;
  final ValueChanged<TempoPreset> onPresetChanged;
  final SwingTempoUseCase useCase;

  const TempoPresetSelector({
    super.key,
    required this.swingType,
    required this.currentPreset,
    required this.onSwingTypeChanged,
    required this.onPresetChanged,
    required this.useCase,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final presets = useCase.getPresets(swingType);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented Switch: Full Swing (3:1) vs Putting (2:1)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Tempo Cadence',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              SegmentedButton<SwingType>(
                segments: const [
                  ButtonSegment(
                    value: SwingType.fullSwing,
                    label: Text(
                      'Full Swing (3:1)',
                      style: TextStyle(fontSize: 11),
                    ),
                    icon: Icon(Icons.sports_golf_rounded, size: 14),
                  ),
                  ButtonSegment(
                    value: SwingType.putting,
                    label: Text(
                      'Putting (2:1)',
                      style: TextStyle(fontSize: 11),
                    ),
                    icon: Icon(Icons.flag_outlined, size: 14),
                  ),
                ],
                selected: {swingType},
                onSelectionChanged: (selected) {
                  onSwingTypeChanged(selected.first);
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Preset Selection Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: presets.map((preset) {
                final isSelected = preset.id == currentPreset.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      '${preset.backswingFrames}/${preset.downswingFrames} (${preset.totalMs}ms)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) onPresetChanged(preset);
                    },
                    selectedColor: colorScheme.primary,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Detailed Preset Info Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
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
                      currentPreset.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${currentPreset.bpm.toStringAsFixed(0)} BPM',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Pro Reference: ${currentPreset.proExample}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentPreset.description,
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
    );
  }
}
