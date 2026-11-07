import 'package:verso/data/bible_book_names.dart';
import 'package:verso/data/bible_data.dart';

/// English book names mapped to their canonical book ID in [BibleData].
const Map<String, int> _dailyVerseBookNameToId = {
  'Genesis': 1,
  'Exodus': 2,
  'Leviticus': 3,
  'Numbers': 4,
  'Deuteronomy': 5,
  'Joshua': 6,
  'Judges': 7,
  'Ruth': 8,
  '1 Samuel': 9,
  '2 Samuel': 10,
  '1 Kings': 11,
  '2 Kings': 12,
  '1 Chronicles': 13,
  '2 Chronicles': 14,
  'Ezra': 15,
  'Nehemiah': 16,
  'Tobit': 17,
  'Judith': 18,
  'Esther': 19,
  '1 Maccabees': 20,
  '2 Maccabees': 21,
  'Job': 25,
  'Psalm': 26,
  'Psalms': 26,
  'Proverbs': 27,
  'Ecclesiastes': 28,
  'Song of Solomon': 29,
  'Song of Songs': 29,
  'Isaiah': 30,
  'Jeremiah': 31,
  'Lamentations': 32,
  'Baruch': 24,
  'Ezekiel': 33,
  'Daniel': 34,
  'Hosea': 35,
  'Joel': 36,
  'Amos': 37,
  'Obadiah': 38,
  'Jonah': 39,
  'Micah': 40,
  'Nahum': 41,
  'Habakkuk': 42,
  'Zephaniah': 43,
  'Haggai': 44,
  'Zechariah': 45,
  'Malachi': 46,
  'Matthew': 47,
  'Mark': 48,
  'Luke': 49,
  'John': 50,
  'Acts': 51,
  'Romans': 52,
  '1 Corinthians': 53,
  '2 Corinthians': 54,
  'Galatians': 55,
  'Ephesians': 56,
  'Philippians': 57,
  'Colossians': 58,
  '1 Thessalonians': 59,
  '2 Thessalonians': 60,
  '1 Timothy': 61,
  '2 Timothy': 62,
  'Titus': 63,
  'Philemon': 64,
  'Hebrews': 65,
  'James': 66,
  '1 Peter': 67,
  '2 Peter': 68,
  '1 John': 69,
  '2 John': 70,
  '3 John': 71,
  'Jude': 72,
  'Revelation': 73,
};

/// Represents a Scripture verse of the day with English and Malayalam translations.
class DailyVerse {
  const DailyVerse({
    required this.dayOfYear,
    required this.referenceEn,
    required this.textEn,
    required this.textMlPoc,
    required this.textMlBsi,
  });

  factory DailyVerse.fromJson(Map<String, dynamic> json) {
    final poc =
        json['text_ml_poc'] as String? ?? json['text_ml'] as String? ?? '';
    final bsi = json['text_ml_bsi'] as String? ?? '';
    return DailyVerse(
      dayOfYear: json['day_of_year'] as int? ?? 1,
      referenceEn: json['reference'] as String? ?? json['ref'] as String? ?? '',
      textEn: json['text_en'] as String? ?? json['text'] as String? ?? '',
      textMlPoc: poc.isNotEmpty ? poc : bsi,
      textMlBsi: bsi.isNotEmpty ? bsi : poc,
    );
  }

  /// Default fallback verse for fresh offline launches.
  static const fallback = DailyVerse(
    dayOfYear: 1,
    referenceEn: 'Psalm 119:105',
    textEn: 'Your word is a lamp to my feet and a light to my path.',
    textMlPoc: 'അങ്ങയുടെ വചനം എന്റെ പാദത്തിനു വിളക്കും പാതയില്‍ പ്രകാശവുമാണ്.',
    textMlBsi:
        'നിന്റെ വചനം എന്റെ കാലിന്നു ദീപവും എന്റെ പാതെക്കു പ്രകാശവും ആകുന്നു.',
  );

  final int dayOfYear;
  final String referenceEn;
  final String textEn;

  /// POC Catholic/Orthodox Malayalam translation.
  final String textMlPoc;

  /// BSI Protestant Malayalam translation (Sathya Veda Pusthakam).
  final String textMlBsi;

  /// Legacy map indexing for backward compatibility.
  dynamic operator [](String key) => switch (key) {
        'day_of_year' => dayOfYear,
        'reference' || 'ref' => referenceEn,
        'text' || 'text_en' => textEn,
        'text_ml_poc' => textMlPoc,
        'text_ml_bsi' => textMlBsi,
        'text_ml' => textMlPoc,
        _ => null,
      };

  /// Returns the Scripture text based on language code ('en' or 'ml')
  /// and [canon] tradition.
  String getText(String langCode, CanonType canon) {
    if (langCode == 'ml') {
      final preferred = canon == CanonType.protestant ? textMlBsi : textMlPoc;
      if (preferred.trim().isNotEmpty) return preferred;
      final alternate = canon == CanonType.protestant ? textMlPoc : textMlBsi;
      if (alternate.trim().isNotEmpty) return alternate;
      return textEn;
    }
    return textEn;
  }

  /// Returns the localized reference (e.g. "സങ്കീർത്തനങ്ങൾ 119:105" or "യോശുവ 1:9").
  String getReference(String langCode, CanonType canon) {
    if (langCode != 'ml') return referenceEn;
    return getLocalizedReference(referenceEn, canon);
  }

  /// Static helper to convert an English reference to a localized Malayalam reference
  /// matching the specified [canon].
  static String getLocalizedReference(String englishRef, CanonType canon) {
    final lastSpace = englishRef.lastIndexOf(' ');
    if (lastSpace == -1) return englishRef;
    final bookName = englishRef.substring(0, lastSpace).trim();
    final chapterVerse = englishRef.substring(lastSpace + 1).trim();

    final bookId = _dailyVerseBookNameToId[bookName];
    if (bookId == null) return englishRef;

    final book = BibleData.findBookById(bookId);
    if (book == null) return englishRef;

    final localizedBook = book.getLocalizedName('ml', canon);
    return '$localizedBook $chapterVerse';
  }

  Map<String, dynamic> toJson() => {
        'day_of_year': dayOfYear,
        'reference': referenceEn,
        'text': textEn,
        'text_ml_poc': textMlPoc,
        'text_ml_bsi': textMlBsi,
      };
}
