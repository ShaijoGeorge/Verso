import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../reading/providers/reading_providers.dart';
import '../../../data/bible_data.dart';
import '../data/verse_repository.dart';

part 'home_providers.g.dart';

/// Info about a book the user was most recently reading (and hasn't finished).
class ContinueReadingInfo {
  final BibleBook book;
  final int chaptersRead;
  final int lastChapter;

  ContinueReadingInfo({
    required this.book,
    required this.chaptersRead,
    required this.lastChapter,
  });

  double get progress => chaptersRead / book.chapters;
}

/// Returns the most recently read book that isn't fully completed,
/// so the user can quickly jump back in.
@riverpod
Future<ContinueReadingInfo?> continueReading(Ref ref) async {
  final history = await ref.watch(globalProgressProvider.future);
  final readHistory =
      history.where((p) => p.isRead && p.readAt != null).toList();

  if (readHistory.isEmpty) return null;

  // Sort by readAt descending to find most recent
  readHistory.sort((a, b) => b.readAt!.compareTo(a.readAt!));

  // Build a map of chapters read per book
  final Map<int, Set<int>> readChaptersByBook = {};
  for (final p in readHistory) {
    readChaptersByBook.putIfAbsent(p.bookId, () => <int>{});
    readChaptersByBook[p.bookId]!.add(p.chapterNumber);
  }

  // Find the most recently read book that is NOT fully completed
  for (final p in readHistory) {
    final book = kBibleBooks.firstWhere((b) => b.id == p.bookId);
    final readCount = readChaptersByBook[p.bookId]?.length ?? 0;
    if (readCount < book.chapters) {
      return ContinueReadingInfo(
        book: book,
        chaptersRead: readCount,
        lastChapter: p.chapterNumber,
      );
    }
  }

  // All books the user has touched are completed — no "continue" suggestion
  return null;
}

/// Number of chapters read today.
@riverpod
Future<int> todayChapters(Ref ref) async {
  final history = await ref.watch(globalProgressProvider.future);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return history.where((p) {
    if (!p.isRead || p.readAt == null) return false;
    final d = p.readAt!;
    return d.year == today.year && d.month == today.month && d.day == today.day;
  }).length;
}

/// Returns the user's first name from Supabase auth metadata.
@riverpod
String userName(Ref ref) {
  final user = Supabase.instance.client.auth.currentUser;
  final fullName = user?.userMetadata?['full_name'] as String? ?? '';
  if (fullName.isEmpty) return 'Reader';
  // Return first name only
  return fullName.split(' ').first;
}

/// Time-based greeting string.
String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 5) return 'Good night';
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

/// Motivational subtitle based on streak / progress.
String getMotivationalMessage(int streak, double progress, int todayCount) {
  if (todayCount > 0) {
    return "You've read $todayCount chapter${todayCount == 1 ? '' : 's'} today. Keep going!";
  }
  if (streak > 7) {
    return '$streak day streak! Incredible discipline.';
  }
  if (streak > 0) {
    return "$streak day streak — don't break it!";
  }
  if (progress > 50) {
    return "You're past the halfway mark!";
  }
  return 'Open the Word and start your day.';
}

// Access to the repository for fetching verse data.
// Kept alive to reuse the repository instance across the app.
@Riverpod(keepAlive: true)
VerseRepository verseRepository(Ref ref) {
  return VerseRepository(Supabase.instance.client);
}

// Fetches the daily Scripture verse to display on the home screen.
@riverpod
Future<Map<String, dynamic>> dailyVerse(Ref ref) async {
  final repo = ref.watch(verseRepositoryProvider);
  return repo.getTodayVerse();
}
