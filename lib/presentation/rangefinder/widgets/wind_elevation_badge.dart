import 'package:flutter/material.dart';

class WindElevationBadge extends StatelessWidget {
  final String windDirection;
  final double windSpeedMph;
  final int elevationFeet;

  const WindElevationBadge({
    super.key,
    required this.windDirection,
    required this.windSpeedMph,
    required this.elevationFeet,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.surface.withValues(alpha: 0.4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.air_rounded, size: 16, color: colorScheme.secondary),
          const SizedBox(width: 6),
          Text(
            windDirection,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 10),
          Icon(Icons.height_rounded, size: 16, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            '${elevationFeet >= 0 ? "+$elevationFeet" : elevationFeet} ft',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
