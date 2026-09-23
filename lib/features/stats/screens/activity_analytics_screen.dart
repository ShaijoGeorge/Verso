import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:verso/core/design/extensions.dart';
import 'package:verso/core/widgets/error_state_widget.dart';
import 'package:verso/features/stats/providers/stats_providers.dart';

class ActivityAnalyticsScreen extends ConsumerWidget {
  const ActivityAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(detailedStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detailed Activity')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorStateWidget(
          error: err,
          onRetry: () => ref.invalidate(detailedStatsProvider),
        ),
        data: (stats) {
          final cs = Theme.of(context).colorScheme;

          // Calculate Dynamic Y-Axis Max
          final maxMonthly = stats.currentMonthDailyCounts.values.isEmpty
              ? 0
              : stats.currentMonthDailyCounts.values.reduce(max);
          final maxYMonth = maxMonthly > 50 ? maxMonthly.toDouble() + 5 : 50.0;

          final maxYearly = stats.currentYearMonthlyCounts.values.isEmpty
              ? 0
              : stats.currentYearMonthlyCounts.values.reduce(max);
          final maxYYEAR = maxYearly > 500 ? maxYearly.toDouble() + 50 : 500.0;

          final today = DateTime.now();
          final daysInMonth = DateUtils.getDaysInMonth(today.year, today.month);

          final axisLabelStyle = TextStyle(
            fontSize: 10,
            color: cs.onSurfaceVariant,
          );
          final axisTitleStyle = TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: cs.onSurfaceVariant,
          );
          final chartBorder = Border(
            bottom: BorderSide(color: cs.outline.withValues(alpha: 0.4)),
            left: BorderSide(color: cs.outline.withValues(alpha: 0.4)),
          );

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            children: [
              // ---  MONTHLY CHART ---
              _buildSectionTitle(
                'This Month Progress (${_monthName(today.month)} ${today.year})',
                cs,
              ),
              const Gap(24),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SizedBox(
                    height: 250,
                    child: _AnimatedChartWrapper(
                      builder: (isAnimated) {
                        return LineChart(
                          LineChartData(
                            minY: 0,
                            maxY: maxYMonth,
                            minX: 1,
                            maxX: daysInMonth.toDouble(),
                            gridData: const FlGridData(
                              horizontalInterval: 10,
                              drawVerticalLine: false,
                            ),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(),
                              rightTitles: const AxisTitles(),
                              bottomTitles: AxisTitles(
                                axisNameWidget: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Day of Month',
                                    style: axisTitleStyle,
                                  ),
                                ),
                                axisNameSize: 20,
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 5,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    final day = value.toInt();
                                    if (day > daysInMonth) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        day.toString(),
                                        style: axisLabelStyle,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                axisNameWidget:
                                    Text('Chapters', style: axisTitleStyle),
                                axisNameSize: 20,
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 10,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) => Text(
                                    value.toInt().toString(),
                                    style: axisLabelStyle,
                                  ),
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: chartBorder,
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _generateDailySpots(
                                  stats.currentMonthDailyCounts,
                                  isAnimated,
                                ),
                                isCurved: true,
                                color: context.palette.primary,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: context.palette.primary
                                      .withValues(alpha: 0.1),
                                ),
                              ),
                            ],
                          ),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeOutCubic,
                        );
                      },
                    ),
                  ),
                ),
              ),

              const Gap(40),
              const Divider(),
              const Gap(40),

              // ---  YEARLY CHART ---
              _buildSectionTitle('This Year Progress (${today.year})', cs),
              const Gap(24),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SizedBox(
                    height: 250,
                    child: _AnimatedChartWrapper(
                      builder: (isAnimated) {
                        return LineChart(
                          LineChartData(
                            minY: 0,
                            maxY: maxYYEAR,
                            minX: 1,
                            maxX: 12,
                            gridData: const FlGridData(
                              horizontalInterval: 100,
                              drawVerticalLine: false,
                            ),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(),
                              rightTitles: const AxisTitles(),
                              bottomTitles: AxisTitles(
                                axisNameWidget: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text('Month', style: axisTitleStyle),
                                ),
                                axisNameSize: 20,
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        _monthNameCaps(value.toInt()),
                                        style: axisLabelStyle.copyWith(
                                          fontSize: 9,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                axisNameWidget:
                                    Text('Chapters', style: axisTitleStyle),
                                axisNameSize: 20,
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 100,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) => Text(
                                    value.toInt().toString(),
                                    style: axisLabelStyle,
                                  ),
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: chartBorder,
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _generateMonthlySpots(
                                  stats.currentYearMonthlyCounts,
                                  isAnimated,
                                ),
                                isCurved: true,
                                color: context.palette.accent,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: context.palette.accent
                                      .withValues(alpha: 0.1),
                                ),
                              ),
                            ],
                          ),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeOutCubic,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const Gap(32),
            ],
          );
        },
      ),
    );
  }

  // --- HELPER CLASSES ---

  List<FlSpot> _generateDailySpots(Map<int, int> data, bool animate) {
    final today = DateTime.now();
    final spots = <FlSpot>[];

    // Loop ONLY up to today's day (e.g., if today is 5th, loop 1..5)
    for (var day = 1; day <= today.day; day++) {
      // If animating, show actual value; otherwise start at 0 for effect
      final value = animate ? (data[day] ?? 0).toDouble() : 0.0;
      spots.add(FlSpot(day.toDouble(), value));
    }
    return spots;
  }

  List<FlSpot> _generateMonthlySpots(Map<int, int> data, bool animate) {
    final today = DateTime.now();
    final spots = <FlSpot>[];

    // Loop ONLY up to current month (e.g., if Nov, loop 1..11)
    for (var month = 1; month <= today.month; month++) {
      final value = animate ? (data[month] ?? 0).toDouble() : 0.0;
      spots.add(FlSpot(month.toDouble(), value));
    }
    return spots;
  }

  Widget _buildSectionTitle(String title, ColorScheme cs) {
    return Center(
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: cs.onSurface,
        ),
      ),
    );
  }

  String _monthNameCaps(int index) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    if (index < 1 || index > 12) return '';
    return months[index - 1];
  }

  String _monthName(int index) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    if (index < 1 || index > 12) return '';
    return months[index - 1];
  }
}

// Reusing the wrapper here as well
class _AnimatedChartWrapper extends StatefulWidget {
  const _AnimatedChartWrapper({required this.builder});
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
