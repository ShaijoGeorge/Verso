import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/bible_repository.dart';
import '../../../data/local/entities/reading_progress.dart';
import '../../../data/local/app_database.dart';
import '../../../core/services/offline_cache_service.dart';

part 'reading_providers.g.dart';

@riverpod
class BiblePageTrigger extends _$BiblePageTrigger {
  @override
  int build() => 0;

  void increment() => state++;
}

// Provide the Repository
@Riverpod(keepAlive: true)
BibleRepository bibleRepository(Ref ref) {
  return BibleRepository(Supabase.instance.client);
}

// Single database instance shared across the app
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
}

@Riverpod(keepAlive: true)
OfflineCacheService offlineCacheService(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return OfflineCacheService(db);
}

// GLOBAL PROGRESS STREAM (The Engine) — Offline-first with rubber-band prevention
//
// 1. Emits cached data instantly on startup
// 2. Hydrates from Supabase Realtime stream, merging pending writes on top
// 3. Persists each update back to cache
// 4. Falls back to cache if the live stream errors (e.g. connection drop)
@Riverpod(keepAlive: true)
Stream<List<ReadingProgress>> globalProgress(Ref ref) async* {
  final repo = ref.watch(bibleRepositoryProvider);
  final cache = ref.watch(offlineCacheServiceProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

  // Emit cached data first for instant UI
  final cached = await cache.getCachedProgress();
  if (cached.isNotEmpty) {
    yield cached;
  }

  // Then hydrate from the live Supabase stream.
  // If the stream errors (connection drop), fall back to cached data
  // so the UI never gets stuck in a loading/error state.
  try {
    await for (final data in repo.getAllProgressStream()) {
      // Merge pending queue writes on top of server data so the UI
      // doesn't "rubber-band" back to unread before sync completes.
      final queue = await cache.getWriteQueue();
      final merged = cache.mergeWithPendingWrites(data, queue, userId);

      // Persist the merged result to cache for next offline session
      cache.cacheProgress(merged);
      yield merged;
    }
  } catch (_) {
    // Connection lost — re-emit cache so derived providers stay alive
    final fallback = await cache.getCachedProgress();
    yield fallback;
  }
}

// Read Count for a specific Book (Derived instantly from global)
@riverpod
Stream<int> bookReadCount(Ref ref, int bookId) {
  // Watch the global stream. When it updates, this recalculates instantly.
  final allProgressAsync = ref.watch(globalProgressProvider);

  return allProgressAsync.when(
    data: (all) {
      final count = all.where((p) => p.bookId == bookId && p.isRead).length;
      return Stream.value(count);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
}

// Progress List for a specific Book (Derived instantly from global)
@riverpod
Stream<List<ReadingProgress>> bookProgress(Ref ref, int bookId) {
  final allProgressAsync = ref.watch(globalProgressProvider);

  return allProgressAsync.when(
    data: (all) {
      final bookData = all.where((p) => p.bookId == bookId).toList();
      return Stream.value(bookData);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
}
