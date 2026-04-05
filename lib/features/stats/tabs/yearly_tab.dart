import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gap/gap.dart';
import '../providers/stats_providers.dart';

class YearlyTab extends StatelessWidget {
  final DetailedStats stats;

  const YearlyTab({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final now = DateTime.now();

    final totalThisYear = stats.currentYearMonthlyCounts.values.fold(0, (a, b) => a + b);
    final maxMonthly = stats.currentYearMonthlyCounts.values.isEmpty
        ? 0
        : stats.currentYearMonthlyCounts.values.reduce(max);
    final maxY = maxMonthly > 50 ? maxMonthly.toDouble() + 20 : 60.0;

    // Find best month
    String bestMonthLabel = '—';
    int bestMonthCount = 0;
    if (stats.currentYearMonthlyCounts.isNotEmpty) {
      final best = stats.currentYearMonthlyCounts.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      bestMonthLabel = _monthNameShort(best.key);
      bestMonthCount = best.value;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            '${now.year} Progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Gap(4),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
              children: [
                TextSpan(
                  text: '$totalThisYear chapters ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                    fontSize: 16,
                  ),
                ),
                const TextSpan(text: 'read this year'),
              ],
            ),
          ),
          const Gap(24),

          // Area Chart
          SizedBox(
            height: 280,
            child: _AnimatedChartWrapper(
              builder: (isAnimated) {
                return LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: maxY,
                    minX: 1,
                    maxX: 12,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: (maxY / 4).ceilToDouble().clamp(1, double.infinity),
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: scheme.outline.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final m = value.toInt();
                            if (m < 1 || m > 12) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _monthNameShort(m),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: m == now.month
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: m == now.month
                                      ? scheme.primary
                                      : scheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 35,
                          interval: (maxY / 4).ceilToDouble().clamp(1, double.infinity),
                          getTitlesWidget: (value, meta) => Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _generateSpots(isAnimated, now.month),
                        isCurved: true,
                        curveSmoothness: 0.3,
                        color: scheme.primary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: scheme.primary,
                              strokeWidth: 2,
                              strokeColor: scheme.surface,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              scheme.primary.withValues(alpha: isLight ? 0.3 : 0.25),
                              scheme.primary.withValues(alpha: 0.02),
                            ],
                          ),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (spots) => spots.map((spot) {
                          return LineTooltipItem(
                            '${_monthNameShort(spot.x.toInt())}: ${spot.y.toInt()} chapters',
                            TextStyle(
                              color: scheme.onPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                );
              },
            ),
          ),
          const Gap(32),

          // Summary cards
          Row(
            children: [
              Expanded(
                child: _YearCard(
                  label: 'Best Month',
                  value: bestMonthLabel,
                  subtitle: '$bestMonthCount chapters',
                  icon: Icons.star_rounded,
                  iconColor: Colors.amber.shade700,
                ),
              ),
              const Gap(12),
              Expanded(
                child: _YearCard(
                  label: 'Monthly Avg',
                  value: now.month > 0
                      ? (totalThisYear / now.month).toStringAsFixed(1)
                      : '0',
                  subtitle: 'chapters / month',
                  icon: Icons.show_chart_rounded,
                  iconColor: scheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateSpots(bool animate, int currentMonth) {
    final spots = <FlSpot>[];
    for (int m = 1; m <= currentMonth; m++) {
      final value = animate
          ? (stats.currentYearMonthlyCounts[m] ?? 0).toDouble()
          : 0.0;
      spots.add(FlSpot(m.toDouble(), value));
    }
    return spots;
  }

  String _monthNameShort(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (m < 1 || m > 12) return '';
    return months[m - 1];
  }
}

class _YearCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const _YearCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: iconColor),
          const Gap(8),
          Text(label,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          Text(value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(subtitle,
              style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _AnimatedChartWrapper extends StatefulWidget {
  final Widget Function(bool isAnimated) builder;
  const _AnimatedChartWrapper({required this.builder});

  @override
  State<_AnimatedChartWrapper> createState() => _AnimatedChartWrapperState();
}

class _AnimatedChartWrapperState extends State<_AnimatedChartWrapper> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) => widget.builder(_visible);
}
