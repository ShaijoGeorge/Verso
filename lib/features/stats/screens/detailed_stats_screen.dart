import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../providers/stats_providers.dart';

class DetailedStatsScreen extends ConsumerStatefulWidget {
  const DetailedStatsScreen({super.key});

  @override
  ConsumerState<DetailedStatsScreen> createState() => _DetailedStatsScreenState();
}

class _DetailedStatsScreenState extends ConsumerState<DetailedStatsScreen> {
  bool _isChartAnimated = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isChartAnimated = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(detailedStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detailed Stats')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (stats) {
          final int maxRead = stats.last7DaysCounts.isNotEmpty 
              ? stats.last7DaysCounts.reduce(max) 
              : 0;
          final double maxY = maxRead > 30 ? maxRead.toDouble() + 5 : 30.0;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                _SectionHeader(title: "Testament Progress"),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _AnimatedTestamentCircle(
                        title: "Old Testament",
                        targetProgress: stats.otProgress,
                        color: Colors.orange,
                        scale: 1.3,
                      ),
                      _AnimatedTestamentCircle(
                        title: "New Testament",
                        targetProgress: stats.ntProgress,
                        color: Colors.blue,
                        scale: 1.3,
                      ),
                    ],
                  ),
                ),
                const Gap(16),

                _SectionHeader(title: "Overview of Chapters"),
                const Gap(16),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Expanded(child: _SummaryCard(
                        label: "Old Testament",
                        value: "${stats.otRead}/1074", 
                        color: Colors.orange.shade100,
                        textColor: Colors.orange.shade900,
                      )),
                      const Gap(8),
                      Expanded(child: _SummaryCard(
                        label: "New Testament", 
                        value: "${stats.ntRead}/260", 
                        color: Colors.blue.shade100,
                        textColor: Colors.blue.shade900,
                      )),
                      const Gap(8),
                      Expanded(child: _SummaryCard(
                        label: "Total Bible", 
                        value: "${stats.totalRead}/1334", 
                        color: Colors.green.shade100,
                        textColor: Colors.green.shade900,
                      )),
                    ],
                  ),
                ),
                const Gap(24),

                _SectionHeader(title: "Recent Activity (Last 7 Days)"),
                const Gap(8),
                SizedBox(
                  height: 240, 
                  child: ClipRect(
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: maxY,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: maxY / 5,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.withValues(alpha: 0.1),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            axisNameWidget: const Text("Date", style: TextStyle(fontSize: 10)),
                            axisNameSize: 20,
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= stats.last7DaysDates.length) {
                                  return const SizedBox();
                                }
                                final date = stats.last7DaysDates[index];
                                final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                                final label = "${months[date.month - 1]} ${date.day}";
                                
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    label,
                                    style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            axisNameWidget: const Text("Chapters", style: TextStyle(fontSize: 10)),
                            axisNameSize: 20,
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: (maxY / 5).ceilToDouble(), 
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(stats.last7DaysCounts.length, (index) {
                              final count = stats.last7DaysCounts[index].toDouble();
                              return FlSpot(index.toDouble(), _isChartAnimated ? count : 0);
                            }),
                            isCurved: true,
                            color: Theme.of(context).colorScheme.primary,
                            barWidth: 2, 
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                      duration: const Duration(milliseconds: 1000), 
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                ),
                const Gap(16),
                FilledButton.icon(
                  onPressed: () => context.push('/detailed-activity'),
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text("View Full Analytics"),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
    );
  }
}

class _AnimatedTestamentCircle extends StatelessWidget {
  final String title;
  final double targetProgress;
  final Color color;
  final double scale;

  const _AnimatedTestamentCircle({
    required this.title, 
    required this.targetProgress, 
    required this.color,
    this.scale = 1.0,
  });

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
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Gap(8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color textColor;

  const _SummaryCard({
    required this.label, 
    required this.value, 
    required this.color,
    required this.textColor,
  });

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
          Text(
            value,
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const Gap(4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}