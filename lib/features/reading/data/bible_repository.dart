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
    }, onConflict: 'user_id, book_id, chapter_number');
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
}