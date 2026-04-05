import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/design/tokens/colors.dart';
import '../providers/stats_providers.dart';
import '../widgets/time_period_navigator.dart';

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
        final daysWithReading = chartData.dailyCounts.values.where((v) => v > 0).length;
        final label = '${_monthName(chartData.month)} ${chartData.year}';

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period navigator
              TimePeriodNavigator(
                label: label,
                onPrevious: () => ref.read(monthlyOffsetProvider.notifier).goBack(),
                onNext: offset > 0
                    ? () => ref.read(monthlyOffsetProvider.notifier).goForward()
                    : null,
                onReset: offset > 0
                    ? () => ref.read(monthlyOffsetProvider.notifier).state = 0
                    : null,
              ),
              const Gap(16),

              // Summary
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
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
                      text: daysWithReading > 0
                          ? 'across $daysWithReading days'
                          : 'no reading recorded',
                    ),
                  ],
                ),
              ),
              const Gap(24),

              // Heatmap Calendar
              _HeatmapCalendar(
                year: chartData.year,
                month: chartData.month,
                dailyCounts: chartData.dailyCounts,
              ),
              const Gap(20),

              // Intensity legend
              const _IntensityLegend(),
              const Gap(28),

              // Top reading days
              if (chartData.dailyCounts.values.any((v) => v > 0)) ...[
                Text(
                  'Top Reading Days',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Gap(12),
                ..._topDays(context, chartData.dailyCounts, chartData.month, chartData.year),
              ] else ...[
                // Empty state for months with no data
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 40,
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                        ),
                        const Gap(12),
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

  List<Widget> _topDays(BuildContext context, Map<int, int> dailyCounts, int month, int year) {
    final scheme = Theme.of(context).colorScheme;
    final sorted = dailyCounts.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return sorted.take(5).map((entry) {
      final entryDate = DateTime(year, month, entry.key);
      final isToday = entryDate == today;

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                '${entry.key}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
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
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
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
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: scheme.outline.withValues(alpha: 0.1),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (entry.value / sorted.first.value).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: scheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _monthName(int m) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[m - 1];
  }
}

// ─────────────────────────────────────────────
// Heatmap Calendar (Sunday-first)
// ─────────────────────────────────────────────
class _HeatmapCalendar extends StatelessWidget {
  final int year;
  final int month;
  final Map<int, int> dailyCounts;

  const _HeatmapCalendar({
    required this.year,
    required this.month,
    required this.dailyCounts,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    // Convert Dart weekday (1=Mon..7=Sun) to Sunday-first (0=Sun..6=Sat)
    final dartWeekday = DateTime(year, month, 1).weekday;
    final firstWeekday = dartWeekday % 7;
    final maxCount = dailyCounts.values.isEmpty ? 1 : dailyCounts.values.reduce(max);

    const dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Column(
      children: [
        // Day-of-week header
        Row(
          children: dayLabels.map((d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              )).toList(),
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
                  return Expanded(child: AspectRatio(aspectRatio: 1, child: Container()));
                }

                final count = dailyCounts[dayNum] ?? 0;
                final intensity = maxCount > 0 ? count / maxCount : 0.0;
                final cellDate = DateTime(year, month, dayNum);
                final isToday = cellDate == today;

                return Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Tooltip(
                        message: '$count chapter${count == 1 ? '' : 's'}',
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          decoration: BoxDecoration(
                            color: _heatColor(intensity, isLight),
                            borderRadius: BorderRadius.circular(5),
                            border: isToday
                                ? Border.all(color: scheme.primary, width: 2)
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$dayNum',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                              color: intensity > 0.25
                                  ? Colors.white.withValues(alpha: 0.9)
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

  Color _heatColor(double intensity, bool isLight) {
    if (intensity <= 0) {
      return isLight ? AppColors.backgroundLight : AppColors.backgroundDark;
    }

    // Sacred Blue scale
    if (intensity <= 0.25) {
      return isLight ? AppColors.primaryContainerLight : AppColors.primaryContainerDark;
    } else if (intensity <= 0.5) {
      return isLight ? const Color(0xFF7EB8E0) : const Color(0xFF1B3A5C);
    } else if (intensity <= 0.75) {
      return isLight ? const Color(0xFF3B82C4) : const Color(0xFF4A90D9);
    } else {
      return isLight ? AppColors.primaryLight : AppColors.primaryDark;
    }
  }
}

// ─────────────────────────────────────────────
// Intensity Legend
// ─────────────────────────────────────────────
class _IntensityLegend extends StatelessWidget {
  const _IntensityLegend();

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final scheme = Theme.of(context).colorScheme;

    final colors = isLight
        ? [AppColors.backgroundLight, AppColors.primaryContainerLight,
           const Color(0xFF7EB8E0), const Color(0xFF3B82C4), AppColors.primaryLight]
        : [AppColors.backgroundDark, AppColors.primaryContainerDark,
           const Color(0xFF1B3A5C), const Color(0xFF4A90D9), AppColors.primaryDark];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Less', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
        const Gap(6),
        ...colors.map((c) => Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(3),
              ),
            )),
        const Gap(6),
        Text('More', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
      ],
    );
  }
}
