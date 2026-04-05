import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../core/design/tokens/colors.dart';
import '../providers/stats_providers.dart';

class MonthlyTab extends StatelessWidget {
  final DetailedStats stats;

  const MonthlyTab({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final totalThisMonth = stats.currentMonthDailyCounts.values.fold(0, (a, b) => a + b);
    final daysWithReading = stats.currentMonthDailyCounts.values.where((v) => v > 0).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            _monthName(now.month),
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
                  text: '$totalThisMonth chapters ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                    fontSize: 16,
                  ),
                ),
                TextSpan(text: 'across $daysWithReading days'),
              ],
            ),
          ),
          const Gap(24),

          // Heatmap Calendar
          _HeatmapCalendar(
            year: now.year,
            month: now.month,
            dailyCounts: stats.currentMonthDailyCounts,
          ),
          const Gap(24),

          // Intensity legend
          _IntensityLegend(),
          const Gap(24),

          // Top reading days
          if (stats.currentMonthDailyCounts.isNotEmpty) ...[
            Text(
              'Top Reading Days',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Gap(12),
            ..._topDays(context, now),
          ],
        ],
      ),
    );
  }

  List<Widget> _topDays(BuildContext context, DateTime now) {
    final scheme = Theme.of(context).colorScheme;
    final sorted = stats.currentMonthDailyCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(5).map((entry) {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '${entry.key}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
            ),
            const Gap(12),
            Text(
              '${months[now.month - 1]} ${entry.key}',
              style: const TextStyle(fontSize: 14),
            ),
            const Spacer(),
            Text(
              '${entry.value} chapters',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: scheme.primary,
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

// Heatmap Calendar
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
    final dartWeekday = DateTime(year, month, 1).weekday; // 1=Mon, 7=Sun
    final firstWeekday = dartWeekday % 7; // Sun=0, Mon=1, ..., Sat=6
    final maxCount = dailyCounts.values.isEmpty ? 1 : dailyCounts.values.reduce(max);

    // Day labels (Sunday-first)
    const dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Column(
      children: [
        // Day-of-week header row
        Row(
          children: [
            const SizedBox(width: 0), // No left label column
            ...dayLabels.map((d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )),
          ],
        ),
        const Gap(8),

        // Calendar grid
        ...List.generate(_weekCount(daysInMonth, firstWeekday), (weekIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: List.generate(7, (dayOfWeek) {
                // dayOfWeek: 0=Sun, 6=Sat
                final dayNum = weekIndex * 7 + dayOfWeek - firstWeekday + 1;

                if (dayNum < 1 || dayNum > daysInMonth) {
                  // Empty cell (before month start or after month end)
                  return Expanded(child: AspectRatio(aspectRatio: 1, child: Container()));
                }

                final count = dailyCounts[dayNum] ?? 0;
                final intensity = maxCount > 0 ? count / maxCount : 0.0;
                final isToday = dayNum == DateTime.now().day &&
                    month == DateTime.now().month &&
                    year == DateTime.now().year;

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
                            color: _heatColor(intensity, isLight, scheme),
                            borderRadius: BorderRadius.circular(4),
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

  Color _heatColor(double intensity, bool isLight, ColorScheme scheme) {
    if (intensity <= 0) {
      return isLight ? AppColors.backgroundLight : AppColors.backgroundDark;
    }

    // Sacred Blue scale — uses the app's primary palette
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
// Intensity Legend (Less → More)
// ─────────────────────────────────────────────
class _IntensityLegend extends StatelessWidget {
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
