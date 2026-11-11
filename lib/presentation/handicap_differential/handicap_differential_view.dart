import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../core/utils/app_feedback.dart';
import 'handicap_differential_controller.dart';
import 'widgets/differential_cockpit_card.dart';
import 'widgets/net_double_bogey_table.dart';
import 'widgets/whs_history_card.dart';

class HandicapDifferentialView extends StatefulWidget {
  const HandicapDifferentialView({super.key});

  @override
  State<HandicapDifferentialView> createState() =>
      _HandicapDifferentialViewState();
}

class _HandicapDifferentialViewState extends State<HandicapDifferentialView> {
  late final HandicapDifferentialController _controller;
  final ScrollController _portraitScrollController = ScrollController();
  final ScrollController _landscapeLeftController = ScrollController();
  final ScrollController _landscapeRightController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = GetIt.I<HandicapDifferentialController>();
  }

  @override
  void dispose() {
    _portraitScrollController.dispose();
    _landscapeLeftController.dispose();
    _landscapeRightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('USGA Handicap Differential'),
        toolbarHeight: isLandscape ? 40 : kToolbarHeight,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset PCC',
            onPressed: () => _controller.setPcc(0.0),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final result = _controller.differentialResult;
          final calculation = _controller.whsCalculation;

          if (isLandscape) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Pane: Course Details & Differential Cockpit
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    controller: _landscapeLeftController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildCourseHeader(context),
                        const SizedBox(height: 12),
                        DifferentialCockpitCard(
                          result: result,
                          pcc: _controller.pcc,
                          onPccChanged: _controller.setPcc,
                        ),
                        const SizedBox(height: 12),
                        _buildSubmitButton(context, result),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(width: 1, color: colorScheme.outlineVariant),
                // Right Pane: Net Double Bogey Table & 20-Round History
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    controller: _landscapeRightController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        NetDoubleBogeyTable(
                          adjustments: result.holeAdjustments,
                          onStrokeChanged: _controller.updateHoleStroke,
                        ),
                        const SizedBox(height: 12),
                        WhsHistoryCard(calculation: calculation),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          // Portrait View
          return SingleChildScrollView(
            controller: _portraitScrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCourseHeader(context),
                const SizedBox(height: 14),
                DifferentialCockpitCard(
                  result: result,
                  pcc: _controller.pcc,
                  onPccChanged: _controller.setPcc,
                ),
                const SizedBox(height: 14),
                _buildSubmitButton(context, result),
                const SizedBox(height: 14),
                NetDoubleBogeyTable(
                  adjustments: result.holeAdjustments,
                  onStrokeChanged: _controller.updateHoleStroke,
                ),
                const SizedBox(height: 14),
                WhsHistoryCard(calculation: calculation),
                const SizedBox(height: 28),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourseHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                _controller.course.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_controller.teeBox} Tees',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Course Rating: ${_controller.course.ratingForTee(_controller.teeBox).toStringAsFixed(1)} • Slope: ${_controller.course.slopeForTee(_controller.teeBox)} • Course Handicap: ${_controller.courseHandicap}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, dynamic result) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton.icon(
        onPressed: () {
          AppFeedback.showSuccess(
            context,
            'Submitted Differential of ${result.scoreDifferential >= 0 ? '+' : ''}${result.scoreDifferential.toStringAsFixed(1)} to WHS Record',
          );
        },
        icon: const Icon(Icons.send_rounded, size: 18),
        label: const Text(
          'SUBMIT OFFICIAL WHS SCORE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
