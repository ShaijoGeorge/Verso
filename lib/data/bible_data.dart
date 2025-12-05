enum Testament { old, newTestament }

class BibleBook {
  final int id;
  final String name;
  final int chapters;
  final Testament testament;

  const BibleBook({
    required this.id,
    required this.name,
    required this.chapters,
    required this.testament,
  });
}

/// A static list of all 73 books of the Bible.
const List<BibleBook> kBibleBooks = [
  // Old Testament
  BibleBook(id: 1, name: 'Genesis', chapters: 50, testament: Testament.old),
  BibleBook(id: 2, name: 'Exodus', chapters: 40, testament: Testament.old),
  BibleBook(id: 3, name: 'Leviticus', chapters: 27, testament: Testament.old),
  BibleBook(id: 4, name: 'Numbers', chapters: 36, testament: Testament.old),
  BibleBook(id: 5, name: 'Deuteronomy', chapters: 34, testament: Testament.old),
  BibleBook(id: 6, name: 'Joshua', chapters: 24, testament: Testament.old),
  BibleBook(id: 7, name: 'Judges', chapters: 21, testament: Testament.old),
  BibleBook(id: 8, name: 'Ruth', chapters: 4, testament: Testament.old),
  BibleBook(id: 9, name: '1 Samuel', chapters: 31, testament: Testament.old),
  BibleBook(id: 10, name: '2 Samuel', chapters: 24, testament: Testament.old),
  BibleBook(id: 11, name: '1 Kings', chapters: 22, testament: Testament.old),
  BibleBook(id: 12, name: '2 Kings', chapters: 25, testament: Testament.old),
  BibleBook(id: 13, name: '1 Chronicles', chapters: 29, testament: Testament.old),
  BibleBook(id: 14, name: '2 Chronicles', chapters: 36, testament: Testament.old),
  BibleBook(id: 15, name: 'Ezra', chapters: 10, testament: Testament.old),
  BibleBook(id: 16, name: 'Nehemiah', chapters: 13, testament: Testament.old),

  // Deuterocanonical Books
  BibleBook(id: 17, name: 'Tobit', chapters: 14, testament: Testament.old),
  BibleBook(id: 18, name: 'Judith', chapters: 16, testament: Testament.old),
  // Catholic Esther (16 chapters)
  BibleBook(id: 19, name: 'Esther', chapters: 16, testament: Testament.old),
  BibleBook(id: 20, name: '1 Maccabees', chapters: 16, testament: Testament.old),
  BibleBook(id: 21, name: '2 Maccabees', chapters: 15, testament: Testament.old),
  BibleBook(id: 22, name: 'Wisdom', chapters: 19, testament: Testament.old),
  BibleBook(id: 23, name: 'Sirach', chapters: 51, testament: Testament.old),
  BibleBook(id: 24, name: 'Baruch', chapters: 6, testament: Testament.old),

  // Continue remaining Old Testament
  BibleBook(id: 25, name: 'Job', chapters: 42, testament: Testament.old),
  BibleBook(id: 26, name: 'Psalms', chapters: 150, testament: Testament.old),
  BibleBook(id: 27, name: 'Proverbs', chapters: 31, testament: Testament.old),
  BibleBook(id: 28, name: 'Ecclesiastes', chapters: 12, testament: Testament.old),
  BibleBook(id: 29, name: 'Song of Solomon', chapters: 8, testament: Testament.old),
  BibleBook(id: 30, name: 'Isaiah', chapters: 66, testament: Testament.old),
  BibleBook(id: 31, name: 'Jeremiah', chapters: 52, testament: Testament.old),
  BibleBook(id: 32, name: 'Lamentations', chapters: 5, testament: Testament.old),
  // Catholic Daniel (14 chapters)
  BibleBook(id: 33, name: 'Ezekiel', chapters: 48, testament: Testament.old),
  BibleBook(id: 34, name: 'Daniel', chapters: 14, testament: Testament.old),
  BibleBook(id: 35, name: 'Hosea', chapters: 14, testament: Testament.old),
  BibleBook(id: 36, name: 'Joel', chapters: 3, testament: Testament.old),
  BibleBook(id: 37, name: 'Amos', chapters: 9, testament: Testament.old),
  BibleBook(id: 38, name: 'Obadiah', chapters: 1, testament: Testament.old),
  BibleBook(id: 39, name: 'Jonah', chapters: 4, testament: Testament.old),
  BibleBook(id: 40, name: 'Micah', chapters: 7, testament: Testament.old),
  BibleBook(id: 41, name: 'Nahum', chapters: 3, testament: Testament.old),
  BibleBook(id: 42, name: 'Habakkuk', chapters: 3, testament: Testament.old),
  BibleBook(id: 43, name: 'Zephaniah', chapters: 3, testament: Testament.old),
  BibleBook(id: 44, name: 'Haggai', chapters: 2, testament: Testament.old),
  BibleBook(id: 45, name: 'Zechariah', chapters: 14, testament: Testament.old),
  BibleBook(id: 46, name: 'Malachi', chapters: 4, testament: Testament.old),

  // New Testament
  BibleBook(id: 47, name: 'Matthew', chapters: 28, testament: Testament.newTestament),
  BibleBook(id: 48, name: 'Mark', chapters: 16, testament: Testament.newTestament),
  BibleBook(id: 49, name: 'Luke', chapters: 24, testament: Testament.newTestament),
  BibleBook(id: 50, name: 'John', chapters: 21, testament: Testament.newTestament),
  BibleBook(id: 51, name: 'Acts', chapters: 28, testament: Testament.newTestament),
  BibleBook(id: 52, name: 'Romans', chapters: 16, testament: Testament.newTestament),
  BibleBook(id: 53, name: '1 Corinthians', chapters: 16, testament: Testament.newTestament),
  BibleBook(id: 54, name: '2 Corinthians', chapters: 13, testament: Testament.newTestament),
  BibleBook(id: 55, name: 'Galatians', chapters: 6, testament: Testament.newTestament),
  BibleBook(id: 56, name: 'Ephesians', chapters: 6, testament: Testament.newTestament),
  BibleBook(id: 57, name: 'Philippians', chapters: 4, testament: Testament.newTestament),
  BibleBook(id: 58, name: 'Colossians', chapters: 4, testament: Testament.newTestament),
  BibleBook(id: 59, name: '1 Thessalonians', chapters: 5, testament: Testament.newTestament),
  BibleBook(id: 60, name: '2 Thessalonians', chapters: 3, testament: Testament.newTestament),
  BibleBook(id: 61, name: '1 Timothy', chapters: 6, testament: Testament.newTestament),
  BibleBook(id: 62, name: '2 Timothy', chapters: 4, testament: Testament.newTestament),
  BibleBook(id: 63, name: 'Titus', chapters: 3, testament: Testament.newTestament),
  BibleBook(id: 64, name: 'Philemon', chapters: 1, testament: Testament.newTestament),
  BibleBook(id: 65, name: 'Hebrews', chapters: 13, testament: Testament.newTestament),
  BibleBook(id: 66, name: 'James', chapters: 5, testament: Testament.newTestament),
  BibleBook(id: 67, name: '1 Peter', chapters: 5, testament: Testament.newTestament),
  BibleBook(id: 68, name: '2 Peter', chapters: 3, testament: Testament.newTestament),
  BibleBook(id: 69, name: '1 John', chapters: 5, testament: Testament.newTestament),
  BibleBook(id: 70, name: '2 John', chapters: 1, testament: Testament.newTestament),
  BibleBook(id: 71, name: '3 John', chapters: 1, testament: Testament.newTestament),
  BibleBook(id: 72, name: 'Jude', chapters: 1, testament: Testament.newTestament),
  BibleBook(id: 73, name: 'Revelation', chapters: 22, testament: Testament.newTestament),
];

// Automatically filter the lists so you don't have to manage them manually
final oldTestamentBooks = kBibleBooks
    .where((book) => book.testament == Testament.old)
    .toList();

final newTestamentBooks = kBibleBooks
    .where((book) => book.testament == Testament.newTestament)
    .toList();