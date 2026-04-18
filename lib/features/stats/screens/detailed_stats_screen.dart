import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:verso/core/widgets/error_state_widget.dart';
import 'package:verso/features/stats/providers/stats_providers.dart';

class DetailedStatsScreen extends ConsumerStatefulWidget {
  const DetailedStatsScreen({super.key});

  @override
  ConsumerState<DetailedStatsScreen> createState() =>
      _DetailedStatsScreenState();
}

class _DetailedStatsScreenState extends ConsumerState<DetailedStatsScreen> {
  // A unique key generated every time the page opens.
  // This forces the "Count up" animations to replay on every visit.
  late UniqueKey _entryKey;

  @override
  void initState() {
    super.initState();
    _entryKey = UniqueKey();
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(detailedStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detailed Stats')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorStateWidget(
          error: err,
          onRetry: () => ref.invalidate(detailedStatsProvider),
        ),
        data: (stats) {
          final maxRead = stats.last7DaysCounts.isNotEmpty
              ? stats.last7DaysCounts.reduce(max)
              : 0;
          final maxY = maxRead > 30 ? maxRead.toDouble() + 5 : 30.0;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SectionHeader(title: 'Testament Progress'),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _AnimatedTestamentCircle(
                        key: ValueKey('ot_circle_$_entryKey'),
                        title: 'Old Testament',
                        targetProgress: stats.otProgress,
                        color: Colors.orange,
                        scale: 1.3,
                      ),
                      _AnimatedTestamentCircle(
                        key: ValueKey('nt_circle_$_entryKey'),
                        title: 'New Testament',
                        targetProgress: stats.ntProgress,
                        color: Colors.blue,
                        scale: 1.3,
                      ),
                    ],
                  ),
                ),
                const Gap(16),
                const _SectionHeader(title: 'Overview of Chapters'),
                const Gap(16),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          key: ValueKey('ot_card_$_entryKey'),
                          label: 'Old Testament',
                          currentValue: stats.otRead,
                          maxValue: 1074,
                          color: Colors.orange.shade100,
                          textColor: Colors.orange.shade900,
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: _SummaryCard(
                          key: ValueKey('nt_card_$_entryKey'),
                          label: 'New Testament',
                          currentValue: stats.ntRead,
                          maxValue: 260,
                          color: Colors.blue.shade100,
                          textColor: Colors.blue.shade900,
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: _SummaryCard(
                          key: ValueKey('total_card_$_entryKey'),
                          label: 'Total Bible',
                          currentValue: stats.totalRead,
                          maxValue: 1334,
                          color: Colors.green.shade100,
                          textColor: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(24),
                const _SectionHeader(title: 'Recent Activity (Last 7 Days)'),
                const Gap(8),
                SizedBox(
                  height: 240,
                  child: ClipRect(
                    // [FIX] Wrapper ensures animation starts ONLY after data loads
                    child: _AnimatedChartWrapper(
                      builder: (isAnimated) {
                        return LineChart(
                          LineChartData(
                            minY: 0,
                            maxY: maxY,
                            gridData: FlGridData(
                              drawVerticalLine: false,
                              horizontalInterval: maxY / 5,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: Colors.grey.withValues(alpha: 0.1),
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(),
                              rightTitles: const AxisTitles(),
                              bottomTitles: AxisTitles(
                                axisNameWidget: const Text(
                                  'Date',
                                  style: TextStyle(fontSize: 10),
                                ),
                                axisNameSize: 20,
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index < 0 ||
                                        index >= stats.last7DaysDates.length) {
                                      return const SizedBox();
                                    }
                                    final date = stats.last7DaysDates[index];
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
                                    final label =
                                        '${months[date.month - 1]} ${date.day}';

                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                axisNameWidget: const Text(
                                  'Chapters',
                                  style: TextStyle(fontSize: 10),
                                ),
                                axisNameSize: 20,
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: (maxY / 5).ceilToDouble(),
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) => Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: List.generate(
                                    stats.last7DaysCounts.length, (index) {
                                  final count =
                                      stats.last7DaysCounts[index].toDouble();
                                  // ANIMATION LOGIC:
                                  // If isAnimated is false (first frame), show 0.
                                  // If true (after 50ms), show real count.
                                  // FlChart animates the transition automatically.
                                  return FlSpot(
                                    index.toDouble(),
                                    isAnimated ? count : 0,
                                  );
                                }),
                                isCurved: true,
                                color: Theme.of(context).colorScheme.primary,
                                isStrokeCapRound: true,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
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
                const Gap(16),
                FilledButton.icon(
                  onPressed: () => context.go('/detailed-activity'),
                  icon: const Icon(Icons.auto_stories_rounded),
                  label: const Text(' View Full Analytics'),
                ),
                const Gap(24),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- NEW HELPER WIDGET ---
// This widget waits until it is mounted (data loaded) before triggering
// the animation flag. This solves the race condition.
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
    // Trigger animation slightly after the widget appears
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) => widget.builder(_visible);
}

// ... _SectionHeader, _AnimatedTestamentCircle, _SummaryCard (Keep unchanged from previous code)
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
    );
  }
}

class _AnimatedTestamentCircle extends StatelessWidget {
  const _AnimatedTestamentCircle({
    required this.title,
    required this.targetProgress,
    required this.color,
    super.key,
    this.scale = 1.0,
  });
  final String title;
  final double targetProgress;
  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 90,
            width: 90,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: targetProgress),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutQuart,
              builder: (context, value, _) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: value,
                      strokeWidth: 8,
                      backgroundColor: color.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(color),
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Text(
                        '${(value * 100).toInt()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Gap(8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.currentValue,
    required this.maxValue,
    required this.color,
    required this.textColor,
    super.key,
  });
  final String label;
  final int currentValue;
  final int maxValue;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: currentValue),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, _) {
              return Text(
                '$animatedValue/$maxValue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              );
            },
          ),
          const Gap(4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
