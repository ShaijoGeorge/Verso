import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gap/gap.dart';
import '../providers/stats_providers.dart';

class WeeklyTab extends StatelessWidget {
  final DetailedStats stats;

  const WeeklyTab({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final total = stats.last7DaysCounts.reduce((a, b) => a + b);
    final maxCount = stats.last7DaysCounts.reduce(max);
    final maxY = maxCount > 10 ? maxCount.toDouble() + 3 : 12.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header stat
          Text(
            'Last 7 Days',
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
                  text: '$total chapters ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                    fontSize: 16,
                  ),
                ),
                const TextSpan(text: 'read this week'),
              ],
            ),
          ),
          const Gap(24),

          // Bar Chart
          SizedBox(
            height: 280,
            child: _AnimatedChartWrapper(
              builder: (isAnimated) {
                return BarChart(
                  BarChartData(
                    maxY: maxY,
                    alignment: BarChartAlignment.spaceAround,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final count = stats.last7DaysCounts[group.x];
                          return BarTooltipItem(
                            '$count chapters',
                            TextStyle(
                              color: scheme.onPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= stats.last7DaysDates.length) {
                              return const SizedBox();
                            }
                            final date = stats.last7DaysDates[index];
                            final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                days[date.weekday - 1],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: (maxY / 4).ceilToDouble().clamp(1, double.infinity),
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                fontSize: 10,
                                color: scheme.onSurfaceVariant,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: (maxY / 4).ceilToDouble().clamp(1, double.infinity),
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: scheme.outline.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(7, (index) {
                      final count = stats.last7DaysCounts[index].toDouble();
                      final isToday = index == 6;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: isAnimated ? count : 0,
                            width: 28,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: isToday
                                  ? [scheme.primary, scheme.primary.withValues(alpha: 0.7)]
                                  : isLight
                                      ? [const Color(0xFF7EB8E0), const Color(0xFFBBDEFB)]
                                      : [const Color(0xFF1B3A5C), const Color(0xFF7EB8E0)],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                );
              },
            ),
          ),
          const Gap(24),

          // Daily breakdown list
          ...List.generate(7, (index) {
            final date = stats.last7DaysDates[index];
            final count = stats.last7DaysCounts[index];
            final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            final isToday = index == 6;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(
                      isToday ? 'Today' : '${months[date.month - 1]} ${date.day}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                        color: isToday ? scheme.primary : scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: maxCount > 0 ? count / maxCount : 0,
                        minHeight: 8,
                        backgroundColor: scheme.outline.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation(
                          isToday ? scheme.primary : scheme.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),
                  SizedBox(
                    width: 20,
                    child: Text(
                      '$count',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
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
