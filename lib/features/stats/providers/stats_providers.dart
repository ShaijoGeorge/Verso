import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../reading/providers/reading_providers.dart';
import '../../../data/local/entities/reading_progress.dart';

part 'stats_providers.g.dart';



class UserStats {
  final int streak;
  final int totalChaptersRead;
  final double totalProgress;

  UserStats({
    required this.streak,
    required this.totalChaptersRead,
    required this.totalProgress,
  });
}

int _calculateStreak(List<ReadingProgress> history) {
  if (history.isEmpty) return 0;

  final readDates = history
      .where((p) => p.isRead && p.readAt != null)
      .map((p) => p.readAt!)
      .map((dt) => DateTime(dt.year, dt.month, dt.day))
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a)); // Descending

  if (readDates.isEmpty) return 0;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  // If the most recent read is not today or yesterday, streak is broken
  if (readDates.first != today && readDates.first != yesterday) {
    return 0;
  }

  int streak = 0;
  DateTime targetDate = readDates.first;

  for (final day in readDates) {
    if (day == targetDate) {
      streak++;
      targetDate = targetDate.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }
  return streak;
}

@riverpod
Future<UserStats> userStats(Ref ref) async {
  // Watch the global stream's latest data
  final history = await ref.watch(globalProgressProvider.future);
  
  final totalRead = history.where((p) => p.isRead).length;
  final streak = _calculateStreak(history);
  
  const totalChaptersInBible = 1334;
  final progress =
      totalChaptersInBible > 0 ? (totalRead / totalChaptersInBible) * 100 : 0.0;

  return UserStats(
    streak: streak,
    totalChaptersRead: totalRead,
    totalProgress: progress,
  );
}

class DetailedStats {
  final int otRead;
  final int ntRead;
  final int totalRead;
  final double otProgress;
  final double ntProgress;
  final double totalProgress;

  final List<DateTime> last7DaysDates;
  final List<int> last7DaysCounts;
  final Map<int, int> currentMonthDailyCounts;
  final Map<int, int> currentYearMonthlyCounts;
  final double averageChaptersPerDay;

  DetailedStats({
    required this.otRead,
    required this.ntRead,
    required this.totalRead,
    required this.otProgress,
    required this.ntProgress,
    required this.totalProgress,
    required this.last7DaysDates,
    required this.last7DaysCounts,
    required this.currentMonthDailyCounts,
    required this.currentYearMonthlyCounts,
    required this.averageChaptersPerDay,
  });
}

@riverpod
Future<DetailedStats> detailedStats(Ref ref) async {
  final history = await ref.watch(globalProgressProvider.future);

  const int totalOT = 1074;
  const int totalNT = 260;
  const int totalBible = 1334;

  final readHistory = history.where((p) => p.isRead).toList();

  final otRead = readHistory.where((p) => p.bookId <= 39).length;
  final ntRead = readHistory.where((p) => p.bookId >= 40).length;
  final totalRead = readHistory.length;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // 1. Weekly Data
  final last7DaysDates = <DateTime>[];
  final last7DaysCounts = <int>[];
  for (int i = 6; i >= 0; i--) {
    final date = today.subtract(Duration(days: i));
    last7DaysDates.add(date);
    final count = readHistory.where((p) {
      if (p.readAt == null) return false;
      final pDate = p.readAt!;
      return pDate.year == date.year &&
          pDate.month == date.month &&
          pDate.day == date.day;
    }).length;
    last7DaysCounts.add(count);
  }

  // 2. Monthly Data
  final currentMonthDailyCounts = <int, int>{};
  final monthHistory = readHistory.where((p) =>
      p.readAt != null &&
      p.readAt!.year == now.year &&
      p.readAt!.month == now.month);
  for (final entry in monthHistory) {
    currentMonthDailyCounts[entry.readAt!.day] =
        (currentMonthDailyCounts[entry.readAt!.day] ?? 0) + 1;
  }

  // 3. Yearly Data
  final currentYearMonthlyCounts = <int, int>{};
  final yearHistory =
      readHistory.where((p) => p.readAt != null && p.readAt!.year == now.year);
  for (final entry in yearHistory) {
    currentYearMonthlyCounts[entry.readAt!.month] =
        (currentYearMonthlyCounts[entry.readAt!.month] ?? 0) + 1;
  }

  // 4. Average
  final recentTotal = last7DaysCounts.reduce((a, b) => a + b);
  final dailyRate = recentTotal > 0 ? recentTotal / 7.0 : 0.0;

  return DetailedStats(
    otRead: otRead,
    ntRead: ntRead,
    totalRead: totalRead,
    otProgress: otRead / totalOT,
    ntProgress: ntRead / totalNT,
    totalProgress: totalRead / totalBible,
    last7DaysDates: last7DaysDates,
    last7DaysCounts: last7DaysCounts,
    currentMonthDailyCounts: currentMonthDailyCounts,
    currentYearMonthlyCounts: currentYearMonthlyCounts,
    averageChaptersPerDay: dailyRate,
  );
}
