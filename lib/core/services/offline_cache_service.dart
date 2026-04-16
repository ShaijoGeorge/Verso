import 'package:drift/drift.dart';
import '../../data/local/app_database.dart';
import '../../data/local/entities/reading_progress.dart';

class OfflineCacheService {
  final AppDatabase _db;

  OfflineCacheService(this._db);

  // --- Read Cache ---

  Future<List<ReadingProgress>> getCachedProgress() async {
    final rows = await _db.select(_db.cachedProgress).get();
    return rows.map(_rowToProgress).toList();
  }

  Future<void> cacheProgress(List<ReadingProgress> progress) async {
    // Replace the entire cache inside a single transaction so the
    // table is never in a half-written state.
    await _db.transaction(() async {
      await _db.delete(_db.cachedProgress).go();
      await _db.batch((batch) {
        batch.insertAll(
          _db.cachedProgress,
          progress.map((p) => CachedProgressCompanion.insert(
                userId: p.userId,
                bookId: p.bookId,
                chapterNumber: p.chapterNumber,
                isRead: Value(p.isRead),
                readAt: Value(p.readAt),
              )),
        );
      });
    });
  }

  // --- Write Queue ---

  Future<List<Map<String, dynamic>>> getWriteQueue() async {
    final rows = await (_db.select(_db.offlineWriteQueue)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();

    // Convert to the same Map format the rest of the app expects,
    // so ReadingService and mergeWithPendingWrites keep working.
    return rows.map((row) {
      final map = <String, dynamic>{
        'type': row.type,
        'book_id': row.bookId,
      };
      if (row.type == 'toggle') {
        map['chapter_number'] = row.chapterNumber;
        map['is_read'] = row.isRead;
      } else if (row.type == 'mark_book') {
        map['total_chapters'] = row.totalChapters;
      }
      return map;
    }).toList();
  }

  /// Enqueue a write operation, deduplicating toggle actions for the same chapter.
  Future<void> enqueueWrite(Map<String, dynamic> operation) async {
    await _db.transaction(() async {
      // Deduplicate: if toggling the same chapter, remove the old entry
      if (operation['type'] == 'toggle') {
        await (_db.delete(_db.offlineWriteQueue)
              ..where((t) =>
                  t.type.equals('toggle') &
                  t.bookId.equals(operation['book_id'] as int) &
                  t.chapterNumber.equals(operation['chapter_number'] as int)))
            .go();
      }

      await _db.into(_db.offlineWriteQueue).insert(
            OfflineWriteQueueCompanion.insert(
              type: operation['type'] as String,
              bookId: operation['book_id'] as int,
              chapterNumber: Value(operation['chapter_number'] as int?),
              isRead: Value(operation['is_read'] as bool?),
              totalChapters: Value(operation['total_chapters'] as int?),
            ),
          );
    });
  }

  /// Remove the first action from the queue after successful sync.
  Future<void> removeQueueAction(int index) async {
    // Grab the row with the lowest id (FIFO front).
    final front = await (_db.select(_db.offlineWriteQueue)
          ..orderBy([(t) => OrderingTerm.asc(t.id)])
          ..limit(1, offset: index))
        .getSingleOrNull();

    if (front != null) {
      await (_db.delete(_db.offlineWriteQueue)
            ..where((t) => t.id.equals(front.id)))
          .go();
    }
  }

  Future<void> clearWriteQueue() async {
    await _db.delete(_db.offlineWriteQueue).go();
  }

  /// Clear all cached data and queued writes (used on logout).
  Future<void> clearAll() async {
    await _db.transaction(() async {
      await _db.delete(_db.cachedProgress).go();
      await _db.delete(_db.offlineWriteQueue).go();
    });
  }

  /// Apply a toggle operation to the cached progress optimistically.
  Future<void> applyCachedToggle(
    String userId,
    int bookId,
    int chapterNumber,
    bool isRead,
  ) async {
    if (isRead) {
      // Upsert: insert or update the chapter as read
      await _db.into(_db.cachedProgress).insertOnConflictUpdate(
            CachedProgressCompanion.insert(
              userId: userId,
              bookId: bookId,
              chapterNumber: chapterNumber,
              isRead: const Value(true),
              readAt: Value(DateTime.now()),
            ),
          );
    } else {
      // Remove the chapter entry (marking as unread)
      await (_db.delete(_db.cachedProgress)
            ..where((t) =>
                t.bookId.equals(bookId) &
                t.chapterNumber.equals(chapterNumber)))
          .go();
    }
  }

  /// Apply a "mark book as read" operation to the cached progress optimistically.
  Future<void> applyCachedMarkBook(
    String userId,
    int bookId,
    int totalChapters,
  ) async {
    final now = DateTime.now();
    await _db.batch((batch) {
      for (int i = 1; i <= totalChapters; i++) {
        batch.insert(
          _db.cachedProgress,
          CachedProgressCompanion.insert(
            userId: userId,
            bookId: bookId,
            chapterNumber: i,
            isRead: const Value(true),
            readAt: Value(now),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
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

  // --- Helpers ---

  static ReadingProgress _rowToProgress(CachedProgressData row) {
    return ReadingProgress(
      userId: row.userId,
      bookId: row.bookId,
      chapterNumber: row.chapterNumber,
      isRead: row.isRead,
      readAt: row.readAt,
    );
  }
}
