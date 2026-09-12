enum CanonType { catholic, protestant, orthodox }

enum Testament { old, newTestament }

enum BookCategory {
  pentateuch,
  historical,
  wisdom,
  prophets,
  gospels,
  acts,
  letters,
  apocalyptic
}

extension BookCategoryName on BookCategory {
  String get displayName {
    switch (this) {
      case BookCategory.pentateuch:
        return 'The Pentateuch';
      case BookCategory.historical:
        return 'The Historical Books';
      case BookCategory.wisdom:
        return 'The Wisdom Books';
      case BookCategory.prophets:
        return 'The Prophets';
      case BookCategory.gospels:
        return 'The Gospels';
      case BookCategory.acts:
        return 'The Acts of the Apostles';
      case BookCategory.letters:
        return 'The Epistles (Letters)';
      case BookCategory.apocalyptic:
        return 'The Book of Revelation (Apocalyptic)';
    }
  }
}

class BibleBook {
  const BibleBook({
    required this.id,
    required this.name,
    required this.chapters,
    required this.testament,
    required this.category,
  });

  final int id;
  final String name;
  final int chapters;
  final Testament testament;
  final BookCategory category;
}

class BibleData {
  /// -------------------------------------------------------------------------
  /// SHARED NEW TESTAMENT (IDs 47-73)
  /// -------------------------------------------------------------------------
  static const List<BibleBook> _newTestament = [
    BibleBook(
        id: 47,
        name: 'Matthew',
        chapters: 28,
        testament: Testament.newTestament,
        category: BookCategory.gospels,),
    BibleBook(
        id: 48,
        name: 'Mark',
        chapters: 16,
        testament: Testament.newTestament,
        category: BookCategory.gospels,),
    BibleBook(
        id: 49,
        name: 'Luke',
        chapters: 24,
        testament: Testament.newTestament,
        category: BookCategory.gospels,),
    BibleBook(
        id: 50,
        name: 'John',
        chapters: 21,
        testament: Testament.newTestament,
        category: BookCategory.gospels,),
    BibleBook(
        id: 51,
        name: 'Acts',
        chapters: 28,
        testament: Testament.newTestament,
        category: BookCategory.acts,),
    BibleBook(
        id: 52,
        name: 'Romans',
        chapters: 16,
        testament: Testament.newTestament,
        category: BookCategory.letters,),
    BibleBook(
        id: 53,
        name: '1 Corinthians',
        chapters: 16,
        testament: Testament.newTestament,
        category: BookCategory.letters,),
    BibleBook(
        id: 54,
        name: '2 Corinthians',
        chapters: 13,
        testament: Testament.newTestament,
        category: BookCategory.letters,),
    BibleBook(
        id: 55,
        name: 'Galatians',
        chapters: 6,
        testament: Testament.newTestament,
        category: BookCategory.letters,),
    BibleBook(
        id: 56,
        name: 'Ephesians',
        chapters: 6,
        testament: Testament.newTestament,
        category: BookCategory.letters,),
    BibleBook(
        id: 57,
        name: 'Philippians',
        chapters: 4,
        testament: Testament.newTestament,
        category: BookCategory.letters,),
    BibleBook(
        id: 58,
        name: 'Colossians',
        chapters: 4,
        testament: Testament.newTestament,
        category: BookCategory.letters,),
    BibleBook(
        id: 59,
        name: '1 Thessalonians',
        chapters: 5,
        testament: Testament.newTestament,
        category: BookCategory.letters,),
    BibleBook(
        id: 60,
        name: '2 Thessalonians',
        chapters: 3,
        testament: Testament.newTestament,
        category: BookCategory.letters,),
    BibleBook(
        id: 61,
        name: '1 Timothy',
        chapters: 6,
        testament: Testament.newTestament,
        category: BookCategory.letters,),
    BibleBook(
        id: 62,
        name: '2 Timothy',
        chapters: 4,
        testament: Testament.newTestament,
        category: BookCategory.letters,),
    BibleBook(
        id: 63,
        name: 'Titus',
        chapters: 3,
        testament: Testament.newTestament,
        category: BookCategory.letters,),
    BibleBook(
        id: 64,
        name: 'Philemon',
        chapters: 1,
        testament: Testament.newTestament,
        category: BookCategory.letters,),
    BibleBook(
        id: 65,
        name: 'Hebrews',
        chapters: 13,
        testament: Testament.newTestament,
        category: BookCategory.letters,),
    BibleBook(
        id: 66,
        name: 'James',
        chapters: 5,
        testament: Testament.newTestament,
        category: BookCategory.letters,),
    BibleBook(
        id: 67,
        name: '1 Peter',
        chapters: 5,
        testament: Testament.newTestament,
        category: BookCategory.letters,),
    BibleBook(
        id: 68,
        name: '2 Peter',
        chapters: 3,
        testament: Testament.newTestament,
        category: BookCategory.letters,),
    BibleBook(
        id: 69,
        name: '1 John',
        chapters: 5,
        testament: Testament.newTestament,
        category: BookCategory.letters,),
    BibleBook(
        id: 70,
        name: '2 John',
        chapters: 1,
        testament: Testament.newTestament,
        category: BookCategory.letters,),
    BibleBook(
        id: 71,
        name: '3 John',
        chapters: 1,
        testament: Testament.newTestament,
        category: BookCategory.letters,),
    BibleBook(
        id: 72,
        name: 'Jude',
        chapters: 1,
        testament: Testament.newTestament,
        category: BookCategory.letters,),
    BibleBook(
        id: 73,
        name: 'Revelation',
        chapters: 22,
        testament: Testament.newTestament,
        category: BookCategory.apocalyptic,),
  ];

