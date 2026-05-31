import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verso/data/bible_data.dart';
import 'package:verso/data/local/entities/reading_progress.dart';
import 'package:verso/features/reading/providers/reading_providers.dart';

part 'stats_providers.g.dart';

/// Increments when the user re-enters the Stats branch from another tab.
/// StatsScreen listens to this and resets to the Overview tab.
class StatsTabResetTrigger extends Notifier<int> {
  @override
  int build() => 0;
  void trigger() => state++;
}

final statsTabResetTriggerProvider =
    NotifierProvider<StatsTabResetTrigger, int>(StatsTabResetTrigger.new);

class UserStats {
  UserStats({
    required this.streak,
    required this.totalChaptersRead,
    required this.booksCompleted,
    required this.totalProgress,
  });
  final int streak;
  final int totalChaptersRead;
  final int booksCompleted;
  final double totalProgress;
}

int _calculateStreak(List<ReadingProgress> history) {
  if (history.isEmpty) return 0;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  final readDates = history
      .where((p) => p.isRead && p.readAt != null)
      .map((p) => p.readAt!.toLocal()) // Convert to local time
      .map((dt) {
        final d = DateTime(dt.year, dt.month, dt.day);
        // Sanitization: If an old record was saved with the timezone bug,
        // it might appear as "tomorrow". Clamp it to today to avoid breaking streaks.
        if (d.isAfter(today)) return today;
        return d;
      })
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a)); // Descending

  if (readDates.isEmpty) return 0;

  // If the most recent read is not today or yesterday, streak is broken
  if (readDates.first != today && readDates.first != yesterday) {
    return 0;
  }

  var streak = 0;
  var targetDate = readDates.first;

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

  final readHistory = history.where((p) => p.isRead).toList();
  final totalRead = readHistory.length;
  final streak = _calculateStreak(history);

  // Calculate Books Completed
  var completedBooksCount = 0;
  final readChaptersByBook = <int, Set<int>>{};
  for (final progress in readHistory) {
    readChaptersByBook.putIfAbsent(progress.bookId, () => <int>{});
    readChaptersByBook[progress.bookId]!.add(progress.chapterNumber);
  }

  for (final book in kBibleBooks) {
    final readCount = readChaptersByBook[book.id]?.length ?? 0;
    if (readCount >= book.chapters) {
      completedBooksCount++;
    }
  }

  const totalChaptersInBible = 1334;
  final progress =
      totalChaptersInBible > 0 ? (totalRead / totalChaptersInBible) * 100 : 0.0;

  return UserStats(
    streak: streak,
    totalChaptersRead: totalRead,
    booksCompleted: completedBooksCount,
    totalProgress: progress,
  );
}

class DetailedStats {
  DetailedStats({
    required this.otRead,
    required this.ntRead,
    required this.totalRead,
    required this.otBooksCompleted,
    required this.ntBooksCompleted,
    required this.otProgress,
    required this.ntProgress,
    required this.totalProgress,
    required this.last7DaysDates,
    required this.last7DaysCounts,
    required this.currentMonthDailyCounts,
    required this.currentYearMonthlyCounts,
    required this.averageChaptersPerDay,
    required this.streak,
    required this.bookCompletionMap,
  });
  final int otRead;
  final int ntRead;
  final int totalRead;
  final int otBooksCompleted;
  final int ntBooksCompleted;
  final double otProgress;
  final double ntProgress;
  final double totalProgress;

  final List<DateTime> last7DaysDates;
  final List<int> last7DaysCounts;
  final Map<int, int> currentMonthDailyCounts;
  final Map<int, int> currentYearMonthlyCounts;
  final double averageChaptersPerDay;
  final int streak;

  /// Per-book completion: bookId → fraction (0.0 to 1.0)
  final Map<int, double> bookCompletionMap;
}

