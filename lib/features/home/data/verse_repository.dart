import 'dart:convert';
import 'dart:developer' as dev;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerseRepository {
  VerseRepository(this._supabase);
  final SupabaseClient _supabase;
  static const String _cacheKey = 'cached_daily_verses_v1';

  /// Called by the UI to get today's verse instantly.
  Future<Map<String, dynamic>> getTodayVerse() async {
    final todayDayOfYear = _getDayOfYear(DateTime.now());

    // 1. Instantly fetch our local offline stash
    final localVerses = await _getLocalVerses();

    // 2. Find today's verse
    Map<String, dynamic>? todayVerse;
    try {
      todayVerse = localVerses.firstWhere(
        (verse) =>
            (verse as Map<String, dynamic>)['day_of_year'] == todayDayOfYear,
      ) as Map<String, dynamic>;
    } catch (_) {
      // It's okay if it fails, todayVerse stays null
    }

    // 3. BACKGROUND CHECK: Are we running low on verses?
    final futureVersesCount = localVerses
        .where(
          (v) =>
              (v as Map<String, dynamic>)['day_of_year'] as int >=
              todayDayOfYear,
        )
        .length;

    if (futureVersesCount < 3) {
      if (todayVerse == null) {
        // We have no verse for today (e.g. cache cleared)! Await the fetch so the UI gets it instantly.
        await _fetchAndCacheNextBatch(todayDayOfYear);
        // Try reading from cache again
        final newVerses = await _getLocalVerses();
        try {
          todayVerse = newVerses.firstWhere(
            (verse) =>
                (verse as Map<String, dynamic>)['day_of_year'] ==
                todayDayOfYear,
          ) as Map<String, dynamic>;
        } catch (_) {}
      } else {
        // We have today's verse, but are running low. Fetch silently in the background.
        _fetchAndCacheNextBatch(todayDayOfYear).ignore();
      }
    }

    // 4. Return the verse, or throw if they are offline and the cache is completely empty
    if (todayVerse != null) {
      return {
        'text': todayVerse['text'],
        'ref': todayVerse['reference'],
      };
    } else {
      throw Exception('Unable to fetch the daily verse.');
    }
  }

  // --- PRIVATE HELPER METHODS ---

  Future<List<dynamic>> _getLocalVerses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKey);
    if (jsonString == null) return [];
    return jsonDecode(jsonString) as List<dynamic>;
  }

  Future<void> _fetchAndCacheNextBatch(int startDay) async {
    try {
      dev.log(
        'Silently fetching next batch of verses from Supabase...',
        name: 'VerseRepo',
      );

      final response = await _supabase
          .from('daily_verses')
          .select('day_of_year, reference, text')
          .gte('day_of_year', startDay)
          .limit(7);

      // Save them directly to SharedPreferences for tomorrow
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(response));
    } catch (e) {
      // Silent failure. If they are offline, we just try again next time!
      dev.log(
        'Background verse fetch failed (likely offline). Safe to ignore.',
        error: e,
        name: 'VerseRepo',
      );
    }
  }

  /// Calculates the current day of the year (1 - 366)
  int _getDayOfYear(DateTime date) {
    return date.difference(DateTime(date.year)).inDays + 1;
  }
}
