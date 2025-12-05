import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/local/entities/reading_progress.dart';

class BibleRepository {
  final SupabaseClient _supabase;

  BibleRepository(this._supabase);

  String get _currentUserId => _supabase.auth.currentUser?.id ?? '';

  // 1. Get Realtime Stream for a specific Book
  // We stream the data and filter it in Dart to ensure compatibility
  Stream<List<ReadingProgress>> getBookProgressStream(int bookId) {
    final userId = _currentUserId;
    if (userId.isEmpty) return Stream.value([]);

    return _supabase
        .from('user_progress')
        .stream(primaryKey: ['user_id', 'book_id', 'chapter_number'])
        .map((data) {
          // Filter results locally to match the requested book and user
          return data
              .where((row) => row['user_id'] == userId && row['book_id'] == bookId)
              .map((json) => ReadingProgress.fromJson(json))
              .toList();
        });
  }

  // 2. Toggle Chapter (Writes directly to Cloud)
  Future<void> toggleChapter(int bookId, int chapterNumber, bool isRead) async {
    final userId = _currentUserId;
    if (userId.isEmpty) return;

    final now = DateTime.now();

    await _supabase.from('user_progress').upsert({
      'user_id': userId,
      'book_id': bookId,
      'chapter_number': chapterNumber,
      'is_read': isRead,
      'read_at': isRead ? now.toIso8601String() : null,
    }, onConflict: 'user_id,book_id,chapter_number');
  }

  // Mark Entire Book as Read (Smart Version)
  // Only inserts chapters that are NOT already marked as read.
  Future<void> markBookAsRead(int bookId, int totalChapters) async {
    final userId = _currentUserId;
    if (userId.isEmpty) return;

    final now = DateTime.now().toIso8601String();

    // Fetch which chapters are ALREADY read
    final existingData = await _supabase
        .from('user_progress')
        .select('chapter_number')
        .eq('user_id', userId)
        .eq('book_id', bookId);
    
    // Create a Set of existing IDs for fast lookup (e.g., {1, 2, 3, 4, 5})
    final existingChapters = (existingData as List)
        .map((e) => e['chapter_number'] as int)
        .toSet();

    // Generate list of ONLY the missing chapters
    final List<Map<String, dynamic>> newInserts = [];
    
    for (int i = 1; i <= totalChapters; i++) {
      if (!existingChapters.contains(i)) {
        newInserts.add({
          'user_id': userId,
          'book_id': bookId,
          'chapter_number': i,
          'is_read': true,
          'read_at': now,
        });
      }
    }

    // Insert only the new ones (Standard Insert, not Upsert)
    // This avoids "duplicate key" errors since we filtered them out manually.
    if (newInserts.isNotEmpty) {
      await _supabase.from('user_progress').insert(newInserts); 
    }
  }

  // 3. Count Total Read
  Future<int> countTotalRead() async {
    final userId = _currentUserId;
    if (userId.isEmpty) return 0;

    final response = await _supabase
        .from('user_progress')
        .count()
        .eq('user_id', userId)
        .eq('is_read', true);
    
    return response;
  }

  // 4. Calculate Streak
  Future<int> getCurrentStreak() async {
    final userId = _currentUserId;
    if (userId.isEmpty) return 0;

    // Fetch only the read dates
    final data = await _supabase
        .from('user_progress')
        .select('read_at')
        .eq('user_id', userId)
        .eq('is_read', true)
        .not('read_at', 'is', null)
        .order('read_at', ascending: false);

    if (data.isEmpty) return 0;

    final uniqueDays = (data as List)
        .map((row) => DateTime.parse(row['read_at']))
        .map((dt) => DateTime(dt.year, dt.month, dt.day)) 
        .toSet()
        .toList();

    if (uniqueDays.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (uniqueDays.first != today && uniqueDays.first != yesterday) {
      return 0;
    }

    int streak = 0;
    DateTime targetDate = uniqueDays.first;

    for (final day in uniqueDays) {
      if (day == targetDate) {
        streak++;
        targetDate = targetDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  Future<List<ReadingProgress>> getAllProgressSnapshot() async {
    final userId = _currentUserId;
    if (userId.isEmpty) return [];

    final response = await _supabase
        .from('user_progress')
        .select()
        .eq('user_id', userId)
        .eq('is_read', true); // Only fetch what is actually read

    final data = response as List<dynamic>;
    return data.map((json) => ReadingProgress.fromJson(json)).toList();
  }
}