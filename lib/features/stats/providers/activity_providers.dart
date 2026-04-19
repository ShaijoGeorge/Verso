import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso/core/providers/connectivity_provider.dart';
import 'package:verso/data/bible_data.dart';
import 'package:verso/data/local/entities/reading_progress.dart';
import 'package:verso/features/reading/providers/reading_providers.dart';

part 'activity_providers.g.dart';

// Filter State

class ActivityFilter {
  const ActivityFilter({this.bookId, this.startDate, this.endDate});
  final int? bookId; // Null means 'All Books'
  final DateTime? startDate;
  final DateTime? endDate;

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
  // Did this complete the book?

  ActivityGroup({
    required this.timestamp,
    required this.book,
    required this.chapters,
    this.isBulkAction = false,
    this.isFinish = false,
  });
  final DateTime timestamp;
  final BibleBook book;
  final List<int> chapters;
  bool isBulkAction; // Was this likely a "Mark All Read"?
  bool isFinish;

  String get timeOfDay {
    final hour = timestamp.hour;
    if (hour < 5) return 'Late Night 🌙';
    if (hour < 12) return 'Morning 🌅';
    if (hour < 17) return 'Afternoon ☀️';
    return 'Evening 🌇';
  }

  String get description {
    if (isBulkAction) return 'Marked ${chapters.length} chapters as read';
    if (chapters.length == 1) return 'Read Chapter ${chapters.first}';

    // Sort chapters to handle "1, 2, 3" properly
    chapters.sort();
    // Check if consecutive (simple check)
    var isConsecutive = true;
    for (var i = 0; i < chapters.length - 1; i++) {
      if (chapters[i + 1] != chapters[i] + 1) isConsecutive = false;
    }

    if (isConsecutive) {
      return 'Read Chapters ${chapters.first} - ${chapters.last}';
    }
    return 'Read Chapters ${chapters.join(", ")}';
  }
}

// --- CORE OFFLINE-FIRST LOGIC ---

/// Fetches reading history. Handles network checks, caching, and optimistic UI updates.
Future<List<ReadingProgress>> _fetchOfflineFirstHistory(Ref ref) async {
  final repo = ref.watch(bibleRepositoryProvider);
  final isConnected = ref.watch(connectivityProvider);
  final cacheService = ref.watch(offlineCacheServiceProvider);

  // We need the user ID to apply pending writes locally
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

  var history = <ReadingProgress>[];

  if (isConnected) {
    try {
      // 1. Try fetching fresh data from the cloud
      history = await repo.getAllProgressSnapshot();
      // 2. Silently cache it for the next time we go offline
      cacheService.cacheProgress(history);
    } catch (_) {
      // If the network call fails (e.g., spotty connection), fallback to cache
      history = await cacheService.getCachedProgress();
    }
  } else {
    // 3. We are definitively offline, use the cache
    history = await cacheService.getCachedProgress();
  }

  // 4. Merge any pending actions the user JUST took
  // so the Journal immediately reflects their progress even before it syncs.
  final queue = await cacheService.getWriteQueue();
  if (queue.isNotEmpty && userId.isNotEmpty) {
    history = cacheService.mergeWithPendingWrites(history, queue, userId);
  }

  return history;
}

// --- Providers ---

@riverpod
Future<Map<DateTime, List<ActivityGroup>>> activityLog(Ref ref) async {
  // WATCH the filter - if filter changes, this entire function re-runs
  final filter = ref.watch(activityFilterStateProvider);

  // Use our new Offline-First helper, and copy to a mutable list so we can sort it
  final rawHistory = await _fetchOfflineFirstHistory(ref);
  final allHistory = List<ReadingProgress>.from(rawHistory);

  // Detect Completed Books
  final bookCompletionTimes = <int, DateTime>{};

  // Group history by book to check completion status
  final historyByBook = groupBy(allHistory, (p) => p.bookId);

  for (final entry in historyByBook.entries) {
    final bookId = entry.key;
    final progressList = entry.value;

    // Find the book definition to get total chapters
    final book = kBibleBooks.firstWhere(
      (b) => b.id == bookId,
      orElse: () => kBibleBooks.first,
    );

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
  allHistory.sort(
    (a, b) => (b.readAt ?? DateTime(0)).compareTo(a.readAt ?? DateTime(0)),
  );

  final groups = <ActivityGroup>[];

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

    final book = kBibleBooks.firstWhereOrNull((b) => b.id == entry.bookId);
    if (book == null) {
      // Skip this orphan entry gracefully to prevent crashing
      continue;
    }

    // Check finishing
    var isFinisher = false;
    if (bookCompletionTimes.containsKey(book.id)) {
      final finishTime = bookCompletionTimes[book.id];
      if (entry.readAt!.isAtSameMomentAs(finishTime!)) {
        isFinisher = true;
      }
    }

    // Smart Grouping - same book, within 2 minutes = same session
    if (groups.isNotEmpty) {
      final lastGroup = groups.last;
      final timeDiff =
          lastGroup.timestamp.difference(entry.readAt!).inMinutes.abs();
      if (lastGroup.book.id == book.id &&
          lastGroup.timestamp.day == entry.readAt!.day &&
          timeDiff < 2) {
        lastGroup.chapters.add(entry.chapterNumber);
        if (isFinisher) lastGroup.isFinish = true;
        if (lastGroup.chapters.length > 5) {
          lastGroup.isBulkAction = true;
        }
        continue;
      }
    }

    groups.add(
      ActivityGroup(
        timestamp: entry.readAt!,
        book: book,
        chapters: [entry.chapterNumber],
        isFinish: isFinisher,
      ),
    );
  }

  // Group by Date for Sticky Headers
  final grouped = <DateTime, List<ActivityGroup>>{};
  for (final g in groups) {
    final dateKey =
        DateTime(g.timestamp.year, g.timestamp.month, g.timestamp.day);
    grouped.putIfAbsent(dateKey, () => []).add(g);
  }

  return grouped;
}

// Helper: Books that have activity (for filter dropdown)

@riverpod
Future<List<BibleBook>> booksWithActivity(Ref ref) async {
  // Use our new Offline-First helper so the dropdown works offline!
  final allHistory = await _fetchOfflineFirstHistory(ref);
  final bookIds = allHistory.map((p) => p.bookId).toSet();

  return kBibleBooks.where((b) => bookIds.contains(b.id)).toList();
}
