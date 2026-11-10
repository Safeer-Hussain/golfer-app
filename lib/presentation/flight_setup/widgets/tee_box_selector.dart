import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/course_entity.dart';

class TeeBoxSelector extends StatelessWidget {
  final CourseEntity course;
  final String selectedTee;
  final ValueChanged<String> onTeeSelected;

  const TeeBoxSelector({
    super.key,
    required this.course,
    required this.selectedTee,
    required this.onTeeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final tees = [
      {
        'name': AppConstants.teeBlack,
        'yards': 7120,
        'slope': course.slope,
        'rating': course.rating,
      },
      {
        'name': AppConstants.teeBlue,
        'yards': 6680,
        'slope': 132,
        'rating': 72.0,
      },
      {
        'name': AppConstants.teeWhite,
        'yards': 6240,
        'slope': 125,
        'rating': 70.1,
      },
      {
        'name': AppConstants.teeRed,
        'yards': 5510,
        'slope': 118,
        'rating': 67.5,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tee Box & Course Handicap Calculation',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: tees.map((t) {
            final name = t['name'] as String;
            final isSelected = name == selectedTee;
            final shortName = name.split(' ').first;

            return Expanded(
              child: GestureDetector(
                onTap: () => onTeeSelected(name),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary.withValues(alpha: 0.15)
                        : colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                      width: isSelected ? 1.8 : 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        shortName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${t['yards']}y',
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'S:${t['slope']}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
