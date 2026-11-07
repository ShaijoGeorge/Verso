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
  ref.watch(authUserProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id ??
      ref.watch(authUserProvider).value?.id ??
      '';

  if (userId.isEmpty) {
    yield [];
    return;
  }

  // 1. Emit cached data first if available (instant 0ms UI)
  var cached = await cache.getCachedProgress(userId);
  if (cached.isNotEmpty) {
    yield cached;
  }

  // 2. Fetch fresh snapshot from server to guarantee latest cross-device data
  try {
    final fresh = await repo.getAllProgressSnapshot();
    final queue = await cache.getWriteQueue();
    final merged = cache.mergeWithPendingWrites(fresh, queue, userId);
    await cache.cacheProgress(merged, userId: userId);
    cached = merged;
    yield merged;
  } catch (e) {
    if (cached.isEmpty) {
      // If we have no local cache AND can't reach the server, throw so UI shows retry
      throw Exception(
        'Cannot load your reading progress. Please check your connection.',
      );
    }
  }

  // 3. Hydrate from the live Supabase stream for real-time changes
  try {
    await for (final data in repo.getAllProgressStream()) {
      // Avoid transient empty emission glitch if we already have verified cached data
      if (data.isEmpty && cached.isNotEmpty) {
        continue;
      }

      final queue = await cache.getWriteQueue();
      final merged = cache.mergeWithPendingWrites(data, queue, userId);

      await cache.cacheProgress(merged, userId: userId);
      cached = merged;
      yield merged;
    }
  } catch (_) {
    // Connection lost — re-emit cache so derived providers stay alive
    final fallback = await cache.getCachedProgress(userId);
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
