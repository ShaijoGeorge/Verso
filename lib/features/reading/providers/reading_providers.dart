import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/bible_repository.dart';
import '../../../data/local/entities/reading_progress.dart';

part 'reading_providers.g.dart';

// 1. Provide the Repository
// REMOVED: databaseServiceProvider
@Riverpod(keepAlive: true)
BibleRepository bibleRepository(Ref ref) {
  // Just pass the Supabase client
  return BibleRepository(Supabase.instance.client);
}

// 2. Realtime Read Count for a specific Book
@riverpod
Stream<int> bookReadCount(Ref ref, int bookId) {
  final repo = ref.watch(bibleRepositoryProvider);
  
  return repo.getBookProgressStream(bookId).map((list) {
    return list.where((p) => p.isRead).length;
  });
}

// 3. Realtime Reading Progress for a specific Book
@riverpod
Stream<List<ReadingProgress>> bookProgress(Ref ref, int bookId) { 
  final repo = ref.watch(bibleRepositoryProvider);
  return repo.getBookProgressStream(bookId);
}