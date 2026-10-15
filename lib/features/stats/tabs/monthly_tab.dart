import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:verso/core/design/components/verso_card.dart';
import 'package:verso/core/design/components/verso_section_header.dart';
import 'package:verso/core/design/extensions.dart';
import 'package:verso/features/stats/providers/stats_providers.dart';
import 'package:verso/features/stats/widgets/time_period_navigator.dart';

class MonthlyTab extends ConsumerWidget {
  const MonthlyTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    final offset = ref.watch(monthlyOffsetProvider);
    final asyncData = ref.watch(monthlyChartStatsProvider(offset));

    return asyncData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (chartData) {
        final daysWithReading =
            chartData.dailyCounts.values.where((v) => v > 0).length;
        final label = '${_monthName(chartData.month)} ${chartData.year}';

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period navigator
              TimePeriodNavigator(
                label: label,
                onPrevious: () =>
                    ref.read(monthlyOffsetProvider.notifier).goBack(),
                onNext: offset > 0
                    ? () => ref.read(monthlyOffsetProvider.notifier).goForward()
                    : null,
                onReset: offset > 0
                    ? () => ref.read(monthlyOffsetProvider.notifier).reset()
                    : null,
              ),
              const Gap(16),

              // Summary
              VersoCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                        children: [
                          TextSpan(
                            text: '${chartData.totalRead} chapters ',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: scheme.primary,
                              fontSize: 18,
                              letterSpacing: -0.3,
                            ),
                          ),
                          TextSpan(
                            text: daysWithReading > 0
                                ? 'across $daysWithReading active days'
                                : 'no reading recorded',
                          ),
                        ],
                      ),
                    ),
                    const Gap(20),
                    // Heatmap Calendar
                    _HeatmapCalendar(
                      year: chartData.year,
                      month: chartData.month,
                      dailyCounts: chartData.dailyCounts,
                    ),
                    const Gap(18),
                    // Intensity legend
                    const _IntensityLegend(),
                  ],
                ),
              ),
              const Gap(24),

              // Top reading days
              if (chartData.dailyCounts.values.any((v) => v > 0)) ...[
                const VersoSectionHeader(title: 'Top Reading Days'),
                const Gap(12),
                VersoCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: _topDays(
                      context,
                      chartData.dailyCounts,
                      chartData.month,
                      chartData.year,
                    ),
                  ),
                ),
              ] else ...[
                // Empty state for months with no data
                VersoCard(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 36,
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                        ),
                        const Gap(10),
                        Text(
                          'No reading activity this month',
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

  List<Widget> _topDays(
    BuildContext context,
    Map<int, int> dailyCounts,
    int month,
    int year,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final sorted = dailyCounts.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final topItems = sorted.take(5).toList();

    return List.generate(topItems.length, (i) {
      final entry = topItems[i];
      final entryDate = DateTime(year, month, entry.key);
      final isToday = entryDate == today;

      return Padding(
        padding: EdgeInsets.only(bottom: i == topItems.length - 1 ? 0 : 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              alignment: Alignment.center,
              child: Text(
                '${entry.key}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                  fontSize: 15,
                ),
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToday ? 'Today' : '${months[month - 1]} ${entry.key}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                      color: isToday ? scheme.primary : scheme.onSurface,
                    ),
                  ),
                  Text(
                    '${entry.value} chapter${entry.value == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Mini bar indicator
            Container(
              width: 56,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: scheme.outline.withValues(alpha: 0.12),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (entry.value / sorted.first.value).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: scheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  String _monthName(int m) {
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
    return months[m - 1];
  }
}

// Heatmap Calendar (Sunday-first)
class _HeatmapCalendar extends StatelessWidget {
  const _HeatmapCalendar({
    required this.year,
    required this.month,
    required this.dailyCounts,
  });
  final int year;
  final int month;
  final Map<int, int> dailyCounts;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    // Convert Dart weekday (1=Mon..7=Sun) to Sunday-first (0=Sun..6=Sat)
    final dartWeekday = DateTime(year, month).weekday;
    final firstWeekday = dartWeekday % 7;
    final maxCount =
        dailyCounts.values.isEmpty ? 1 : dailyCounts.values.reduce(max);

    const dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Column(
      children: [
        // Day-of-week header
        Row(
          children: dayLabels
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const Gap(8),
        // Calendar grid
        ...List.generate(_weekCount(daysInMonth, firstWeekday), (weekIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: List.generate(7, (dayOfWeek) {
                final dayNum = weekIndex * 7 + dayOfWeek - firstWeekday + 1;

                if (dayNum < 1 || dayNum > daysInMonth) {
                  return Expanded(
                    child: AspectRatio(aspectRatio: 1, child: Container()),
                  );
                }

                final count = dailyCounts[dayNum] ?? 0;
                final intensity = maxCount > 0 ? count / maxCount : 0.0;
                final cellDate = DateTime(year, month, dayNum);
                final isToday = cellDate == today;

                return Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(2.5),
                      child: Tooltip(
                        message: '$count chapter${count == 1 ? '' : 's'}',
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          decoration: BoxDecoration(
                            color: _heatColor(context, intensity),
                            borderRadius: BorderRadius.circular(7),
                            border: isToday
                                ? Border.all(color: scheme.primary, width: 2)
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$dayNum',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight:
                                  isToday ? FontWeight.w800 : FontWeight.w600,
                              color: intensity > 0.25
                                  ? Colors.white.withValues(alpha: 0.95)
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  int _weekCount(int daysInMonth, int firstWeekday) {
    final totalSlots = firstWeekday + daysInMonth;
    return (totalSlots / 7).ceil();
  }

  Color _heatColor(BuildContext context, double intensity) {
    if (intensity <= 0) {
      return context.palette.surfaceAlt.withValues(alpha: 0.65);
    }

    if (intensity <= 0.25) {
      return context.palette.primary.withValues(alpha: 0.32);
    } else if (intensity <= 0.5) {
      return context.palette.primary.withValues(alpha: 0.54);
    } else if (intensity <= 0.75) {
      return context.palette.primary.withValues(alpha: 0.78);
    } else {
      return context.palette.primary;
    }
  }
}

// Intensity Legend
class _IntensityLegend extends StatelessWidget {
  const _IntensityLegend();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final colors = [
      context.palette.surfaceAlt.withValues(alpha: 0.65),
      context.palette.primary.withValues(alpha: 0.32),
      context.palette.primary.withValues(alpha: 0.54),
      context.palette.primary.withValues(alpha: 0.78),
      context.palette.primary,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Less',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const Gap(6),
        ...colors.map(
          (c) => Container(
            width: 15,
            height: 15,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const Gap(6),
        Text(
          'More',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
