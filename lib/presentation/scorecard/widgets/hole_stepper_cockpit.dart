import 'package:flutter/material.dart';

import '../../../domain/entities/hole_entity.dart';

class HoleStepperCockpit extends StatelessWidget {
  final HoleEntity hole;
  final int currentHoleIndex;
  final String teeBox;
  final ValueChanged<int> onSelectHole;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const HoleStepperCockpit({
    super.key,
    required this.hole,
    required this.currentHoleIndex,
    required this.teeBox,
    required this.onSelectHole,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Column(
        children: [
          // 1-18 Horizontal Scroller
          SizedBox(
            height: 34,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 18,
              itemBuilder: (context, index) {
                final isSelected = index == currentHoleIndex;
                return GestureDetector(
                  onTap: () => onSelectHole(index),
                  child: Container(
                    width: 34,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Hole Details Banner
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                onPressed: currentHoleIndex > 0 ? onPrev : null,
                color: colorScheme.onSurface,
              ),
              Column(
                children: [
                  Text(
                    'HOLE ${hole.holeNumber}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'PAR ${hole.par}  •  ${hole.yardageForTee(teeBox)} YDS  •  STROKE INDEX ${hole.strokeIndex}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onPressed: currentHoleIndex < 17 ? onNext : null,
                color: colorScheme.onSurface,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
