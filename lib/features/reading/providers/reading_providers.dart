import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso/core/services/offline_cache_service.dart';
import 'package:verso/data/bible_data.dart';
import 'package:verso/data/local/app_database.dart';
import 'package:verso/data/local/entities/reading_progress.dart';
import 'package:verso/features/auth/providers/auth_providers.dart';
import 'package:verso/features/reading/data/bible_repository.dart';
import 'package:verso/features/settings/providers/settings_providers.dart';

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
  ref.onDispose(db.close);
  return db;
}

/// Alias for compatibility
final AppDatabaseProvider localDatabaseProvider = appDatabaseProvider;

@Riverpod(keepAlive: true)
OfflineCacheService offlineCacheService(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return OfflineCacheService(db);
}

// GLOBAL PROGRESS STREAM (The Engine) — Offline-first with rubber-band prevention
//
// 1. Emits cached data instantly on startup. If cache is empty, fetches a snapshot.
// 2. Hydrates from Supabase Realtime stream, merging pending writes on top
// 3. Persists each update back to cache
// 4. Falls back to cache if the live stream errors (e.g. connection drop)
@Riverpod(keepAlive: true)
Stream<List<ReadingProgress>> globalProgress(Ref ref) async* {
  final repo = ref.watch(bibleRepositoryProvider);
  final cache = ref.watch(offlineCacheServiceProvider);

  // Watch the auth state so this provider rebuilds automatically on login/logout
  final authUser = ref.watch(authUserProvider).value;
  final userId = authUser?.id ?? '';

  // Emit cached data first for instant UI
  var cached = await cache.getCachedProgress();

  if (cached.isEmpty && userId.isNotEmpty) {
    // Cache was cleared, or brand new install.
    // Fetch a true snapshot from the server to prevent the UI from flickering to 0.
    try {
      cached = await repo.getAllProgressSnapshot();
      await cache.cacheProgress(cached);
    } catch (e) {
      // If we have no cache AND we can't reach the server, we must throw.
      // Yielding an empty list would make the UI display fake 0s.
      throw Exception(
        'Cannot load your reading progress. Please check your connection.',
      );
    }
  }

  // Yield the initial true state so the UI never flashes 0s
  yield cached;

  // Then hydrate from the live Supabase stream.
  // We skip(1) because the stream typically emits an empty list [] or a duplicate
  // snapshot immediately upon subscription before real-time changes come in.
  try {
    await for (final data in repo.getAllProgressStream().skip(1)) {
      // Merge pending queue writes on top of server data so the UI
      // doesn't "rubber-band" back to unread before sync completes.
      final queue = await cache.getWriteQueue();
      final merged = cache.mergeWithPendingWrites(data, queue, userId);

      // Persist the merged result to cache for next offline session
      await cache.cacheProgress(merged);
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

@riverpod
List<BibleBook> activeCanonBooks(Ref ref) {
  // 1. Watch your user settings provider
  final settingsAsync = ref.watch(userSettingsProvider);

  // 2. Extract the canon string safely
  final canonString = settingsAsync.value?.canonType ?? 'catholic';

  // 3. Convert string to enum
  final canonType = CanonType.values.firstWhere(
    (e) => e.name == canonString,
    orElse: () => CanonType.catholic,
  );

  // 4. Return the correct blueprint
  return BibleData.getBooksForCanon(canonType);
}
