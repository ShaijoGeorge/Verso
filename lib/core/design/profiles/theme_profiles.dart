import 'package:verso/core/design/profiles/candy_pop_profile.dart';
import 'package:verso/core/design/profiles/current_profile.dart';
import 'package:verso/core/design/profiles/illuminated_manuscript_profile.dart';
import 'package:verso/core/design/profiles/malabar_chapel_profile.dart';
import 'package:verso/core/design/profiles/theme_profile.dart';

export 'candy_pop_profile.dart';
export 'current_profile.dart';
export 'illuminated_manuscript_profile.dart';
export 'malabar_chapel_profile.dart';
export 'theme_profile.dart';
export 'verso_palette.dart';

/// Registry of all available [ThemeProfile]s.
abstract final class ThemeProfiles {
  static const String defaultId = 'current';

  static final List<ThemeProfile> all = [
    currentProfile,
    illuminatedManuscriptProfile,
    malabarChapelProfile,
    candyPopProfile,
  ];

  static ThemeProfile byId(String id) =>
      all.firstWhere((p) => p.id == id, orElse: () => currentProfile);
}
