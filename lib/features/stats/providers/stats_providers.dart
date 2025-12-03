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

// Note: Calculating aggregate stats (like total count of 1000+ chapters) 
// via Realtime Stream can be heavy. We keep this as a Future that refreshes
// when the user enters the screen.
@riverpod
Future<UserStats> userStats(Ref ref) async {
  final repo = ref.watch(bibleRepositoryProvider);

  // 1. Get Streak (Fetches from Cloud)
  final streak = await repo.getCurrentStreak();

  // 2. Get Total Read (Fetches from Cloud)
  final totalRead = await repo.countTotalRead();

  // 3. Calculate Percentage (Total Bible Chapters = 1189)
  const totalChaptersInBible = 1189;
  final progress = totalChaptersInBible > 0 
      ? (totalRead / totalChaptersInBible) * 100 
      : 0.0;

  return UserStats(
    streak: streak,
    totalChaptersRead: totalRead,
    totalProgress: progress,
  );
}

class DetailedStats {
  final int otChaptersRead;
  final int ntChaptersRead;
  final double otProgress; // 0.0 to 1.0
  final double ntProgress; // 0.0 to 1.0
  final int booksCompleted;
  final List<ReadingProgress> rawHistory;

  DetailedStats({
    required this.otChaptersRead,
    required this.ntChaptersRead,
    required this.otProgress,
    required this.ntProgress,
    required this.booksCompleted,
    required this.rawHistory,
  });
}

@riverpod
Future<DetailedStats> detailedStats(Ref ref) async {
  final repo = ref.watch(bibleRepositoryProvider);
  
  // 1. Fetch ALL reading progress (We need a new method in Repository or stream it)
  // For now, we will stream all progress using the existing stream method if feasible,
  // or better, fetch a snapshot since stats don't need 100% realtime for charts.
  // Note: ideally you add `getAllProgress()` to your repository.
  // Assuming we use the existing filtered stream logic, we might need a broader query.
  // Let's assume you add `Future<List<ReadingProgress>> getAllProgress()` to your repo.
  // For this example, I will mock the fetch call assuming you add it.
  
  final allProgress = await repo.getAllProgressSnapshot(); 

  // 2. Constants (Standard Protestant Bible)
  const int totalOTChapters = 929;
  const int totalNTChapters = 260;
  
  // 3. Filter Data
  // OT is usually Book ID 1-39, NT is 40-66
  final otRead = allProgress.where((p) => p.bookId <= 39 && p.isRead).length;
  final ntRead = allProgress.where((p) => p.bookId >= 40 && p.isRead).length;

  // 4. Calculate Books Completed
  // This is tricky without knowing total chapters per book dynamically.
  // We will just count chapters for now.
  
  return DetailedStats(
    otChaptersRead: otRead,
    ntChaptersRead: ntRead,
    otProgress: otRead / totalOTChapters,
    ntProgress: ntRead / totalNTChapters,
    booksCompleted: 0, // Placeholder until complex logic is added
    rawHistory: allProgress,
  );
}