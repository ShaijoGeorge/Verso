import 'package:verso/data/bible_data.dart';

/// Malayalam book translations for Catholic and Orthodox traditions (POC standard).
const Map<int, String> _malayalamPocBookNames = {
  // Pentateuch
  1: 'ഉല്‍‍പത്തി',
  2: 'പുറപ്പാട്',
  3: 'ലേവ്യർ',
  4: 'സംഖ്യ',
  5: 'നിയമാവർത്തനം',

  // Historical
  6: 'ജോഷ്വാ',
  7: 'ന്യായാധിപ‌ന്‍‍മാര്‍',
  8: 'റൂത്ത്',
  9: '1 സാമുവൽ',
  10: '2 സാമുവൽ',
  11: '1 രാജാക്കന്മാർ',
  12: '2 രാജാക്കന്മാർ',
  13: '1 ദിനവൃത്താന്തം',
  14: '2 ദിനവൃത്താന്തം',
  15: 'എസ്രാ',
  16: 'നെഹെമിയ',
  17: 'തോബിത്',
  18: 'യൂദിത്ത്',
  19: 'എസ്തേർ',
  20: '1 മക്കബായർ',
  21: '2 മക്കബായർ',

  // Wisdom
  22: 'ജ്ഞാനം',
  23: 'സിറാക്ക്',
  25: 'ജോബ്',
  26: 'സങ്കീർത്തനങ്ങൾ',
  27: 'സുഭാഷിതങ്ങൾ',
  28: 'സഭാപ്രസംഗകൻ',
  29: 'ഉത്തമഗീതം',

  // Prophets
  24: 'ബാറൂക്ക്',
  30: 'ഏശയ്യാ',
  31: 'ജെറെമിയ',
  32: 'വിലാപങ്ങൾ',
  33: 'എസെക്കിയേൽ',
  34: 'ദാനിയേൽ',
  35: 'ഹോസിയാ',
  36: 'ജോയേൽ',
  37: 'ആമോസ്',
  38: 'ഒബാദിയ',
  39: 'യോനാ',
  40: 'മിക്കാ',
  41: 'നാഹും',
  42: 'ഹബക്കുക്ക്',
  43: 'സെഫാനിയ',
  44: 'ഹഗ്ഗായി',
  45: 'സഖറിയാ',
  46: 'മലാക്കി',

  // New Testament
  47: 'മത്തായി',
  48: 'മർക്കോസ്',
  49: 'ലൂക്കാ',
  50: 'യോഹന്നാൻ',
  51: 'അപ്പ. പ്രവര്‍ത്തനങ്ങള്‍',
  52: 'റോമാ',
  53: '1 കൊറിന്തോസ്',
  54: '2 കൊറിന്തോസ്',
  55: 'ഗലാത്തിയാ',
  56: 'എഫേസോസ്',
  57: 'ഫിലിപ്പി',
  58: 'കൊളോസോസ്',
  59: '1 തെസലോനിക്കാ',
  60: '2 തെസലോനിക്കാ',
  61: '1 തിമോത്തേയോസ്',
  62: '2 തിമോത്തേയോസ്',
  63: 'തീത്തോസ്',
  64: 'ഫിലെമോ‌ന്‍',
  65: 'ഹെബ്രായര്‍',
  66: 'യാക്കോബ്',
  67: '1 പത്രോസ്',
  68: '2 പത്രോസ്',
  69: '1 യോഹന്നാൻ',
  70: '2 യോഹന്നാൻ',
  71: '3 യോഹന്നാൻ',
  72: 'യുദാസ്',
  73: 'വെളിപാട്',

  // Orthodox specific books
  74: '1 എസ്രാ',
  75: '3 മക്കബായർ',
  76: 'മനശ്ശെയുടെ പ്രാർത്ഥന',
  77: 'ജെറമിയായുടെ ലേഖനം',
};

/// Specific Malayalam name variants for Protestant traditions (BSI Sathya Veda Pusthakam).
const Map<int, String> _malayalamBsiVariants = {
  6: 'യോശുവ',
  25: 'ഇയ്യോബ്',
  27: 'സദൃശവാക്യങ്ങൾ',
  30: 'യെശയ്യാവ്',
  31: 'യിരെമ്യാവ്',
  33: 'യെഹെസ്കേൽ',
  35: 'ഹോശേയ',
  36: 'യോവേൽ',
  38: 'ഒബദ്യാവ്',
  39: 'യോനാ',
  43: 'സെഫന്യാവ്',
  49: 'ലൂക്കോസ്',
  51: 'പ്രവൃത്തികൾ',
};

