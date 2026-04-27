import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:verso/core/design/extensions.dart';
import 'package:verso/features/stats/providers/stats_providers.dart';
import 'package:verso/features/stats/widgets/time_period_navigator.dart';

class WeeklyTab extends ConsumerWidget {
  const WeeklyTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final offset = ref.watch(weeklyOffsetProvider);
    final asyncData = ref.watch(weeklyChartStatsProvider(offset));

    return asyncData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (chartData) {
        final total = chartData.totalRead;
        final maxCount =
            chartData.counts.isEmpty ? 0 : chartData.counts.reduce(max);
        final maxY = maxCount > 10 ? maxCount.toDouble() + 3 : 12.0;

        final firstDate = chartData.dates.first;
        final lastDate = chartData.dates.last;
        final months = [
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
        final rangeLabel = offset == 0
            ? 'This Week'
            : '${months[firstDate.month - 1]} ${firstDate.day} – ${months[lastDate.month - 1]} ${lastDate.day}';

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period navigator
              TimePeriodNavigator(
                label: rangeLabel,
                onPrevious: () =>
                    ref.read(weeklyOffsetProvider.notifier).goBack(),
                onNext: offset > 0
                    ? () => ref.read(weeklyOffsetProvider.notifier).goForward()
                    : null,
                onReset: offset > 0
                    ? () => ref.read(weeklyOffsetProvider.notifier).reset()
                    : null,
              ),
              const Gap(16),

              // Summary line
              _SummaryLine(
                highlight: '$total chapters',
                suffix: offset == 0 ? 'read this week' : 'read that week',
                scheme: scheme,
              ),
              const Gap(24),

              // Bar Chart
              SizedBox(
                height: 260,
                child: _AnimatedChartWrapper(
                  key: ValueKey('weekly_chart_$offset'),
                  builder: (isAnimated) {
                    return BarChart(
                      BarChartData(
                        maxY: maxY,
                        alignment: BarChartAlignment.spaceAround,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => scheme.primaryContainer,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final count = chartData.counts[group.x];
                              return BarTooltipItem(
                                '$count chapters',
                                TextStyle(
                                  color: scheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(),
                          rightTitles: const AxisTitles(),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 ||
                                    index >= chartData.dates.length) {
                                  return const SizedBox();
                                }
                                final date = chartData.dates[index];
                                // Sunday-first labels
                                const days = [
                                  'Mon',
                                  'Tue',
                                  'Wed',
                                  'Thu',
                                  'Fri',
                                  'Sat',
                                  'Sun',
                                ];
                                final dayDate =
                                    DateTime(date.year, date.month, date.day);
                                final isTodayCell = dayDate == today;

                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        days[date.weekday - 1],
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isTodayCell
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isTodayCell
                                              ? scheme.primary
                                              : scheme.onSurfaceVariant,
                                        ),
                                      ),
                                      Text(
                                        '${date.day}',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: isTodayCell
                                              ? scheme.primary
                                                  .withValues(alpha: 0.8)
                                              : scheme.onSurfaceVariant
                                                  .withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: (maxY / 4)
                                  .ceilToDouble()
                                  .clamp(1, double.infinity),
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
                          drawVerticalLine: false,
                          horizontalInterval: (maxY / 4)
                              .ceilToDouble()
                              .clamp(1, double.infinity),
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: scheme.outline.withValues(alpha: 0.08),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(7, (index) {
                          final count = chartData.counts[index].toDouble();
                          final dayDate = DateTime(
                            chartData.dates[index].year,
                            chartData.dates[index].month,
                            chartData.dates[index].day,
                          );
                          final isToday = dayDate == today;

                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: isAnimated ? count : 0,
                                width: 26,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: isToday
                                      ? [
                                          scheme.primary,
                                          scheme.primary.withValues(alpha: 0.7),
                                        ]
                                      : count > 0
                                          ? isLight
                                              ? [
                                                  context
                                                      .appColors.primaryAccent,
                                                  context.appColors.ntContainer,
                                                ]
                                              : [
                                                  context.colors.primary,
                                                  context
                                                      .appColors.primaryAccent,
                                                ]
                                          : [
                                              scheme.outline
                                                  .withValues(alpha: 0.15),
                                              scheme.outline
                                                  .withValues(alpha: 0.08),
                                            ],
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
              const Gap(28),

              // Daily breakdown
              Text(
                'Daily Breakdown',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Gap(12),
              ...List.generate(7, (index) {
                final date = chartData.dates[index];
                final count = chartData.counts[index];
                final dayDate = DateTime(date.year, date.month, date.day);
                final isToday = dayDate == today;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 72,
                        child: Text(
                          isToday
                              ? 'Today'
                              : '${months[date.month - 1]} ${date.day}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isToday ? FontWeight.w700 : FontWeight.w500,
                            color: isToday
                                ? scheme.primary
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: maxCount > 0 ? count / maxCount : 0,
                            minHeight: 8,
                            backgroundColor:
                                scheme.outline.withValues(alpha: 0.08),
                            valueColor: AlwaysStoppedAnimation(
                              isToday
                                  ? scheme.primary
                                  : scheme.primary.withValues(alpha: 0.45),
                            ),
                          ),
                        ),
                      ),
                      const Gap(12),
                      SizedBox(
                        width: 24,
                        child: Text(
                          '$count',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: count > 0
                                ? scheme.onSurface
                                : scheme.onSurfaceVariant,
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
      },
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.highlight,
    required this.suffix,
    required this.scheme,
  });
  final String highlight;
  final String suffix;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
        children: [
          TextSpan(
            text: '$highlight ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: scheme.primary,
              fontSize: 16,
            ),
          ),
          TextSpan(text: suffix),
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