  /// -------------------------------------------------------------------------
  /// PROTESTANT CANON (66 Books)
  /// -------------------------------------------------------------------------
  static const List<BibleBook> protestantCanon = [
    // Pentateuch
    BibleBook(
        id: 1,
        name: 'Genesis',
        chapters: 50,
        testament: Testament.old,
        category: BookCategory.pentateuch,),
    BibleBook(
        id: 2,
        name: 'Exodus',
        chapters: 40,
        testament: Testament.old,
        category: BookCategory.pentateuch,),
    BibleBook(
        id: 3,
        name: 'Leviticus',
        chapters: 27,
        testament: Testament.old,
        category: BookCategory.pentateuch,),
    BibleBook(
        id: 4,
        name: 'Numbers',
        chapters: 36,
        testament: Testament.old,
        category: BookCategory.pentateuch,),
    BibleBook(
        id: 5,
        name: 'Deuteronomy',
        chapters: 34,
        testament: Testament.old,
        category: BookCategory.pentateuch,),
    // Historical
    BibleBook(
        id: 6,
        name: 'Joshua',
        chapters: 24,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 7,
        name: 'Judges',
        chapters: 21,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 8,
        name: 'Ruth',
        chapters: 4,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 9,
        name: '1 Samuel',
        chapters: 31,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 10,
        name: '2 Samuel',
        chapters: 24,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 11,
        name: '1 Kings',
        chapters: 22,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 12,
        name: '2 Kings',
        chapters: 25,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 13,
        name: '1 Chronicles',
        chapters: 29,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 14,
        name: '2 Chronicles',
        chapters: 36,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 15,
        name: 'Ezra',
        chapters: 10,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 16,
        name: 'Nehemiah',
        chapters: 13,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 19,
        name: 'Esther',
        chapters: 10,
        testament: Testament.old,
        category: BookCategory.historical,), // Protestant Esther = 10 chs
    // Wisdom
    BibleBook(
        id: 25,
        name: 'Job',
        chapters: 42,
        testament: Testament.old,
        category: BookCategory.wisdom,),
    BibleBook(
        id: 26,
        name: 'Psalms',
        chapters: 150,
        testament: Testament.old,
        category: BookCategory.wisdom,),
    BibleBook(
        id: 27,
        name: 'Proverbs',
        chapters: 31,
        testament: Testament.old,
        category: BookCategory.wisdom,),
    BibleBook(
        id: 28,
        name: 'Ecclesiastes',
        chapters: 12,
        testament: Testament.old,
        category: BookCategory.wisdom,),
    BibleBook(
        id: 29,
        name: 'Song of Solomon',
        chapters: 8,
        testament: Testament.old,
        category: BookCategory.wisdom,),
    // Prophets
    BibleBook(
        id: 30,
        name: 'Isaiah',
        chapters: 66,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 31,
        name: 'Jeremiah',
        chapters: 52,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 32,
        name: 'Lamentations',
        chapters: 5,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 33,
        name: 'Ezekiel',
        chapters: 48,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 34,
        name: 'Daniel',
        chapters: 12,
        testament: Testament.old,
        category: BookCategory.prophets,), // Protestant Daniel = 12 chs
    BibleBook(
        id: 35,
        name: 'Hosea',
        chapters: 14,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 36,
        name: 'Joel',
        chapters: 3,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 37,
        name: 'Amos',
        chapters: 9,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 38,
        name: 'Obadiah',
        chapters: 1,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 39,
        name: 'Jonah',
        chapters: 4,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 40,
        name: 'Micah',
        chapters: 7,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 41,
        name: 'Nahum',
        chapters: 3,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 42,
        name: 'Habakkuk',
        chapters: 3,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 43,
        name: 'Zephaniah',
        chapters: 3,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 44,
        name: 'Haggai',
        chapters: 2,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 45,
        name: 'Zechariah',
        chapters: 14,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 46,
        name: 'Malachi',
        chapters: 4,
        testament: Testament.old,
        category: BookCategory.prophets,),
    ..._newTestament,
  ];