/// Category translations in Malayalam
const Map<BookCategory, String> _malayalamCategoryNames = {
  BookCategory.pentateuch: 'പഞ്ചഗ്രന്ഥങ്ങൾ',
  BookCategory.historical: 'ചരിത്ര പുസ്തകങ്ങൾ',
  BookCategory.wisdom: 'ജ്ഞാനസാഹിത്യം',
  BookCategory.prophets: 'പ്രവാചകന്മാർ',
  BookCategory.gospels: 'സുവിശേഷങ്ങൾ',
  BookCategory.acts: 'അപ്പസ്തോല പ്രവർത്തനങ്ങൾ',
  BookCategory.letters: 'ലേഖനങ്ങൾ',
  BookCategory.apocalyptic: 'വെളിപാട് പുസ്തകം',
};

String _normalizeMalayalam(String text) {
  return text
      .replaceAll('\u200D', '')
      .replaceAll('\u200C', '')
      .replaceAll('ൽ', 'ല്')
      .replaceAll('ർ', 'ര്')
      .replaceAll('ൻ', 'ന്')
      .replaceAll('ൺ', 'ണ്')
      .replaceAll('ൾ', 'ള്');
}

/// Extension for localized Bible book names and search matching.
extension BibleBookLocalization on BibleBook {
  /// Returns the localized name of the Bible book according to [langCode] ('en' or 'ml')
  /// and the user's active [canon] tradition.
  String getLocalizedName(String langCode, [CanonType? canon]) {
    if (langCode == 'ml') {
      if (canon == CanonType.protestant &&
          _malayalamBsiVariants.containsKey(id)) {
        return _malayalamBsiVariants[id]!;
      }
      return _malayalamPocBookNames[id] ?? name;
    }
    return name;
  }

  /// Returns true if [query] matches the English name, primary Malayalam name,
  /// or Protestant/Catholic variant of the book.
  bool matchesQuery(String query, String langCode, [CanonType? canon]) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return true;

    // 1. English match
    if (name.toLowerCase().contains(cleanQuery)) return true;

    final normQuery = _normalizeMalayalam(cleanQuery);

    bool matchesCandidate(String? candidate) {
      if (candidate == null) return false;
      final lower = candidate.toLowerCase();
      if (lower.contains(cleanQuery)) return true;
      if (_normalizeMalayalam(lower).contains(normQuery)) return true;
      return false;
    }

    // 2. Localized name match
    if (matchesCandidate(getLocalizedName(langCode, canon))) return true;

    // 3. Alternative Malayalam spelling matches
    if (matchesCandidate(_malayalamPocBookNames[id])) return true;
    if (matchesCandidate(_malayalamBsiVariants[id])) return true;

    // 4. Common alternate spellings
    const commonAliases = <int, List<String>>{
      1: ['ഉല്പത്തി', 'ഉല്‍പത്തി', 'ഉല്‍‍പത്തി'],
      7: ['ന്യായാധിപന്മാർ', 'ന്യായാധിപ‌ന്‍‍മാര്‍'],
      49: ['ലൂക്കോസ്', 'ലൂക്കൊസ്'],
      51: ['അപ്പസ്തോല പ്രവർത്തനങ്ങൾ', 'പ്രവൃത്തികൾ', 'അപ്പ. പ്രവര്‍ത്തനങ്ങള്‍'],
    };
    final aliases = commonAliases[id];
    if (aliases != null) {
      for (final alias in aliases) {
        if (matchesCandidate(alias)) return true;
      }
    }

    return false;
  }
}

/// Extension for localized Book Category display names.
extension BookCategoryLocalization on BookCategory {
  String getLocalizedDisplayName(String langCode) {
    if (langCode == 'ml') {
      return _malayalamCategoryNames[this] ?? displayName;
    }
    return displayName;
  }
}

/// Extension for localized Testament display names.
extension TestamentLocalization on Testament {
  String getLocalizedName(String langCode) {
    if (langCode == 'ml') {
      return this == Testament.old ? 'പഴയനിയമം' : 'പുതിയനിയമം';
    }
    return this == Testament.old ? 'Old Testament' : 'New Testament';
  }
}
