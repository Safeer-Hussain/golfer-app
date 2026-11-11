import 'package:flutter/material.dart';

class SkinsRulesModal extends StatelessWidget {
  const SkinsRulesModal({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tournament Skins Rules & Regulations',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(height: 16),
          _buildRuleSection(
            context,
            title: '1. Outright Hole Winner',
            body: 'A skin is awarded on a hole if and only if one player posts a score strictly lower than all other flight competitors. In Gross mode, raw strokes are compared; in Net mode, strokes received are deducted based on hole stroke index.',
          ),
          const SizedBox(height: 10),
          _buildRuleSection(
            context,
            title: '2. Multi-Hole Carryovers',
            body: 'When two or more players tie for the lowest score on a hole, the hole is halved, no skin is awarded, and the monetary value carries over to the subsequent hole, creating cumulative jackpot pots.',
          ),
          const SizedBox(height: 10),
          _buildRuleSection(
            context,
            title: '3. 18th Hole Push Resolution',
            body: 'If the 18th hole ties with accumulated carryover skins, the leftover pot can be pushed equally among all players, split between tied players, or declared dead with zero payout.',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'GOT IT',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildRuleSection(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          body,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
