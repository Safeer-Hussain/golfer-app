import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HandicapAnalyticsTab extends StatelessWidget {
  const HandicapAnalyticsTab({super.key});

  Widget _buildKpiCard(BuildContext context, String label, String value, IconData icon, Color color) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatProgress(BuildContext context, String label, String pctStr, double value, Color color) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
              ),
              Text(
                pctStr,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value,
            backgroundColor: colorScheme.surfaceContainerHighest,
            color: color,
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // KPI Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.8,
            children: [
              _buildKpiCard(context, 'HANDICAP INDEX', '4.2', Icons.trending_down_rounded, colorScheme.primary),
              _buildKpiCard(context, 'SCORING AVERAGE', '72.5', Icons.bar_chart_rounded, colorScheme.secondary),
              _buildKpiCard(context, 'BEST ROUND (18)', '68 (-4)', Icons.emoji_events_outlined, colorScheme.secondary),
              _buildKpiCard(context, 'PUTTS PER ROUND', '29.2', Icons.sports_golf_rounded, colorScheme.primary),
            ],
          ),
          const SizedBox(height: 18),
          // Scoring & Handicap Progression Chart
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Scoring & Handicap Progression',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Row(
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text('Score', style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant)),
                        const SizedBox(width: 10),
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: colorScheme.secondary, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text('HCP Index', style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false, reservedSize: 0),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false, reservedSize: 0),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: 1,
                            getTitlesWidget: (val, meta) {
                              const labels = ['R1', 'R2', 'R3', 'R4', 'R5', 'R6', 'R7', 'R8'];
                              final i = val.toInt();
                              if (i >= 0 && i < labels.length) {
                                return Text(
                                  labels[i],
                                  style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (val, meta) {
                              return Text(
                                '${val.toInt()}',
                                style: TextStyle(fontSize: 9, color: colorScheme.onSurfaceVariant),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: 7,
                      minY: 65,
                      maxY: 80,
                      lineBarsData: [
                        // Scoring average curve
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 75),
                            FlSpot(1, 74),
                            FlSpot(2, 76),
                            FlSpot(3, 73),
                            FlSpot(4, 71),
                            FlSpot(5, 73),
                            FlSpot(6, 70),
                            FlSpot(7, 71),
                          ],
                          isCurved: true,
                          color: colorScheme.primary,
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: colorScheme.primary.withValues(alpha: 0.12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Performance Breakdown
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Round Performance Breakdown',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                _buildStatProgress(context, 'Fairways in Regulation (FIR)', '74%', 0.74, colorScheme.primary),
                _buildStatProgress(context, 'Greens in Regulation (GIR)', '68%', 0.68, colorScheme.primary),
                _buildStatProgress(context, 'Scrambling / Sand Saves', '58%', 0.58, colorScheme.secondary),
                _buildStatProgress(context, 'Par-3 Scoring Efficiency', '3.1 Avg', 0.82, colorScheme.secondary),
              ],
            ),
          ),
          const SizedBox(height: 70),
        ],
      ),
    );
  }
}
