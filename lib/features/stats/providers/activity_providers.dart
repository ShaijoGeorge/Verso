import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../reading/providers/reading_providers.dart';
import '../../../data/bible_data.dart';
import '../../../data/local/entities/reading_progress.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activity_providers.g.dart';

// The Model for "Smart" Log
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
      if (chapters[i+1] != chapters[i] + 1) isConsecutive = false;
    }

    if (isConsecutive) {
      return 'Read Chapters ${chapters.first} - ${chapters.last}';
    }
    return 'Read Chapters ${chapters.join(", ")}';
  }
}

// The Provider to Generate the Log
@riverpod
Future<List<ActivityGroup>> activityLog(Ref ref) async {
  // Fetch ALL raw history (read only)
  final allHistory = await ref.watch(bibleRepositoryProvider).getAllProgressSnapshot();
  
  // Sort by Time DESC (Newest first)
  allHistory.sort((a, b) => (b.readAt ?? DateTime(0)).compareTo(a.readAt ?? DateTime(0)));

  final List<ActivityGroup> groups = [];

  // 3. Smart Grouping Logic
  // We will group entries if they are:
  // - Same Book
  // - Within 1 minute of each other (implies a session or bulk action)
  
  for (final entry in allHistory) {
    if (entry.readAt == null) continue;

    final book = kBibleBooks.firstWhere((b) => b.id == entry.bookId);
    
    // Check if we can add to the most recent group
    if (groups.isNotEmpty) {
      final lastGroup = groups.last;
      final timeDiff = lastGroup.timestamp.difference(entry.readAt!).inMinutes.abs();

      if (lastGroup.book.id == book.id && timeDiff < 2) {
        // It's the same session! Add to existing group.
        lastGroup.chapters.add(entry.chapterNumber);
        continue; // Skip creating a new group
      }
    }

    // Create a new group
    groups.add(ActivityGroup(
      timestamp: entry.readAt!,
      book: book,
      chapters: [entry.chapterNumber],
      // If we eventually group > 10 chapters in one go, we flag it as bulk in UI
    ));
  }

  return groups;
}