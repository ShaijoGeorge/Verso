import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/stats_providers.dart';

class DetailedStatsScreen extends ConsumerWidget {
  const DetailedStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(detailedStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detailed Stats')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (stats) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Testament Progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Gap(16),
                
                // 1. Testament Circles Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCircularIndicator(
                      context, 
                      'Old Testament', 
                      stats.otProgress, 
                      Colors.orangeAccent,
                      '${stats.otChaptersRead}/929'
                    ),
                    _buildCircularIndicator(
                      context, 
                      'New Testament', 
                      stats.ntProgress, 
                      Colors.blueAccent,
                      '${stats.ntChaptersRead}/260'
                    ),
                  ],
                ),

                const Gap(32),
                
                // 2. Overview Cards
                const Text(
                  'Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Gap(12),
                Row(
                  children: [
                    Expanded(child: _buildStatCard(
                      context, 
                      'Total Read', 
                      '${stats.otChaptersRead + stats.ntChaptersRead}',
                      Icons.book
                    )),
                    const Gap(12),
                    Expanded(child: _buildStatCard(
                      context, 
                      'Completion', 
                      '${((stats.otProgress * 929 + stats.ntProgress * 260) / 1189 * 100).toStringAsFixed(1)}%',
                      Icons.percent
                    )),
                  ],
                ),

                const Gap(32),

                // 3. Activity Chart (Mock Visual)
                const Text(
                  'Recent Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Gap(16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _generateChartData(stats),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper Widget: Circular Progress
  Widget _buildCircularIndicator(
    BuildContext context, 
    String title, 
    double progress, 
    Color color,
    String subtitle,
  ) {
    return Column(
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                // FIX 1: Use withValues instead of withOpacity
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(color),
                strokeCap: StrokeCap.round,
              ),
              Center(
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
        const Gap(8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  // Helper Widget: Stat Card
  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        // FIX 2: Use withValues instead of withOpacity
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const Gap(8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  List<BarChartGroupData> _generateChartData(dynamic stats) {
    return [
      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 5, color: Colors.blue)]),
      BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 2, color: Colors.blue)]),
      BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 8, color: Colors.blue)]),
      BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 4, color: Colors.blue)]),
      BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 6, color: Colors.blue)]),
    ];
  }
}