  /// -------------------------------------------------------------------------
  /// CATHOLIC CANON (73 Books - Preserves our exact original structure)
  /// -------------------------------------------------------------------------
  static const List<BibleBook> catholicCanon = [
    // Pentateuch
    BibleBook(
        id: 1,
        name: 'Genesis',
        chapters: 50,
        testament: Testament.old,
        category: BookCategory.pentateuch,),
    BibleBook(
        id: 2,
        name: 'Exodus',
        chapters: 40,
        testament: Testament.old,
        category: BookCategory.pentateuch,),
    BibleBook(
        id: 3,
        name: 'Leviticus',
        chapters: 27,
        testament: Testament.old,
        category: BookCategory.pentateuch,),
    BibleBook(
        id: 4,
        name: 'Numbers',
        chapters: 36,
        testament: Testament.old,
        category: BookCategory.pentateuch,),
    BibleBook(
        id: 5,
        name: 'Deuteronomy',
        chapters: 34,
        testament: Testament.old,
        category: BookCategory.pentateuch,),
    // Historical
    BibleBook(
        id: 6,
        name: 'Joshua',
        chapters: 24,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 7,
        name: 'Judges',
        chapters: 21,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 8,
        name: 'Ruth',
        chapters: 4,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 9,
        name: '1 Samuel',
        chapters: 31,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 10,
        name: '2 Samuel',
        chapters: 24,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 11,
        name: '1 Kings',
        chapters: 22,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 12,
        name: '2 Kings',
        chapters: 25,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 13,
        name: '1 Chronicles',
        chapters: 29,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 14,
        name: '2 Chronicles',
        chapters: 36,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 15,
        name: 'Ezra',
        chapters: 10,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 16,
        name: 'Nehemiah',
        chapters: 13,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 17,
        name: 'Tobit',
        chapters: 14,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 18,
        name: 'Judith',
        chapters: 16,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 19,
        name: 'Esther',
        chapters: 16,
        testament: Testament.old,
        category: BookCategory.historical,), // Catholic Esther = 16 chs
    BibleBook(
        id: 20,
        name: '1 Maccabees',
        chapters: 16,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 21,
        name: '2 Maccabees',
        chapters: 15,
        testament: Testament.old,
        category: BookCategory.historical,),
    // Wisdom
    BibleBook(
        id: 22,
        name: 'Wisdom',
        chapters: 19,
        testament: Testament.old,
        category: BookCategory.wisdom,),
    BibleBook(
        id: 23,
        name: 'Sirach',
        chapters: 51,
        testament: Testament.old,
        category: BookCategory.wisdom,),
    BibleBook(
        id: 25,
        name: 'Job',
        chapters: 42,
        testament: Testament.old,
        category: BookCategory.wisdom,),
    BibleBook(
        id: 26,
        name: 'Psalms',
        chapters: 150,
        testament: Testament.old,
        category: BookCategory.wisdom,),
    BibleBook(
        id: 27,
        name: 'Proverbs',
        chapters: 31,
        testament: Testament.old,
        category: BookCategory.wisdom,),
    BibleBook(
        id: 28,
        name: 'Ecclesiastes',
        chapters: 12,
        testament: Testament.old,
        category: BookCategory.wisdom,),
    BibleBook(
        id: 29,
        name: 'Song of Solomon',
        chapters: 8,
        testament: Testament.old,
        category: BookCategory.wisdom,),
    // Prophets
    BibleBook(
        id: 24,
        name: 'Baruch',
        chapters: 6,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 30,
        name: 'Isaiah',
        chapters: 66,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 31,
        name: 'Jeremiah',
        chapters: 52,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 32,
        name: 'Lamentations',
        chapters: 5,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 33,
        name: 'Ezekiel',
        chapters: 48,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 34,
        name: 'Daniel',
        chapters: 14,
        testament: Testament.old,
        category: BookCategory.prophets,), // Catholic Daniel = 14 chs
    BibleBook(
        id: 35,
        name: 'Hosea',
        chapters: 14,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 36,
        name: 'Joel',
        chapters: 3,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 37,
        name: 'Amos',
        chapters: 9,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 38,
        name: 'Obadiah',
        chapters: 1,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 39,
        name: 'Jonah',
        chapters: 4,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 40,
        name: 'Micah',
        chapters: 7,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 41,
        name: 'Nahum',
        chapters: 3,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 42,
        name: 'Habakkuk',
        chapters: 3,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 43,
        name: 'Zephaniah',
        chapters: 3,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 44,
        name: 'Haggai',
        chapters: 2,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 45,
        name: 'Zechariah',
        chapters: 14,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 46,
        name: 'Malachi',
        chapters: 4,
        testament: Testament.old,
        category: BookCategory.prophets,),
    ..._newTestament,
  ];

