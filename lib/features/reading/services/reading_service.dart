import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso/core/providers/connectivity_provider.dart';
import 'package:verso/core/services/offline_cache_service.dart';
import 'package:verso/data/local/entities/reading_progress.dart';
import 'package:verso/features/reading/data/bible_repository.dart';
import 'package:verso/features/reading/providers/reading_providers.dart';
import 'package:verso/features/settings/providers/settings_providers.dart';
import 'package:verso/features/stats/providers/stats_providers.dart';

part 'reading_service.g.dart';

class ReadingService {
  ReadingService(this._ref, this._repo, this._cache);
  final Ref _ref;
  final BibleRepository _repo;
  final OfflineCacheService _cache;

  // Mutex to prevent multiple sync loops from running concurrently
  bool _isSyncing = false;

  // Cooldown tracker to prevent rapid redundant sync calls
  DateTime? _lastSyncTime;

  // Debounce timer so rapid taps coalesce into one provider refresh
  Timer? _refreshTimer;

  bool get _isOnline => _ref.read(connectivityProvider);
  String get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  Future<int?> toggleChapter(int bookId, int chapterNumber, bool isRead) async {
    final streak = isRead ? await _checkAndMarkFirstReadToday() : null;

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

    return streak;
  }

  Future<int?> markBookAsRead(int bookId, int totalChapters) async {
    final streak = await _checkAndMarkFirstReadToday();

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

    return streak;
  }

  /// Determines if this is the user's first read of today.
  ///
  /// Returns the updated streak number (>= 1) if this action is the first read today,
  /// or `null` if the user has already read or celebrated today.
  Future<int?> _checkAndMarkFirstReadToday() async {
    final uid = _currentUserId;
    if (uid.isEmpty) return null;

    final now = DateTime.now();
    final todayString = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    final settingsRepo = _ref.read(settingsRepositoryProvider);
    final lastCelebrated = await settingsRepo.getLastCelebratedReadDate(uid);

    // 1. If today was already celebrated on this device, don't celebrate again
    if (lastCelebrated == todayString) {
      return null;
    }

    // 2. Check if user already has read records for today in local cache
    final cached = await _cache.getCachedProgress();
    final todayDate = DateTime(now.year, now.month, now.day);

    final alreadyReadToday = cached.any((p) {
      if (!p.isRead || p.readAt == null || p.userId != uid) return false;
      final local = p.readAt!.toLocal();
      final readDate = DateTime(local.year, local.month, local.day);
      return readDate == todayDate;
    });

    if (alreadyReadToday) {
      // User already read today (e.g. synced before opening); sync date marker
      await settingsRepo.setLastCelebratedReadDate(uid, todayString);
      return null;
    }

    // 3. Genuine first read of the day!
    // Compute the new streak count including today's read
    final simulatedTodayRecord = ReadingProgress(
      userId: uid,
      bookId: 0,
      chapterNumber: 0,
      isRead: true,
      readAt: now,
    );
    final updatedStreak = calculateStreak([...cached, simulatedTodayRecord]);

    await settingsRepo.setLastCelebratedReadDate(uid, todayString);
    return updatedStreak > 0 ? updatedStreak : 1;
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

  /// Internal helper to flush queued writes in FIFO order.
  /// Returns `true` if all items were processed or dropped, `false` on network error.
  Future<bool> _flushQueueInternal() async {
    while (true) {
      final current = await _cache.getWriteQueue();
      if (current.isEmpty) return true;

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
        // Network error — stop flush; will retry on next connectivity/resume event
        return false;
      }
    }
  }

  /// Flush all queued writes to Supabase in FIFO order.
  /// Uses a mutex to prevent overlapping syncs from racing.
  Future<void> flushWriteQueue() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      await _flushQueueInternal();
    } finally {
      _isSyncing = false;
    }
  }

  /// Reconciles local data with Supabase when app resumes from background
  /// or when internet connectivity is restored.
  ///
  /// 1. Flushes pending offline writes to Supabase.
  /// 2. Fetches latest remote progress snapshot to catch up on cross-device changes.
  /// 3. Reconciles remote snapshot with any writes queued during fetch.
  /// 4. Atomically updates local Drift SQLite cache.
  /// 5. Invalidates providers so UI updates immediately and stream reconnects.
  Future<void> syncOnResume() async {
    final userId = _currentUserId;
    if (!_isOnline || userId.isEmpty) return;

    // Cooldown guard: Avoid repeated calls if user rapidly switches apps or toggles notification shade,
    // unless there are pending writes in the queue waiting to be synced.
    final now = DateTime.now();
    final queue = await _cache.getWriteQueue();
    if (queue.isEmpty &&
        _lastSyncTime != null &&
        now.difference(_lastSyncTime!) < const Duration(seconds: 5)) {
      return;
    }

    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final flushedSuccessfully = await _flushQueueInternal();
      if (!flushedSuccessfully) return;

      final remoteSnapshot = await _repo.getAllProgressSnapshot();
      final remainingQueue = await _cache.getWriteQueue();
      final merged = _cache.mergeWithPendingWrites(
        remoteSnapshot,
        remainingQueue,
        userId,
      );

      await _cache.cacheProgress(merged);
      _lastSyncTime = DateTime.now();
      _invalidateProviders();
    } catch (_) {
      // Gracefully ignore network errors on resume so app stays on local cache
    } finally {
      _isSyncing = false;
    }
  }
}

@Riverpod(keepAlive: true)
ReadingService readingService(Ref ref) {
  final repo = ref.watch(bibleRepositoryProvider);
  final cache = ref.watch(offlineCacheServiceProvider);
  final service = ReadingService(ref, repo, cache);

  // Watch connectivity — sync when coming back online
  ref.listen(connectivityProvider, (previous, next) {
    if (previous == false && next) {
      service.syncOnResume();
    }
  });

  // Flush any queued writes or sync on fresh start
  if (ref.read(connectivityProvider)) {
    Future.microtask(service.syncOnResume);
  }

  return service;
}
