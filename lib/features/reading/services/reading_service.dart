import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/bible_repository.dart';
import '../providers/reading_providers.dart';
import '../../stats/providers/stats_providers.dart';

part 'reading_service.g.dart';

class ReadingService {
  final Ref _ref;
  final BibleRepository _repo;

  ReadingService(this._ref, this._repo);

  Future<void> toggleChapter(int bookId, int chapterNumber, bool isRead) async {
    await _repo.toggleChapter(bookId, chapterNumber, isRead);
    
    // Invalidation Cascade
    _ref.invalidate(userStatsProvider);
    _ref.invalidate(detailedStatsProvider);
    
    // Also invalidate book-specific counts for immediate UI update
    _ref.invalidate(bookReadCountProvider(bookId));
  }

  Future<void> markBookAsRead(int bookId, int totalChapters) async {
    await _repo.markBookAsRead(bookId, totalChapters);
    
    // Invalidation Cascade
    _ref.invalidate(userStatsProvider);
    _ref.invalidate(detailedStatsProvider);
    
    // Book-specific
    _ref.invalidate(bookReadCountProvider(bookId));
    _ref.invalidate(bookProgressProvider(bookId));
  }
}

@Riverpod(keepAlive: true)
ReadingService readingService(Ref ref) {
  final repo = ref.watch(bibleRepositoryProvider);
  return ReadingService(ref, repo);
}