  /// -------------------------------------------------------------------------
  /// EASTERN ORTHODOX CANON (78 Books)
  /// Introduces new IDs (74+) for Orthodox-specific books to avoid data clashes.
  /// -------------------------------------------------------------------------
  static const List<BibleBook> orthodoxCanon = [
    // Pentateuch
    BibleBook(
        id: 1,
        name: 'Genesis',
        chapters: 50,
        testament: Testament.old,
        category: BookCategory.pentateuch,),
    BibleBook(
        id: 2,
        name: 'Exodus',
        chapters: 40,
        testament: Testament.old,
        category: BookCategory.pentateuch,),
    BibleBook(
        id: 3,
        name: 'Leviticus',
        chapters: 27,
        testament: Testament.old,
        category: BookCategory.pentateuch,),
    BibleBook(
        id: 4,
        name: 'Numbers',
        chapters: 36,
        testament: Testament.old,
        category: BookCategory.pentateuch,),
    BibleBook(
        id: 5,
        name: 'Deuteronomy',
        chapters: 34,
        testament: Testament.old,
        category: BookCategory.pentateuch,),
    // Historical
    BibleBook(
        id: 6,
        name: 'Joshua',
        chapters: 24,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 7,
        name: 'Judges',
        chapters: 21,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 8,
        name: 'Ruth',
        chapters: 4,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 9,
        name: '1 Samuel',
        chapters: 31,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 10,
        name: '2 Samuel',
        chapters: 24,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 11,
        name: '1 Kings',
        chapters: 22,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 12,
        name: '2 Kings',
        chapters: 25,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 13,
        name: '1 Chronicles',
        chapters: 29,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 14,
        name: '2 Chronicles',
        chapters: 36,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 74,
        name: '1 Esdras',
        chapters: 9,
        testament: Testament.old,
        category: BookCategory.historical,), // New ID
    BibleBook(
        id: 15,
        name: 'Ezra',
        chapters: 10,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 16,
        name: 'Nehemiah',
        chapters: 13,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 17,
        name: 'Tobit',
        chapters: 14,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 18,
        name: 'Judith',
        chapters: 16,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 19,
        name: 'Esther',
        chapters: 16,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 20,
        name: '1 Maccabees',
        chapters: 16,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 21,
        name: '2 Maccabees',
        chapters: 15,
        testament: Testament.old,
        category: BookCategory.historical,),
    BibleBook(
        id: 75,
        name: '3 Maccabees',
        chapters: 7,
        testament: Testament.old,
        category: BookCategory.historical,), // New ID
    // Wisdom
    BibleBook(
        id: 26,
        name: 'Psalms',
        chapters: 151,
        testament: Testament.old,
        category: BookCategory.wisdom,), // Orthodox Psalms = 151 chs
    BibleBook(
        id: 76,
        name: 'Prayer of Manasseh',
        chapters: 1,
        testament: Testament.old,
        category: BookCategory.wisdom,), // New ID
    BibleBook(
        id: 25,
        name: 'Job',
        chapters: 42,
        testament: Testament.old,
        category: BookCategory.wisdom,),
    BibleBook(
        id: 27,
        name: 'Proverbs',
        chapters: 31,
        testament: Testament.old,
        category: BookCategory.wisdom,),
    BibleBook(
        id: 28,
        name: 'Ecclesiastes',
        chapters: 12,
        testament: Testament.old,
        category: BookCategory.wisdom,),
    BibleBook(
        id: 29,
        name: 'Song of Solomon',
        chapters: 8,
        testament: Testament.old,
        category: BookCategory.wisdom,),
    BibleBook(
        id: 22,
        name: 'Wisdom',
        chapters: 19,
        testament: Testament.old,
        category: BookCategory.wisdom,),
    BibleBook(
        id: 23,
        name: 'Sirach',
        chapters: 51,
        testament: Testament.old,
        category: BookCategory.wisdom,),
    // Prophets (Orthodox canon places Minor Prophets before Major Prophets)
    BibleBook(
        id: 35,
        name: 'Hosea',
        chapters: 14,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 37,
        name: 'Amos',
        chapters: 9,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 40,
        name: 'Micah',
        chapters: 7,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 36,
        name: 'Joel',
        chapters: 3,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 38,
        name: 'Obadiah',
        chapters: 1,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 39,
        name: 'Jonah',
        chapters: 4,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 41,
        name: 'Nahum',
        chapters: 3,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 42,
        name: 'Habakkuk',
        chapters: 3,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 43,
        name: 'Zephaniah',
        chapters: 3,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 44,
        name: 'Haggai',
        chapters: 2,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 45,
        name: 'Zechariah',
        chapters: 14,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 46,
        name: 'Malachi',
        chapters: 4,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 30,
        name: 'Isaiah',
        chapters: 66,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 31,
        name: 'Jeremiah',
        chapters: 52,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 24,
        name: 'Baruch',
        chapters: 5,
        testament: Testament.old,
        category: BookCategory.prophets,), // Orthodox Baruch = 5 chs
    BibleBook(
        id: 77,
        name: 'Epistle of Jeremiah',
        chapters: 1,
        testament: Testament.old,
        category: BookCategory.prophets,), // Separated from Baruch, New ID
    BibleBook(
        id: 32,
        name: 'Lamentations',
        chapters: 5,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 33,
        name: 'Ezekiel',
        chapters: 48,
        testament: Testament.old,
        category: BookCategory.prophets,),
    BibleBook(
        id: 34,
        name: 'Daniel',
        chapters: 14,
        testament: Testament.old,
        category: BookCategory.prophets,),
    ..._newTestament,
  ];

  /// Core accessor method for UI providers
  static List<BibleBook> getBooksForCanon(CanonType type) {
    switch (type) {
      case CanonType.protestant:
        return protestantCanon;
      case CanonType.catholic:
        return catholicCanon;
      case CanonType.orthodox:
        return orthodoxCanon;
    }
  }

  /// Find a book by ID across all canons.
  static BibleBook? findBookById(int id) {
    for (final b in orthodoxCanon) {
      if (b.id == id) return b;
    }
    for (final b in catholicCanon) {
      if (b.id == id) return b;
    }
    for (final b in protestantCanon) {
      if (b.id == id) return b;
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Backward-Compatibility Aliases
// Defaults to the Catholic Canon (73 books) to ensure existing providers,
// routers, and statistics grids continue functioning smoothly.
// ---------------------------------------------------------------------------
const List<BibleBook> kBibleBooks = BibleData.catholicCanon;

final List<BibleBook> oldTestamentBooks =
    kBibleBooks.where((book) => book.testament == Testament.old).toList();

final List<BibleBook> newTestamentBooks = kBibleBooks
    .where((book) => book.testament == Testament.newTestament)
    .toList();