@riverpod
Future<DetailedStats> detailedStats(Ref ref) async {
  final history = await ref.watch(globalProgressProvider.future);

  const totalOT = 1074;
  const totalNT = 260;
  const totalBible = 1334;

  final readHistory = history.where((p) => p.isRead).toList();

  final otRead = readHistory.where((p) => p.bookId <= 39).length;
  final ntRead = readHistory.where((p) => p.bookId >= 40).length;
  final totalRead = readHistory.length;

  // Calculate Books Completed for OT/NT
  var otBooksCompleted = 0;
  var ntBooksCompleted = 0;
  final readChaptersByBook = <int, Set<int>>{};
  for (final progress in readHistory) {
    readChaptersByBook.putIfAbsent(progress.bookId, () => <int>{});
    readChaptersByBook[progress.bookId]!.add(progress.chapterNumber);
  }

  for (final book in kBibleBooks) {
    final readCount = readChaptersByBook[book.id]?.length ?? 0;
    if (readCount >= book.chapters) {
      if (book.testament == Testament.old) {
        otBooksCompleted++;
      } else {
        ntBooksCompleted++;
      }
    }
  }

  // Per-book completion fractions for the 73-book grid
  final bookCompletionMap = <int, double>{};
  for (final book in kBibleBooks) {
    final readCount = readChaptersByBook[book.id]?.length ?? 0;
    bookCompletionMap[book.id] =
        book.chapters > 0 ? readCount / book.chapters : 0.0;
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Sanitize history: Convert to local time and clamp corrupted future dates to today
  final sanitizedHistory = readHistory.where((p) => p.readAt != null).map((p) {
    final localDt = p.readAt!.toLocal();
    if (DateTime(localDt.year, localDt.month, localDt.day).isAfter(today)) {
      return DateTime(
        today.year,
        today.month,
        today.day,
        localDt.hour,
        localDt.minute,
      );
    }
    return localDt;
  }).toList();

  // 1. Weekly Data
  final last7DaysDates = <DateTime>[];
  final last7DaysCounts = <int>[];
  for (var i = 6; i >= 0; i--) {
    final date = today.subtract(Duration(days: i));
    last7DaysDates.add(date);
    final count = sanitizedHistory.where((dt) {
      return dt.year == date.year &&
          dt.month == date.month &&
          dt.day == date.day;
    }).length;
    last7DaysCounts.add(count);
  }

  // 2. Monthly Data
  final currentMonthDailyCounts = <int, int>{};
  final monthHistory = sanitizedHistory.where(
    (dt) => dt.year == now.year && dt.month == now.month,
  );
  for (final dt in monthHistory) {
    currentMonthDailyCounts[dt.day] =
        (currentMonthDailyCounts[dt.day] ?? 0) + 1;
  }

  // 3. Yearly Data
  final currentYearMonthlyCounts = <int, int>{};
  final yearHistory = sanitizedHistory.where((dt) => dt.year == now.year);
  for (final dt in yearHistory) {
    currentYearMonthlyCounts[dt.month] =
        (currentYearMonthlyCounts[dt.month] ?? 0) + 1;
  }

  // 4. Average
  final recentTotal = last7DaysCounts.reduce((a, b) => a + b);
  final dailyRate = recentTotal > 0 ? recentTotal / 7.0 : 0.0;

  return DetailedStats(
    otRead: otRead,
    ntRead: ntRead,
    totalRead: totalRead,
    otBooksCompleted: otBooksCompleted,
    ntBooksCompleted: ntBooksCompleted,
    otProgress: otRead / totalOT,
    ntProgress: ntRead / totalNT,
    totalProgress: totalRead / totalBible,
    last7DaysDates: last7DaysDates,
    last7DaysCounts: last7DaysCounts,
    currentMonthDailyCounts: currentMonthDailyCounts,
    currentYearMonthlyCounts: currentYearMonthlyCounts,
    averageChaptersPerDay: dailyRate,
    streak: _calculateStreak(history),
    bookCompletionMap: bookCompletionMap,
  );
}

// --- WEEKLY PROVIDERS ---

class WeeklyChartData {
  WeeklyChartData(this.dates, this.counts, this.totalRead);
  final List<DateTime> dates;
  final List<int> counts;
  final int totalRead;
}

@riverpod
class WeeklyOffset extends _$WeeklyOffset {
  @override
  int build() => 0;

  void goBack() => state++;
  void goForward() {
    if (state > 0) state--;
  }

  void reset() => state = 0;
}

@riverpod
Future<WeeklyChartData> weeklyChartStats(Ref ref, int weeksAgo) async {
  final history = await ref.watch(globalProgressProvider.future);
  final readHistory = history.where((p) => p.isRead).toList();

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final startOfWeek = today.subtract(Duration(days: weeksAgo * 7));

  final dates = <DateTime>[];
  final counts = <int>[];
  var totalRead = 0;

  for (var i = 6; i >= 0; i--) {
    final date = startOfWeek.subtract(Duration(days: i));
    dates.add(date);

    final count = readHistory.where((p) {
      if (p.readAt == null) return false;
      final pDate = p.readAt!;
      return pDate.year == date.year &&
          pDate.month == date.month &&
          pDate.day == date.day;
    }).length;

    counts.add(count);
    totalRead += count;
  }

  return WeeklyChartData(dates, counts, totalRead);
}

// --- MONTHLY PROVIDERS ---

class MonthlyChartData {
  MonthlyChartData(this.year, this.month, this.dailyCounts, this.totalRead);
  final int year;
  final int month;
  final Map<int, int> dailyCounts;
  final int totalRead;
}

@riverpod
class MonthlyOffset extends _$MonthlyOffset {
  @override
  int build() => 0;

  void goBack() => state++;
  void goForward() {
    if (state > 0) state--;
  }

  void reset() => state = 0;
}

@riverpod
Future<MonthlyChartData> monthlyChartStats(Ref ref, int monthsAgo) async {
  final history = await ref.watch(globalProgressProvider.future);
  final readHistory = history.where((p) => p.isRead).toList();

  final now = DateTime.now();

  // Calculate target month and year safely
  var targetYear = now.year;
  var targetMonth = now.month - monthsAgo;

  // If we go back past January, shift the year back
  while (targetMonth <= 0) {
    targetMonth += 12;
    targetYear--;
  }

  final dailyCounts = <int, int>{};
  var totalRead = 0;

  final monthHistory = readHistory.where(
    (p) =>
        p.readAt != null &&
        p.readAt!.year == targetYear &&
        p.readAt!.month == targetMonth,
  );

  for (final entry in monthHistory) {
    dailyCounts[entry.readAt!.day] = (dailyCounts[entry.readAt!.day] ?? 0) + 1;
    totalRead++;
  }

  return MonthlyChartData(targetYear, targetMonth, dailyCounts, totalRead);
}

// --- YEARLY PROVIDERS ---

class YearlyChartData {
  YearlyChartData(this.year, this.monthlyCounts, this.totalRead);
  final int year;
  final Map<int, int> monthlyCounts;
  final int totalRead;
}

@riverpod
class YearlyOffset extends _$YearlyOffset {
  @override
  int build() => 0;

  void goBack() => state++;
  void goForward() {
    if (state > 0) state--;
  }

  void reset() => state = 0;
}

@riverpod
Future<YearlyChartData> yearlyChartStats(Ref ref, int yearsAgo) async {
  final history = await ref.watch(globalProgressProvider.future);
  final readHistory = history.where((p) => p.isRead).toList();

  final now = DateTime.now();
  final targetYear = now.year - yearsAgo;

  final monthlyCounts = <int, int>{};
  var totalRead = 0;

  final yearHistory = readHistory
      .where((p) => p.readAt != null && p.readAt!.year == targetYear);

  for (final entry in yearHistory) {
    monthlyCounts[entry.readAt!.month] =
        (monthlyCounts[entry.readAt!.month] ?? 0) + 1;
    totalRead++;
  }

  return YearlyChartData(targetYear, monthlyCounts, totalRead);
}
