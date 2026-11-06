import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/entities/nassau_match_entity.dart';
import '../../../domain/usecases/nassau_calculator_usecase.dart';
import '../scorecard_controller.dart';

class NassauPressModal extends StatefulWidget {
  final ScorecardController controller;

  const NassauPressModal({
    super.key,
    required this.controller,
  });

  @override
  State<NassauPressModal> createState() => _NassauPressModalState();
}

class _NassauPressModalState extends State<NassauPressModal> {
  double _baseStake = 10.0;
  bool _autoPress = true;
  bool _useNetScore = true;
  int _selectedPairingIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    final nassauUseCase = sl<NassauCalculatorUseCase>();
    final players = widget.controller.players;
    final playerScores = widget.controller.activeScorecard.playerScores;
    final course = widget.controller.course;

    final ledgerData = nassauUseCase.computeFlightNassauLedger(
      players: players,
      playerScores: playerScores,
      course: course,
      baseStake: _baseStake,
      autoPress: _autoPress,
      pressStake: _baseStake,
      useNetScore: _useNetScore,
    );

    final matchResults = ledgerData['matchResults'] as List<NassauMatchResult>;
    final netBalances = ledgerData['netBalances'] as Map<String, double>;
    final settlements = ledgerData['settlementPayments'] as List<NassauLedgerPayment>;

    Widget buildConfigCard() {
      return Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Base Stake per Bet',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Wrap(
                  spacing: 4,
                  children: [5.0, 10.0, 20.0, 50.0].map((stake) {
                    final isSel = _baseStake == stake;
                    return ChoiceChip(
                      label: Text(
                        '\$${stake.toInt()}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          color: isSel ? colorScheme.onPrimary : colorScheme.onSurface,
                        ),
                      ),
                      selected: isSel,
                      selectedColor: colorScheme.primary,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      visualDensity: VisualDensity.compact,
                      onSelected: (_) => setState(() => _baseStake = stake),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto 2-Down Press',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Automatically spawns a sub-match bet when any player falls 2 holes behind.',
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _autoPress,
                  activeTrackColor: colorScheme.primary,
                  onChanged: (val) => setState(() => _autoPress = val),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Scoring Mode: ${_useNetScore ? "Net (Handicap Adjusted)" : "Gross (Scratch)"}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.secondary,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _useNetScore = !_useNetScore),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: colorScheme.primary,
                  ),
                  child: Text(
                    _useNetScore ? 'Switch to Gross' : 'Switch to Net',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget buildSubMatchRow(NassauSubMatch sub, String p1Name, String p2Name) {
      final status = sub.getStatusDisplay(p1Name, p2Name);
      final isPress = sub.segment == NassauSegment.press;

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isPress
              ? colorScheme.secondary.withValues(alpha: 0.1)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPress ? colorScheme.secondary.withValues(alpha: 0.4) : colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isPress) ...[
                        Icon(Icons.bolt_rounded, size: 14, color: colorScheme.secondary),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        sub.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isPress ? colorScheme.secondary : colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Stake: \$${sub.stake.toInt()} • Holes ${sub.startHole}-${sub.endHole}',
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: sub.margin != 0 ? colorScheme.primary : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget buildPairingDetails() {
      if (matchResults.isEmpty) {
        return Center(
          child: Text(
            'Add at least 2 players in flight to run Nassau match bets.',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        );
      }

      final activeIndex = _selectedPairingIndex.clamp(0, matchResults.length - 1);
      final res = matchResults[activeIndex];
      final p1 = players.firstWhere((p) => p.id == res.player1Id);
      final p2 = players.firstWhere((p) => p.id == res.player2Id);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pairing selector chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: matchResults.asMap().entries.map((entry) {
                final idx = entry.key;
                final m = entry.value;
                final name1 = players.firstWhere((p) => p.id == m.player1Id).name.split(' ').first;
                final name2 = players.firstWhere((p) => p.id == m.player2Id).name.split(' ').first;
                final isSel = idx == activeIndex;

                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(
                      '$name1 vs $name2',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        color: isSel ? colorScheme.onPrimary : colorScheme.onSurface,
                      ),
                    ),
                    selected: isSel,
                    selectedColor: colorScheme.primary,
                    backgroundColor: colorScheme.surfaceContainer,
                    onSelected: (_) => setState(() => _selectedPairingIndex = idx),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          // Sub-matches: Front 9, Back 9, Overall, and Presses
          buildSubMatchRow(res.front9, p1.name, p2.name),
          buildSubMatchRow(res.back9, p1.name, p2.name),
          buildSubMatchRow(res.overall, p1.name, p2.name),
          if (res.presses.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...res.presses.map((p) => buildSubMatchRow(p, p1.name, p2.name)),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'No 2-down presses triggered yet in this pairing.',
                style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ],
      );
    }

    Widget buildLedgerSummary() {
      return Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Flight Net Balances',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Balanced Sum: \$0.00',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...players.map((p) {
              final bal = netBalances[p.id] ?? 0.0;
              final isPositive = bal > 0.01;
              final isNegative = bal < -0.01;
              final color = isPositive
                  ? colorScheme.primary
                  : (isNegative ? colorScheme.error : colorScheme.onSurfaceVariant);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      p.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: p.isCurrentDeviceUser ? FontWeight.bold : FontWeight.normal,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      isPositive
                          ? '+\$${bal.toStringAsFixed(2)}'
                          : (isNegative ? '-\$${bal.abs().toStringAsFixed(2)}' : '\$0.00'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (settlements.isNotEmpty) ...[
              const Divider(height: 14),
              Text(
                'Settlement Payments:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 4),
              ...settlements.map((s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.description,
                          style: TextStyle(fontSize: 11, color: colorScheme.onSurface),
                        ),
                        Text(
                          '\$${s.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SizedBox(
          height: isLandscape ? 320 : 560,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.handshake_outlined, color: colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Nassau Press Side-Bet Calculator',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant),
                      onPressed: () => Navigator.of(context).pop(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: isLandscape
                    ? Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  buildConfigCard(),
                                  const SizedBox(height: 10),
                                  buildLedgerSummary(),
                                ],
                              ),
                            ),
                          ),
                          VerticalDivider(width: 1, color: colorScheme.outlineVariant),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              padding: const EdgeInsets.all(12),
                              child: buildPairingDetails(),
                            ),
                          ),
                        ],
                      )
                    : SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            buildConfigCard(),
                            const SizedBox(height: 12),
                            Text(
                              'Match Play Board & Active Presses',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            buildPairingDetails(),
                            const SizedBox(height: 14),
                            buildLedgerSummary(),
                            const SizedBox(height: 20),
                          ],
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
