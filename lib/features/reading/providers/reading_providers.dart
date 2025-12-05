import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/bible_repository.dart';
import '../../../data/local/entities/reading_progress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'reading_providers.g.dart';

final biblePageTriggerProvider = StateProvider<int>((ref) => 0);

// Provide the Repository
@Riverpod(keepAlive: true)
BibleRepository bibleRepository(Ref ref) {
  return BibleRepository(Supabase.instance.client);
}

// GLOBAL PROGRESS STREAM (The Engine)
// keepAlive: true ensures this stream stays open even when you scroll or change tabs.
// This fetches data ONCE for the entire app.
@Riverpod(keepAlive: true)
Stream<List<ReadingProgress>> globalProgress(Ref ref) {
  final repo = ref.watch(bibleRepositoryProvider);
  return repo.getAllProgressStream();
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
    loading: () => const Stream.empty(), // Don't emit anything while loading
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