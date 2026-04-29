import 'package:flutter/material.dart';
import 'package:verso/data/local/entities/user_settings.dart';

/// Full semantic color token set for a single appearance variant (light/dark/amoled).
///
/// Registered as a [ThemeExtension] so it travels with [ThemeData] and is
/// accessible via `Theme.of(context).extension<VersoPalette>()!` or the
/// `context.palette` shorthand from `extensions.dart`.
@immutable
class VersoPalette extends ThemeExtension<VersoPalette> {
  const VersoPalette({
    required this.style,
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.borderLight,
    required this.primary,
    required this.primaryHover,
    required this.secondary,
    required this.accent,
    required this.accentBright,
    required this.accentSoft,
    required this.text,
    required this.textMuted,
    required this.textLight,
    required this.success,
    required this.warning,
    required this.danger,
    required this.progress,
    required this.progressBg,
    required this.tag,
    required this.tagText,
    required this.streakBg,
    required this.streakText,
    required this.divider,
    required this.footerBg,
    required this.footerActive,
    required this.footerInactive,
    required this.highlight,
    required this.cross,
  });

  final AppearanceStyle style;

  // Background / Surface
  final Color bg;
  final Color surface;
  final Color surfaceAlt;

  // Borders
  final Color border;
  final Color borderLight;

  // Primary
  final Color primary;
  final Color primaryHover;
  final Color secondary;

  // Accent
  final Color accent;
  final Color accentBright;
  final Color accentSoft;

  // Text
  final Color text;
  final Color textMuted;
  final Color textLight;

  // Status
  final Color success;
  final Color warning;
  final Color danger;

  // Progress
  final Color progress;
  final Color progressBg;

  // Tags
  final Color tag;
  final Color tagText;

  // Streak
  final Color streakBg;
  final Color streakText;

  // Divider
  final Color divider;

  // Footer / Navigation bar
  final Color footerBg;
  final Color footerActive;
  final Color footerInactive;

  // Misc
  final Color highlight;
  final Color cross;

  /// Returns an AMOLED variant derived from this palette: true-black bg/surface,
  /// bumped border contrast to compensate for the pure-black background.
  VersoPalette toAmoled() => copyWith(
        style: AppearanceStyle.amoled,
        bg: const Color(0xFF000000),
        surface: const Color(0xFF0A0A0A),
        border: const Color(0xFF383838),
        borderLight: const Color(0xFF1A1A1A),
        divider: const Color(0xFF1A1A1A),
        footerBg: const Color(0xFF000000),
      );

  @override
  VersoPalette copyWith({
    AppearanceStyle? style,
    Color? bg,
    Color? surface,
    Color? surfaceAlt,
    Color? border,
    Color? borderLight,
    Color? primary,
    Color? primaryHover,
    Color? secondary,
    Color? accent,
    Color? accentBright,
    Color? accentSoft,
    Color? text,
    Color? textMuted,
    Color? textLight,
    Color? success,
    Color? warning,
    Color? danger,
    Color? progress,
    Color? progressBg,
    Color? tag,
    Color? tagText,
    Color? streakBg,
    Color? streakText,
    Color? divider,
    Color? footerBg,
    Color? footerActive,
    Color? footerInactive,
    Color? highlight,
    Color? cross,
  }) =>
      VersoPalette(
        style: style ?? this.style,
        bg: bg ?? this.bg,
        surface: surface ?? this.surface,
        surfaceAlt: surfaceAlt ?? this.surfaceAlt,
        border: border ?? this.border,
        borderLight: borderLight ?? this.borderLight,
        primary: primary ?? this.primary,
        primaryHover: primaryHover ?? this.primaryHover,
        secondary: secondary ?? this.secondary,
        accent: accent ?? this.accent,
        accentBright: accentBright ?? this.accentBright,
        accentSoft: accentSoft ?? this.accentSoft,
        text: text ?? this.text,
        textMuted: textMuted ?? this.textMuted,
        textLight: textLight ?? this.textLight,
        success: success ?? this.success,
        warning: warning ?? this.warning,
        danger: danger ?? this.danger,
        progress: progress ?? this.progress,
        progressBg: progressBg ?? this.progressBg,
        tag: tag ?? this.tag,
        tagText: tagText ?? this.tagText,
        streakBg: streakBg ?? this.streakBg,
        streakText: streakText ?? this.streakText,
        divider: divider ?? this.divider,
        footerBg: footerBg ?? this.footerBg,
        footerActive: footerActive ?? this.footerActive,
        footerInactive: footerInactive ?? this.footerInactive,
        highlight: highlight ?? this.highlight,
        cross: cross ?? this.cross,
      );

  @override
  VersoPalette lerp(ThemeExtension<VersoPalette>? other, double t) {
    if (other is! VersoPalette) return this;
    return VersoPalette(
      style: t < 0.5 ? style : other.style,
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentBright: Color.lerp(accentBright, other.accentBright, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textLight: Color.lerp(textLight, other.textLight, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      progress: Color.lerp(progress, other.progress, t)!,
      progressBg: Color.lerp(progressBg, other.progressBg, t)!,
      tag: Color.lerp(tag, other.tag, t)!,
      tagText: Color.lerp(tagText, other.tagText, t)!,
      streakBg: Color.lerp(streakBg, other.streakBg, t)!,
      streakText: Color.lerp(streakText, other.streakText, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      footerBg: Color.lerp(footerBg, other.footerBg, t)!,
      footerActive: Color.lerp(footerActive, other.footerActive, t)!,
      footerInactive: Color.lerp(footerInactive, other.footerInactive, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      cross: Color.lerp(cross, other.cross, t)!,
    );
  }
}
