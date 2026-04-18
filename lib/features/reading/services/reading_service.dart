import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso/core/providers/connectivity_provider.dart';
import 'package:verso/core/services/offline_cache_service.dart';
import 'package:verso/features/reading/data/bible_repository.dart';
import 'package:verso/features/reading/providers/reading_providers.dart';
import 'package:verso/features/stats/providers/stats_providers.dart';

part 'reading_service.g.dart';

class ReadingService {
  ReadingService(this._ref, this._repo, this._cache);
  final Ref _ref;
  final BibleRepository _repo;
  final OfflineCacheService _cache;

  // Mutex to prevent multiple sync loops from running concurrently
  bool _isSyncing = false;

  // Debounce timer so rapid taps coalesce into one provider refresh
  Timer? _refreshTimer;

  bool get _isOnline => _ref.read(connectivityProvider);
  String get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  Future<void> toggleChapter(int bookId, int chapterNumber, bool isRead) async {
    // 1. ALWAYS queue the action (chronologically ordered source of truth)
    await _cache.enqueueWrite({
      'type': 'toggle',
      'book_id': bookId,
      'chapter_number': chapterNumber,
      'is_read': isRead,
    });

    // 2. ALWAYS update local cache immediately (instant optimistic UI)
    await _cache.applyCachedToggle(
      _currentUserId,
      bookId,
      chapterNumber,
      isRead,
    );

    // 3. Schedule a debounced provider refresh — rapid taps won't
    //    restart the stream on every single toggle.
    _scheduleRefresh();

    // 4. Trigger background sync if online
    _triggerSync();
  }

  Future<void> markBookAsRead(int bookId, int totalChapters) async {
    await _cache.enqueueWrite({
      'type': 'mark_book',
      'book_id': bookId,
      'total_chapters': totalChapters,
    });

    await _cache.applyCachedMarkBook(
      _currentUserId,
      bookId,
      totalChapters,
    );

    // Mark-all is a single action, refresh immediately
    _invalidateProviders();
    _triggerSync();
  }

  void _scheduleRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer =
        Timer(const Duration(milliseconds: 350), _invalidateProviders);
  }

  void _invalidateProviders() {
    _ref.invalidate(globalProgressProvider);
    _ref.invalidate(userStatsProvider);
    _ref.invalidate(detailedStatsProvider);
  }

  void _triggerSync() {
    if (_isOnline) {
      flushWriteQueue();
    }
  }

  /// Flush all queued writes to Supabase in FIFO order.
  /// Uses a mutex to prevent overlapping syncs from racing.
  /// Network errors stop the flush (retried on next connectivity event);
  /// data errors drop the malformed action so the queue isn't blocked.
  Future<void> flushWriteQueue() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
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
            case 'mark_book':
              await _repo.markBookAsRead(
                op['book_id'] as int,
                op['total_chapters'] as int,
              );
          }
          await _cache.removeQueueAction(0);
        } on TypeError catch (_) {
          // Malformed data — drop it so the queue isn't permanently blocked
          await _cache.removeQueueAction(0);
        } catch (_) {
          // Network error — stop flush; will retry on next connectivity event
          break;
        }
      }
    } finally {
      _isSyncing = false;
      // No invalidation here — the Supabase realtime stream already pushes
      // the confirmed state, and the cache was updated in _invalidateProviders.
      // A second invalidation here caused the chapter grid to blink.
    }
  }
}

@Riverpod(keepAlive: true)
ReadingService readingService(Ref ref) {
  final repo = ref.watch(bibleRepositoryProvider);
  final cache = ref.watch(offlineCacheServiceProvider);
  final service = ReadingService(ref, repo, cache);

  // Watch connectivity — flush queue when coming back online
  ref.listen(connectivityProvider, (previous, next) {
    if (previous == false && next) {
      service.flushWriteQueue();
    }
  });

  // Flush any queued writes left over from a previous offline session.
  // This covers the case where the app was closed offline and reopened online
  // (the listener above won't fire because there's no false → true transition).
  if (ref.read(connectivityProvider)) {
    Future.microtask(service.flushWriteQueue);
  }

  return service;
}
