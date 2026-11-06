import 'package:flutter/material.dart';

class CaddieShortcutChips extends StatelessWidget {
  final ValueChanged<String> onSelectPrompt;
  final bool isDisabled;

  const CaddieShortcutChips({
    super.key,
    required this.onSelectPrompt,
    this.isDisabled = false,
  });

  static const List<String> shortcuts = [
    'Recommend Club for Current Hole & Wind',
    'Analyze My Front-9 Putting & GIR Trends',
    'Suggest Safe Layup Strategy',
    'Fix My Driver Slice Tendency',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: shortcuts.map((prompt) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              avatar: Icon(Icons.bolt_rounded, size: 14, color: colorScheme.secondary),
              label: Text(
                prompt,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              backgroundColor: colorScheme.surfaceContainer,
              side: BorderSide(color: colorScheme.outlineVariant),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onPressed: isDisabled ? null : () => onSelectPrompt(prompt),
            ),
          );
        }).toList(),
      ),
    );
  }
}
