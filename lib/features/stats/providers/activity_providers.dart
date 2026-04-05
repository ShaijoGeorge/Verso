import 'package:collection/collection.dart';
import '../../reading/providers/reading_providers.dart';
import '../../../data/bible_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activity_providers.g.dart';

// Filter State

class ActivityFilter {
  final int? bookId; // Null means 'All Books'
  final DateTime? startDate;
  final DateTime? endDate;

  const ActivityFilter({this.bookId, this.startDate, this.endDate});

  bool get isActive => bookId != null || startDate != null || endDate != null;

  ActivityFilter copyWith({
    int? bookId,
    DateTime? startDate,
    DateTime? endDate,
    bool clearBookId = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return ActivityFilter(
      bookId: clearBookId ? null : (bookId ?? this.bookId),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
    );
  }
}

@riverpod
class ActivityFilterState extends _$ActivityFilterState {
  @override
  ActivityFilter build() => const ActivityFilter();

  void setBookFilter(int? bookId) {
    state = ActivityFilter(
      bookId: bookId,
      startDate: state.startDate,
      endDate: state.endDate,
    );
  }

  void setDateRange(DateTime? start, DateTime? end) {
    state = ActivityFilter(
      bookId: state.bookId,
      startDate: start,
      endDate: end,
    );
  }

  void clearFilters() {
    state = const ActivityFilter();
  }
}

// Activity Group Model

class ActivityGroup {
  final DateTime timestamp;
  final BibleBook book;
  final List<int> chapters;
  final bool isBulkAction; // Was this likely a "Mark All Read"?
  final bool isFinish;     // Did this complete the book?

  ActivityGroup({
    required this.timestamp,
    required this.book,
    required this.chapters,
    this.isBulkAction = false,
    this.isFinish = false,
  });

  String get timeOfDay {
    final hour = timestamp.hour;
    if (hour < 5) return 'Late Night 🌙';
    if (hour < 12) return 'Morning 🌅';
    if (hour < 17) return 'Afternoon ☀️';
    return 'Evening 🛋️';
  }

  String get description {
    if (isBulkAction) return 'Marked ${chapters.length} chapters as read';
    if (chapters.length == 1) return 'Read Chapter ${chapters.first}';

    // Sort chapters to handle "1, 2, 3"
    chapters.sort();
    // Check if consecutive (simple check)
    bool isConsecutive = true;
    for (int i = 0; i < chapters.length - 1; i++) {
      if (chapters[i + 1] != chapters[i] + 1) isConsecutive = false;
    }

    if (isConsecutive) {
      return 'Read Chapters ${chapters.first} - ${chapters.last}';
    }
    return 'Read Chapters ${chapters.join(", ")}';
  }
}

// Activity Log Provider (Grouped by Date)

@riverpod
Future<Map<DateTime, List<ActivityGroup>>> activityLog(Ref ref) async {
  // WATCH the filter - if filter changes, this entire function re-runs
  final filter = ref.watch(activityFilterStateProvider);

  // Fetch ALL raw history
  final allHistory = await ref.watch(bibleRepositoryProvider).getAllProgressSnapshot();

  // Detect Completed Books
  final Map<int, DateTime> bookCompletionTimes = {};
  
  // Group history by book to check completion status
  final historyByBook = groupBy(allHistory, (p) => p.bookId);

  for (final entry in historyByBook.entries) {
    final bookId = entry.key;
    final progressList = entry.value;
    
    // Find the book definition to get total chapters
    final book = kBibleBooks.firstWhere((b) => b.id == bookId, orElse: () => kBibleBooks.first);

    // Get unique read chapters
    final readChapterSet = progressList.map((p) => p.chapterNumber).toSet();

    // If all chapters are read, find the LATEST read time
    if (readChapterSet.length >= book.chapters) {
      final dates = progressList
          .map((p) => p.readAt)
          .where((d) => d != null)
          .cast<DateTime>()
          .toList();
      
      if (dates.isNotEmpty) {
        dates.sort(); // Ascending
        // The last date is when the book was "Finished"
        bookCompletionTimes[bookId] = dates.last;
      }
    }
  }

  // Sort by Time DESC (Newest first)
  allHistory.sort((a, b) => (b.readAt ?? DateTime(0)).compareTo(a.readAt ?? DateTime(0)));

  final List<ActivityGroup> groups = [];

  for (final entry in allHistory) {
    if (entry.readAt == null) continue;

    // Apply Filters
    if (filter.bookId != null && entry.bookId != filter.bookId) {
      continue;
    }
    if (filter.startDate != null && entry.readAt!.isBefore(filter.startDate!)) {
      continue;
    }
    if (filter.endDate != null &&
        entry.readAt!.isAfter(filter.endDate!.add(const Duration(days: 1)))) {
      continue;
    }

    final book = kBibleBooks.firstWhere((b) => b.id == entry.bookId);

    // Check finishing
    bool isFinisher = false;
    if (bookCompletionTimes.containsKey(book.id)) {
      final finishTime = bookCompletionTimes[book.id];
      if (entry.readAt!.isAtSameMomentAs(finishTime!)) {
        isFinisher = true;
      }
    }

    // Smart Grouping - same book, within 2 minutes = same session
    if (groups.isNotEmpty) {
      final lastGroup = groups.last;
      final timeDiff = lastGroup.timestamp.difference(entry.readAt!).inMinutes.abs();
      if (lastGroup.book.id == book.id && timeDiff < 2) {
        lastGroup.chapters.add(entry.chapterNumber);
        continue;
      }
    }

    groups.add(ActivityGroup(
      timestamp: entry.readAt!,
      book: book,
      chapters: [entry.chapterNumber],
      isFinish: isFinisher,
    ));
  }

  // Group by Date for Sticky Headers
  final Map<DateTime, List<ActivityGroup>> grouped = {};
  for (final g in groups) {
    final dateKey = DateTime(g.timestamp.year, g.timestamp.month, g.timestamp.day);
    grouped.putIfAbsent(dateKey, () => []).add(g);
  }

  return grouped;
}

// Helper: Books that have activity (for filter dropdown)

@riverpod
Future<List<BibleBook>> booksWithActivity(Ref ref) async {
  final allHistory = await ref.watch(bibleRepositoryProvider).getAllProgressSnapshot();
  final bookIds = allHistory.map((p) => p.bookId).toSet();
  return kBibleBooks.where((b) => bookIds.contains(b.id)).toList();
}