import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../reading/providers/reading_providers.dart';

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