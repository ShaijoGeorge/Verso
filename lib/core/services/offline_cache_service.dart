import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/local/entities/reading_progress.dart';

class OfflineCacheService {
  static const _progressCacheKey = 'cached_reading_progress';
  static const _writeQueueKey = 'offline_write_queue';

  /// Mutex to serialize read-modify-write operations on SharedPreferences,
  /// preventing rapid-fire taps from racing and overwriting each other.
  final _lock = _AsyncLock();

  // --- Read Cache ---

  Future<List<ReadingProgress>> getCachedProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_progressCacheKey);
    if (jsonString == null) return [];

    final List<dynamic> decoded = json.decode(jsonString);
    return decoded
        .map((e) => ReadingProgress.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> cacheProgress(List<ReadingProgress> progress) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(progress.map((p) => p.toJson()).toList());
    await prefs.setString(_progressCacheKey, jsonString);
  }

  // --- Write Queue ---

  Future<List<Map<String, dynamic>>> getWriteQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_writeQueueKey);
    if (jsonString == null) return [];

    final List<dynamic> decoded = json.decode(jsonString);
    return decoded.cast<Map<String, dynamic>>();
  }

  /// Enqueue a write operation, deduplicating toggle actions for the same chapter.
  Future<void> enqueueWrite(Map<String, dynamic> operation) async {
    await _lock.run(() async {
      final queue = await getWriteQueue();

      // Deduplicate: if toggling the same chapter, replace the old entry
      if (operation['type'] == 'toggle') {
        queue.removeWhere((op) =>
            op['type'] == 'toggle' &&
            op['book_id'] == operation['book_id'] &&
            op['chapter_number'] == operation['chapter_number']);
      }

      queue.add(operation);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_writeQueueKey, json.encode(queue));
    });
  }

  /// Remove a single action from the queue by index after successful sync.
  Future<void> removeQueueAction(int index) async {
    await _lock.run(() async {
      final queue = await getWriteQueue();
      if (index < queue.length) {
        queue.removeAt(index);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_writeQueueKey, json.encode(queue));
    });
  }

  Future<void> clearWriteQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_writeQueueKey);
  }

  /// Clear all cached data and queued writes (used on logout).
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressCacheKey);
    await prefs.remove(_writeQueueKey);
  }

  /// Apply a toggle operation to the cached progress optimistically.
  Future<void> applyCachedToggle(
    String userId,
    int bookId,
    int chapterNumber,
    bool isRead,
  ) async {
    await _lock.run(() async {
      final progress = await getCachedProgress();

      // Remove existing entry for this chapter
      progress.removeWhere(
        (p) => p.bookId == bookId && p.chapterNumber == chapterNumber,
      );

      // Add updated entry
      if (isRead) {
        progress.add(ReadingProgress(
          userId: userId,
          bookId: bookId,
          chapterNumber: chapterNumber,
          isRead: true,
          readAt: DateTime.now(),
        ));
      }

      await cacheProgress(progress);
    });
  }

  /// Apply a "mark book as read" operation to the cached progress optimistically.
  Future<void> applyCachedMarkBook(
    String userId,
    int bookId,
    int totalChapters,
  ) async {
    await _lock.run(() async {
      final progress = await getCachedProgress();

      // Find chapters already read for this book
      final existingChapters = progress
          .where((p) => p.bookId == bookId && p.isRead)
          .map((p) => p.chapterNumber)
          .toSet();

      // Add missing chapters
      final now = DateTime.now();
      for (int i = 1; i <= totalChapters; i++) {
        if (!existingChapters.contains(i)) {
          progress.add(ReadingProgress(
            userId: userId,
            bookId: bookId,
            chapterNumber: i,
            isRead: true,
            readAt: now,
          ));
        }
      }

      await cacheProgress(progress);
    });
  }

  /// Merge pending queue writes on top of server data so the UI doesn't
  /// "rubber-band" back to unread before the sync completes.
  List<ReadingProgress> mergeWithPendingWrites(
    List<ReadingProgress> serverData,
    List<Map<String, dynamic>> queue,
    String userId,
  ) {
    if (queue.isEmpty) return serverData;

    // Start with server data as a mutable map keyed by (bookId, chapterNumber)
    final merged = <(int, int), ReadingProgress>{};
    for (final p in serverData) {
      merged[(p.bookId, p.chapterNumber)] = p;
    }

    // Overlay pending writes
    for (final op in queue) {
      switch (op['type']) {
        case 'toggle':
          final bookId = op['book_id'] as int;
          final chapter = op['chapter_number'] as int;
          final isRead = op['is_read'] as bool;
          if (isRead) {
            merged[(bookId, chapter)] = ReadingProgress(
              userId: userId,
              bookId: bookId,
              chapterNumber: chapter,
              isRead: true,
              readAt: DateTime.now(),
            );
          } else {
            merged.remove((bookId, chapter));
          }
          break;
        case 'mark_book':
          final bookId = op['book_id'] as int;
          final totalChapters = op['total_chapters'] as int;
          final now = DateTime.now();
          for (int i = 1; i <= totalChapters; i++) {
            merged[(bookId, i)] = ReadingProgress(
              userId: userId,
              bookId: bookId,
              chapterNumber: i,
              isRead: true,
              readAt: now,
            );
          }
          break;
      }
    }

    return merged.values.toList();
  }
}

/// Simple async mutex to prevent concurrent read-modify-write races.
class _AsyncLock {
  Future<void>? _last;

  Future<T> run<T>(Future<T> Function() action) {
    final prev = _last;
    final completer = Completer<void>();
    _last = completer.future;

    return Future(() async {
      if (prev != null) await prev;
      try {
        return await action();
      } finally {
        completer.complete();
      }
    });
  }
}
