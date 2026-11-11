import 'package:flutter/material.dart';

import '../../../domain/entities/skins_pot_entity.dart';

class SkinsPayoutLedgerCard extends StatelessWidget {
  final SkinsGameResult result;
  final ValueChanged<Hole18CarryoverRule> onRuleChanged;

  const SkinsPayoutLedgerCard({
    super.key,
    required this.result,
    required this.onRuleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
          // Header Row
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Financial Payout Ledger',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Zero-Sum Balanced',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Player Rows
          ...result.playerPayouts.map((payout) {
            final isPositive = payout.netBalance > 0;
            final isNegative = payout.netBalance < 0;

            final netColor = isPositive
                ? colorScheme.primary
                : (isNegative
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant);

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isPositive
                      ? colorScheme.primary.withValues(alpha: 0.3)
                      : colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payout.playerName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          payout.holesWon.isNotEmpty
                              ? '${payout.skinsWonCount} skins (Holes ${payout.holesWon.join(', ')})'
                              : '0 skins won',
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Buy: \$${payout.totalBuyIn.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          'Won: \$${payout.totalPayout.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 68,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: netColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: netColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      isPositive
                          ? '+\$${payout.netBalance.toStringAsFixed(0)}'
                          : '\$${payout.netBalance.toStringAsFixed(0)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: netColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),

          // Hole 18 Carryover Resolution Option
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.settings_suggest_rounded,
                  size: 16,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '18th Hole Carryover Resolution',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                DropdownButton<Hole18CarryoverRule>(
                  value: result.hole18Rule,
                  underline: const SizedBox.shrink(),
                  isDense: true,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: Hole18CarryoverRule.carryoverPush,
                      child: Text('Equal Push'),
                    ),
                    DropdownMenuItem(
                      value: Hole18CarryoverRule.splitTiedPlayers,
                      child: Text('Split Tied'),
                    ),
                    DropdownMenuItem(
                      value: Hole18CarryoverRule.noPayout,
                      child: Text('No Payout'),
                    ),
                  ],
                  onChanged: (rule) {
                    if (rule != null) onRuleChanged(rule);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
