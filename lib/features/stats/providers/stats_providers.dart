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

@riverpod
Future<UserStats> userStats(Ref ref) async {
  final repo = ref.watch(bibleRepositoryProvider);
  final streak = await repo.getCurrentStreak();
  final totalRead = await repo.countTotalRead();
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

  // Predictions REMOVED

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
  final repo = ref.watch(bibleRepositoryProvider);
  final history = await repo.getAllProgressSnapshot();

  const int totalOT = 1074;
  const int totalNT = 260;
  const int totalBible = 1334;

  final otRead = history.where((p) => p.bookId <= 39).length;
  final ntRead = history.where((p) => p.bookId >= 40).length;
  final totalRead = history.length;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // 1. Weekly Data
  final last7DaysDates = <DateTime>[];
  final last7DaysCounts = <int>[];
  for (int i = 6; i >= 0; i--) {
    final date = today.subtract(Duration(days: i));
    last7DaysDates.add(date);
    final count = history.where((p) {
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
  final monthHistory = history.where((p) =>
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
      history.where((p) => p.readAt != null && p.readAt!.year == now.year);
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
