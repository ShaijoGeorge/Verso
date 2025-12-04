import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/stats_providers.dart';

class ActivityAnalyticsScreen extends ConsumerStatefulWidget {
  const ActivityAnalyticsScreen({super.key});

  @override
  ConsumerState<ActivityAnalyticsScreen> createState() => _ActivityAnalyticsScreenState();
}

class _ActivityAnalyticsScreenState extends ConsumerState<ActivityAnalyticsScreen> {
  bool _isChartAnimated = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _isChartAnimated = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(detailedStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detailed Activity')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (stats) {
          
          // Calculate Dynamic Y-Axis Max
          final int maxMonthly = stats.currentMonthDailyCounts.values.isEmpty 
              ? 0 : stats.currentMonthDailyCounts.values.reduce(max);
          final double maxYMonth = maxMonthly > 50 ? maxMonthly.toDouble() + 5 : 50.0;

          final int maxYearly = stats.currentYearMonthlyCounts.values.isEmpty 
              ? 0 : stats.currentYearMonthlyCounts.values.reduce(max);
          final double maxYYEAR = maxYearly > 500 ? maxYearly.toDouble() + 50 : 500.0;

          final today = DateTime.now();
          final daysInMonth = DateUtils.getDaysInMonth(today.year, today.month);

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            children: [
              
              // --- 1. MONTHLY CHART ---
              _buildSectionTitle('This Month Progress (${_monthName(today.month)} ${today.year})'),
              const Gap(24),
              Center( // Horizontal Center
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600), // Max Width
                  child: SizedBox(
                    height: 250, // Reduced Height
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: maxYMonth,
                        minX: 1, 
                        maxX: daysInMonth.toDouble(), // Grid covers full month
                        
                        gridData: const FlGridData(
                          show: true, 
                          horizontalInterval: 10,
                          drawVerticalLine: false,
                        ),
                        
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          
                          // BOTTOM AXIS (Days)
                          bottomTitles: AxisTitles(
                            axisNameWidget: const Padding(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Text("Day of Month", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                            ),
                            axisNameSize: 20,
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 5, // Label every 5 days to avoid crowding
                              reservedSize: 30, 
                              getTitlesWidget: (value, meta) {
                                final day = value.toInt();
                                if (day > daysInMonth) return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    day.toString(),
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // LEFT AXIS (Chapters)
                          leftTitles: AxisTitles(
                            axisNameWidget: const Text("Chapters", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                            axisNameSize: 20, 
                            sideTitles: SideTitles(
                              showTitles: true, 
                              interval: 10, 
                              reservedSize: 40, 
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        
                        borderData: FlBorderData(
                          show: true, 
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade300),
                            left: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        
                        lineBarsData: [
                          LineChartBarData(
                            // STOP LINE AT TODAY
                            spots: _generateDailySpots(stats.currentMonthDailyCounts, _isChartAnimated),
                            isCurved: true,
                            curveSmoothness: 0.35,
                            color: Colors.purpleAccent,
                            barWidth: 3, 
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false), 
                            belowBarData: BarAreaData(
                              show: true, 
                              color: Colors.purpleAccent.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                      duration: const Duration(milliseconds: 1000), 
                      curve: Curves.easeOutCubic, 
                    ),
                  ),
                ),
              ),
              
              const Gap(40),
              const Divider(),
              const Gap(40),

              // --- 2. YEARLY CHART ---
              _buildSectionTitle('This Year Progress (${today.year})'),
              const Gap(24),
              Center( // Horizontal Center
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600), // Max Width
                  child: SizedBox(
                    height: 250, // Reduced Height
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: maxYYEAR,
                        minX: 1,
                        maxX: 12, // Grid covers full year
                        
                        gridData: const FlGridData(
                          show: true, 
                          horizontalInterval: 100,
                          drawVerticalLine: false,
                        ),
                        
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          
                          // BOTTOM AXIS (Months)
                          bottomTitles: AxisTitles(
                            axisNameWidget: const Padding(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Text("Month", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                            ),
                            axisNameSize: 20,
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                // Only show odd months if screen is tight, or all if feasible
                                // Let's show all abbreviated 
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    _monthNameCaps(value.toInt()), 
                                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // LEFT AXIS (Chapters)
                          leftTitles: AxisTitles(
                            axisNameWidget: const Text("Chapters", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                            axisNameSize: 20,
                            sideTitles: SideTitles(
                              showTitles: true, 
                              interval: 100,
                              reservedSize: 40, 
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        
                        borderData: FlBorderData(
                          show: true, 
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade300),
                            left: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        
                        lineBarsData: [
                          LineChartBarData(
                            // STOP LINE AT CURRENT MONTH
                            spots: _generateMonthlySpots(stats.currentYearMonthlyCounts, _isChartAnimated),
                            isCurved: true,
                            curveSmoothness: 0.35,
                            color: Colors.teal,
                            barWidth: 3, 
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true, 
                              color: Colors.teal.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
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

  // --- Logic to STOP line at today's date ---
  List<FlSpot> _generateDailySpots(Map<int, int> data, bool animate) {
    final today = DateTime.now();
    final spots = <FlSpot>[];
    
    // Loop ONLY up to today's day (e.g., if today is 5th, loop 1..5)
    for (int day = 1; day <= today.day; day++) {
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
    for (int month = 1; month <= today.month; month++) {
      final value = animate ? (data[month] ?? 0).toDouble() : 0.0;
      spots.add(FlSpot(month.toDouble(), value));
    }
    return spots;
  }

  Widget _buildSectionTitle(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _monthNameCaps(int index) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    if (index < 1 || index > 12) return '';
    return months[index - 1];
  }

  String _monthName(int index) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    if (index < 1 || index > 12) return '';
    return months[index - 1];
  }
}