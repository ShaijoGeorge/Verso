import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/bible_repository.dart';
import '../providers/reading_providers.dart';
import '../../stats/providers/stats_providers.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../../../core/services/offline_cache_service.dart';

part 'reading_service.g.dart';

class ReadingService {
  final Ref _ref;
  final BibleRepository _repo;
  final OfflineCacheService _cache;

  ReadingService(this._ref, this._repo, this._cache);

  bool get _isOnline => _ref.read(connectivityProvider);
  String get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  Future<void> toggleChapter(int bookId, int chapterNumber, bool isRead) async {
    if (_isOnline) {
      await _repo.toggleChapter(bookId, chapterNumber, isRead);
    } else {
      // Queue the write for later (deduplicates same-chapter toggles)
      await _cache.enqueueWrite({
        'type': 'toggle',
        'book_id': bookId,
        'chapter_number': chapterNumber,
        'is_read': isRead,
      });
      // Optimistically update the local cache
      await _cache.applyCachedToggle(
        _currentUserId,
        bookId,
        chapterNumber,
        isRead,
      );
      // Refresh the global stream from cache
      _ref.invalidate(globalProgressProvider);
    }

    // Invalidation Cascade
    _ref.invalidate(userStatsProvider);
    _ref.invalidate(detailedStatsProvider);
    _ref.invalidate(bookReadCountProvider(bookId));
  }

  Future<void> markBookAsRead(int bookId, int totalChapters) async {
    if (_isOnline) {
      await _repo.markBookAsRead(bookId, totalChapters);
    } else {
      // Queue the write for later
      await _cache.enqueueWrite({
        'type': 'mark_book',
        'book_id': bookId,
        'total_chapters': totalChapters,
      });
      // Optimistically update the local cache
      await _cache.applyCachedMarkBook(
        _currentUserId,
        bookId,
        totalChapters,
      );
      // Refresh the global stream from cache
      _ref.invalidate(globalProgressProvider);
    }

    // Invalidation Cascade
    _ref.invalidate(userStatsProvider);
    _ref.invalidate(detailedStatsProvider);
    _ref.invalidate(bookReadCountProvider(bookId));
    _ref.invalidate(bookProgressProvider(bookId));
  }

  /// Flush all queued offline writes to Supabase.
  /// Processes one-at-a-time: network errors stop the flush (retried next
  /// connectivity event); data errors drop the malformed action so the
  /// queue doesn't get permanently blocked.
  Future<void> flushWriteQueue() async {
    final queue = await _cache.getWriteQueue();
    if (queue.isEmpty) return;

    // Process from index 0 and remove each after success.
    // We re-read the queue length each iteration because removeQueueAction
    // mutates the underlying store.
    while (true) {
      final current = await _cache.getWriteQueue();
      if (current.isEmpty) break;

      final op = current.first;
      try {
        switch (op['type']) {
          case 'toggle':
            await _repo.toggleChapter(
              op['book_id'] as int,
              op['chapter_number'] as int,
              op['is_read'] as bool,
            );
            break;
          case 'mark_book':
            await _repo.markBookAsRead(
              op['book_id'] as int,
              op['total_chapters'] as int,
            );
            break;
        }
        // Success — remove this action from the queue
        await _cache.removeQueueAction(0);
      } on TypeError catch (_) {
        // Malformed data — drop it so the queue isn't permanently blocked
        await _cache.removeQueueAction(0);
      } catch (_) {
        // Network error — stop flush; will retry on next connectivity event
        break;
      }
    }

    // Refresh everything after sync
    _ref.invalidate(globalProgressProvider);
    _ref.invalidate(userStatsProvider);
    _ref.invalidate(detailedStatsProvider);
  }
}

@Riverpod(keepAlive: true)
ReadingService readingService(Ref ref) {
  final repo = ref.watch(bibleRepositoryProvider);
  final cache = ref.watch(offlineCacheServiceProvider);
  final service = ReadingService(ref, repo, cache);

  // Watch connectivity — flush queue when coming back online
  ref.listen(connectivityProvider, (previous, next) {
    if (previous == false && next == true) {
      service.flushWriteQueue();
    }
  });

  // Flush any queued writes left over from a previous offline session.
  // This covers the case where the app was closed offline and reopened online
  // (the listener above won't fire because there's no false → true transition).
  if (ref.read(connectivityProvider)) {
    Future.microtask(() => service.flushWriteQueue());
  }

  return service;
}
