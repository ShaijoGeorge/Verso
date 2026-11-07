import 'package:verso/core/design/profiles/verso_palette.dart';

/// A named color theme profile containing light and dark palettes.
/// The AMOLED variant is auto-derived from [dark] via [VersoPalette.toAmoled].
class ThemeProfile {
  const ThemeProfile({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.inspiration,
    required this.light,
    required this.dark,
  });

  final String id;
  final String name;
  final String tagline;
  final String description;
  final String inspiration;
  final VersoPalette light;
  final VersoPalette dark;

  VersoPalette get amoled => dark.toAmoled();
}
