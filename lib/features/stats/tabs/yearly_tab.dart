import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:verso/features/stats/providers/stats_providers.dart';
import 'package:verso/features/stats/widgets/time_period_navigator.dart';

class YearlyTab extends ConsumerWidget {
  const YearlyTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offset = ref.watch(yearlyOffsetProvider);
    final asyncData = ref.watch(yearlyChartStatsProvider(offset));

    return asyncData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (chartData) {
        final scheme = Theme.of(context).colorScheme;
        final isLight = Theme.of(context).brightness == Brightness.light;
        final now = DateTime.now();

        // Current year: show up to current month. Past year: show all 12.
        final maxMonthToShow = offset == 0 ? now.month : 12;

        final maxMonthly = chartData.monthlyCounts.values.isEmpty
            ? 0
            : chartData.monthlyCounts.values.reduce(max);
        final maxY = maxMonthly > 50 ? maxMonthly.toDouble() + 20 : 60.0;

        var bestMonthLabel = '-';
        var bestMonthCount = 0;
        if (chartData.monthlyCounts.isNotEmpty) {
          final best = chartData.monthlyCounts.entries.reduce(
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
              // Period navigator
              TimePeriodNavigator(
                label: '${chartData.year}',
                onPrevious: () =>
                    ref.read(yearlyOffsetProvider.notifier).goBack(),
                onNext: offset > 0
                    ? () => ref.read(yearlyOffsetProvider.notifier).goForward()
                    : null,
                onReset: offset > 0
                    ? () => ref.read(yearlyOffsetProvider.notifier).reset()
                    : null,
              ),
              const Gap(16),

              // Summary
              RichText(
                text: TextSpan(
                  style:
                      TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
                  children: [
                    TextSpan(
                      text: '${chartData.totalRead} chapters ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: chartData.totalRead > 0
                          ? (offset == 0
                              ? 'read this year'
                              : 'read in ${chartData.year}')
                          : 'no reading recorded',
                    ),
                  ],
                ),
              ),
              const Gap(24),

              // Area Chart
              SizedBox(
                height: 260,
                child: _AnimatedChartWrapper(
                  key: ValueKey('yearly_chart_$offset'),
                  builder: (isAnimated) {
                    return LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: maxY,
                        minX: 1,
                        maxX: 12,
                        gridData: FlGridData(
                          drawVerticalLine: false,
                          horizontalInterval: (maxY / 4)
                              .ceilToDouble()
                              .clamp(1, double.infinity),
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: scheme.outline.withValues(alpha: 0.08),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(),
                          rightTitles: const AxisTitles(),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                final m = value.toInt();
                                if (m < 1 || m > 12) return const SizedBox();
                                final isCurrentMonth =
                                    offset == 0 && m == now.month;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _monthNameShort(m),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isCurrentMonth
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isCurrentMonth
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
                              interval: (maxY / 4)
                                  .ceilToDouble()
                                  .clamp(1, double.infinity),
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
                            spots: _generateSpots(
                              isAnimated,
                              maxMonthToShow,
                              chartData,
                            ),
                            isCurved: true,
                            curveSmoothness: 0.3,
                            color: scheme.primary,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
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
                                  scheme.primary
                                      .withValues(alpha: isLight ? 0.3 : 0.25),
                                  scheme.primary.withValues(alpha: 0.02),
                                ],
                              ),
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (_) => scheme.primaryContainer,
                            getTooltipItems: (spots) => spots.map((spot) {
                              return LineTooltipItem(
                                '${_monthNameShort(spot.x.toInt())}: ${spot.y.toInt()} chapters',
                                TextStyle(
                                  color: scheme.onPrimaryContainer,
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
              if (chartData.totalRead > 0) ...[
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
                        value: maxMonthToShow > 0
                            ? (chartData.totalRead / maxMonthToShow)
                                .toStringAsFixed(1)
                            : '0',
                        subtitle: 'chapters / month',
                        icon: Icons.show_chart_rounded,
                        iconColor: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Empty state
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.insert_chart_outlined,
                          size: 40,
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                        ),
                        const Gap(12),
                        Text(
                          'No reading activity in ${chartData.year}',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  List<FlSpot> _generateSpots(
    bool animate,
    int maxMonthToShow,
    YearlyChartData data,
  ) {
    final spots = <FlSpot>[];
    for (var m = 1; m <= maxMonthToShow; m++) {
      final value = animate ? (data.monthlyCounts[m] ?? 0).toDouble() : 0.0;
      spots.add(FlSpot(m.toDouble(), value));
    }
    return spots;
  }

  String _monthNameShort(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (m < 1 || m > 12) return '';
    return months[m - 1];
  }
}

class _YearCard extends StatelessWidget {
  const _YearCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const Gap(10),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _AnimatedChartWrapper extends StatefulWidget {
  const _AnimatedChartWrapper({required this.builder, super.key});
  final Widget Function(bool isAnimated) builder;

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
