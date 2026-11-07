import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:verso/core/design/design.dart';
import 'package:verso/data/bible_data.dart';
import 'package:verso/data/local/entities/user_settings.dart';
import 'package:verso/features/home/providers/home_providers.dart';
import 'package:verso/features/settings/providers/settings_providers.dart';
import 'package:verso/features/stats/providers/stats_providers.dart';

enum ShareCardMode { invite, dailyVerse, progress }

enum ShareCardTheme { light, dark, amoled }

class VersoShareSheet extends ConsumerStatefulWidget {
  const VersoShareSheet({
    this.initialMode = ShareCardMode.invite,
    this.completedBookName,
    this.completedBookChapters,
    super.key,
  });

  final ShareCardMode initialMode;
  final String? completedBookName;
  final int? completedBookChapters;

  static Future<void> show(
    BuildContext context, {
    ShareCardMode initialMode = ShareCardMode.invite,
    String? completedBookName,
    int? completedBookChapters,
  }) {
    return VersoBottomSheet.show<void>(
      context: context,
      title: 'Share Verso',
      contentPadding: EdgeInsets.zero,
      child: VersoShareSheet(
        initialMode: initialMode,
        completedBookName: completedBookName,
        completedBookChapters: completedBookChapters,
      ),
    );
  }

  @override
  ConsumerState<VersoShareSheet> createState() => _VersoShareSheetState();
}

class _VersoShareSheetState extends ConsumerState<VersoShareSheet> {
  final GlobalKey _boundaryKey = GlobalKey();
  late ShareCardMode _selectedMode;
  bool _isSharing = false;
  ShareCardTheme? _cardTheme;
  String? _overrideProfileId;

  static const String _appUrl = 'https://versobibletracker.netlify.app/';

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.completedBookName != null
        ? ShareCardMode.progress
        : widget.initialMode;
  }

  void _cycleCardTheme(ShareCardTheme currentTheme) {
    HapticFeedback.selectionClick();
    final nextTheme = switch (currentTheme) {
      ShareCardTheme.light => ShareCardTheme.dark,
      ShareCardTheme.dark => ShareCardTheme.amoled,
      ShareCardTheme.amoled => ShareCardTheme.light,
    };
    setState(() => _cardTheme = nextTheme);
  }

  void _showThemeProfilePicker(
    BuildContext context,
    ThemeProfile currentProfile,
    ShareCardTheme currentTheme,
  ) {
    HapticFeedback.mediumImpact();
    VersoBottomSheet.show<void>(
      context: context,
      title: 'Card Theme Profile',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final profile in ThemeProfiles.all)
            _ThemeProfilePickerTile(
              profile: profile,
              isSelected: profile.id == currentProfile.id,
              theme: currentTheme,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _overrideProfileId = profile.id);
                Navigator.pop(context);
              },
            ),
          const Gap(16),
        ],
      ),
    );
  }

  String _buildShareText({
    required UserStats? stats,
    required String? verseText,
    required String? verseRef,
  }) {
    switch (_selectedMode) {
      case ShareCardMode.dailyVerse:
        if (verseText != null && verseRef != null) {
          return '“$verseText”\n— $verseRef\n\n'
              'Read daily on Verso: $_appUrl';
        }
        return 'Join me on Verso: $_appUrl';
      case ShareCardMode.progress:
        if (widget.completedBookName != null) {
          return 'I just completed reading ${widget.completedBookName} '
              '(${widget.completedBookChapters} chapters) on Verso! 📖✨\n\n'
              'Join me on the journey: $_appUrl';
        }
        if (stats != null &&
            (stats.totalChaptersRead > 0 || stats.streak > 0)) {
          final booksText = stats.booksCompleted == 1
              ? '1 book completed'
              : '${stats.booksCompleted} books completed';
          final progressPercent = stats.totalProgress.toStringAsFixed(1);
          return "I'm on a ${stats.streak}-day Bible reading streak with "
              '$booksText ($progressPercent% of Bible completed) on Verso! 🔥📖\n\n'
              'Track your daily Scripture habit with me: $_appUrl';
        }
        return 'Track your daily Bible reading habit on Verso: $_appUrl';
      case ShareCardMode.invite:
        return "Hey! I've been using Verso to read the Bible and build a daily "
            "habit. It's simple, beautiful, and has really helped me stay "
            'consistent.\n\n'
            'Join me on the journey: $_appUrl';
    }
  }

  Future<void> _shareCard({
    required UserStats? stats,
    required String? verseText,
    required String? verseRef,
  }) async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    HapticFeedback.mediumImpact();

    final shareText = _buildShareText(
      stats: stats,
      verseText: verseText,
      verseRef: verseRef,
    );

    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 3);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

        if (byteData != null) {
          final pngBytes = byteData.buffer.asUint8List();
          final tempDir = await getTemporaryDirectory();
          final file = await File('${tempDir.path}/verso_share.png')
              .writeAsBytes(pngBytes);

          await SharePlus.instance.share(
            ShareParams(
              files: [XFile(file.path, mimeType: 'image/png')],
              text: shareText,
            ),
          );
          return;
        }
      }

      await SharePlus.instance.share(ShareParams(text: shareText));
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _copyLink() async {
    await Clipboard.setData(const ClipboardData(text: _appUrl));
    HapticFeedback.lightImpact();
    if (!mounted) return;
    Navigator.pop(context);
    VersoSnackbar.success(context, message: 'Invite link copied to clipboard!');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;
    final defaultTheme = palette.style == AppearanceStyle.amoled
        ? ShareCardTheme.amoled
        : (Theme.of(context).brightness == Brightness.dark
            ? ShareCardTheme.dark
            : ShareCardTheme.light);
    final cardTheme = _cardTheme ?? defaultTheme;

    final stats = ref.watch(userStatsProvider).value;
    final verse = ref.watch(dailyVerseProvider).value;
    final settings = ref.watch(currentSettingsProvider).value;

    final activeProfileId = _overrideProfileId ??
        (settings?.themeProfileId ?? ThemeProfiles.defaultId);
    final activeProfile = ThemeProfiles.byId(activeProfileId);

    final lang = settings?.bibleLanguage ?? 'en';
    final canon = settings?.canon ?? CanonType.catholic;
    final isMalayalam = lang == 'ml';

    final verseText = verse?.getText(lang, canon);
    final verseRef = verse?.getReference(lang, canon);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mode Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _ModeChip(
                  label: 'Invite',
                  icon: Icons.favorite_rounded,
                  isSelected: _selectedMode == ShareCardMode.invite,
                  onTap: () =>
                      setState(() => _selectedMode = ShareCardMode.invite),
                ),
                const Gap(8),
                if (verseText != null) ...[
                  _ModeChip(
                    label: 'Daily Verse',
                    icon: Icons.auto_awesome_rounded,
                    isSelected: _selectedMode == ShareCardMode.dailyVerse,
                    onTap: () => setState(
                      () => _selectedMode = ShareCardMode.dailyVerse,
                    ),
                  ),
                  const Gap(8),
                ],
                _ModeChip(
                  label: widget.completedBookName != null
                      ? 'Book Milestone'
                      : 'My Journey',
                  icon: Icons.local_fire_department_rounded,
                  isSelected: _selectedMode == ShareCardMode.progress,
                  onTap: () =>
                      setState(() => _selectedMode = ShareCardMode.progress),
                ),
              ],
            ),
          ),
          const Gap(12),

          // Appearance Controls Row: Theme Profile Pill (Left) & Brightness Toggle (Right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ThemeProfilePill(
                profile: activeProfile,
                theme: cardTheme,
                onTap: () => _showThemeProfilePicker(
                  context,
                  activeProfile,
                  cardTheme,
                ),
              ),
              _CardThemeToggle(
                theme: cardTheme,
                onToggle: () => _cycleCardTheme(cardTheme),
              ),
            ],
          ),
          const Gap(14),

          // Capturable Visual Card with ambient elevation preview
          Container(
            decoration: BoxDecoration(
              borderRadius: AppRadii.borderRadiusXL,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: cardTheme == ShareCardTheme.amoled
                        ? 0.45
                        : (cardTheme == ShareCardTheme.dark ? 0.35 : 0.08),
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: RepaintBoundary(
              key: _boundaryKey,
              child: _ShareCardPreview(
                mode: _selectedMode,
                stats: stats,
                verseText: verseText,
                verseRef: verseRef,
                isMalayalam: isMalayalam,
                theme: cardTheme,
                profile: activeProfile,
                completedBookName: widget.completedBookName,
                completedBookChapters: widget.completedBookChapters,
              ),
            ),
          ),
          const Gap(20),

          // Action Row
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _copyLink,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.borderRadiusMD,
                  ),
                ),
                icon: const Icon(Icons.link_rounded, size: 18),
                label: Text(
                  'Copy Link',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isSharing
                      ? null
                      : () => _shareCard(
                            stats: stats,
                            verseText: verseText,
                            verseRef: verseRef,
                          ),
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.borderRadiusMD,
                    ),
                  ),
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: Text(
                    _isSharing ? 'Preparing...' : 'Share Card',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _ensureLightContrast(Color color) {
  if (color.computeLuminance() > 0.32) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness * 0.52).clamp(0.18, 0.42))
        .toColor();
  }
  return color;
}

class _ShareCardPreview extends StatelessWidget {
  const _ShareCardPreview({
    required this.mode,
    required this.stats,
    required this.verseText,
    required this.verseRef,
    required this.isMalayalam,
    required this.theme,
    required this.profile,
    this.completedBookName,
    this.completedBookChapters,
  });

  final ShareCardMode mode;
  final UserStats? stats;
  final String? verseText;
  final String? verseRef;
  final bool isMalayalam;
  final ShareCardTheme theme;
  final ThemeProfile profile;
  final String? completedBookName;
  final int? completedBookChapters;

  @override
  Widget build(BuildContext context) {
    final isAmoled = theme == ShareCardTheme.amoled;
    final isDark = theme == ShareCardTheme.dark || isAmoled;
    final isVerse = mode == ShareCardMode.dailyVerse;

    final activePalette = switch (theme) {
      ShareCardTheme.light => profile.light,
      ShareCardTheme.dark => profile.dark,
      ShareCardTheme.amoled => profile.amoled,
    };

    // Dynamic, high-contrast palette definition derived from active ThemeProfile
    final List<Color> backgroundColors;
    final Color borderColor;
    final Color glowColor;
    final Color watermarkColor;
    final Color headerTitleColor;
    final Color badgeBgColor;
    final Color badgeBorderColor;
    final Color badgeTextColor;
    final Color mainTextColor;
    final Color refLineColor;
    final Color refTextColor;
    final Color dividerColor;
    final Color footerLinkColor;
    final Color footerLabelColor;
    final Color streakColor;
    final Color booksColor;
    final Color progressColor;

    if (isAmoled) {
      backgroundColors = const [Color(0xFF000000), Color(0xFF000000)];

      final accent = isVerse ? activePalette.secondary : activePalette.primary;
      borderColor = accent.withValues(alpha: 0.40);
      glowColor = accent.withValues(alpha: 0.22);
      watermarkColor = accent.withValues(alpha: 0.12);
      headerTitleColor = Colors.white;

      badgeBgColor = accent.withValues(alpha: 0.18);
      badgeBorderColor = accent.withValues(alpha: 0.40);
      badgeTextColor = accent;

      mainTextColor = Colors.white;
      refLineColor = accent.withValues(alpha: 0.90);
      refTextColor = accent;

      dividerColor = const Color(0xFF262626);
      footerLinkColor = accent;
      footerLabelColor = const Color(0xFF94A3B8);

      streakColor = context.appColors.streak;
      booksColor = activePalette.secondary;
      progressColor = context.appColors.success;
    } else if (isDark) {
      backgroundColors = [activePalette.surface, activePalette.bg];

      final accent = isVerse ? activePalette.secondary : activePalette.primary;
      borderColor = accent.withValues(alpha: 0.35);
      glowColor = accent.withValues(alpha: 0.18);
      watermarkColor = accent.withValues(alpha: 0.10);
      headerTitleColor = const Color(0xFFF8FAFC);

      badgeBgColor = accent.withValues(alpha: 0.16);
      badgeBorderColor = accent.withValues(alpha: 0.35);
      badgeTextColor = accent;

      mainTextColor = const Color(0xFFF8FAFC);
      refLineColor = accent.withValues(alpha: 0.85);
      refTextColor = accent;

      dividerColor = Colors.white.withValues(alpha: 0.14);
      footerLinkColor = accent;
      footerLabelColor = const Color(0xFF94A3B8);

      streakColor = context.appColors.streak;
      booksColor = activePalette.secondary;
      progressColor = context.appColors.success;
    } else {
      // Light Mode: ensure high contrast readability across all profiles
      final accent = _ensureLightContrast(
        isVerse ? activePalette.secondary : activePalette.primary,
      );

      if (isVerse) {
        final verseAltBg = activePalette.surfaceAlt.computeLuminance() > 0.85
            ? activePalette.surfaceAlt
            : const Color(0xFFF6F0E4);
        backgroundColors = [const Color(0xFFFFFDF9), verseAltBg];
        borderColor = accent.withValues(alpha: 0.40);
        glowColor = activePalette.secondary.withValues(alpha: 0.16);
        watermarkColor = accent.withValues(alpha: 0.13);
        headerTitleColor = const Color(0xFF0F172A);

        badgeBgColor = accent.withValues(alpha: 0.10);
        badgeBorderColor = accent.withValues(alpha: 0.35);
        badgeTextColor = accent;

        mainTextColor = const Color(0xFF0F172A);
        refLineColor = accent.withValues(alpha: 0.65);
        refTextColor = accent;

        dividerColor = accent.withValues(alpha: 0.22);
        footerLinkColor = accent;
        footerLabelColor = const Color(0xFF64748B);

        streakColor = const Color(0xFFC2410C);
        booksColor = accent;
        progressColor = const Color(0xFF0F766E);
      } else {
        final generalAltBg = activePalette.surfaceAlt.computeLuminance() > 0.85
            ? activePalette.surfaceAlt
            : const Color(0xFFF4F7FB);
        backgroundColors = [const Color(0xFFFFFFFF), generalAltBg];
        borderColor = accent.withValues(alpha: 0.30);
        glowColor = activePalette.primary.withValues(alpha: 0.10);
        watermarkColor = accent.withValues(alpha: 0.08);
        headerTitleColor = const Color(0xFF0F172A);

        badgeBgColor = accent.withValues(alpha: 0.09);
        badgeBorderColor = accent.withValues(alpha: 0.24);
        badgeTextColor = accent;

        mainTextColor = const Color(0xFF0F172A);
        refLineColor = accent.withValues(alpha: 0.60);
        refTextColor = accent;

        dividerColor = const Color(0xFFE2E8F0);
        footerLinkColor = accent;
        footerLabelColor = const Color(0xFF64748B);

        streakColor = const Color(0xFFC2410C);
        booksColor = accent;
        progressColor = const Color(0xFF0F766E);
      }
    }

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: AppRadii.borderRadiusXL,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: backgroundColors,
        ),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Top-right radial glow
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    glowColor,
                    glowColor.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          // Oversized decorative serif quotation watermark
          Positioned(
            right: 16,
            bottom: -36,
            child: IgnorePointer(
              child: Text(
                '“',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 130,
                  height: 1,
                  color: watermarkColor,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/app_icon.png',
                            width: 26,
                            height: 26,
                          ),
                        ),
                        const Gap(10),
                        Text(
                          'Verso',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 20,
                            color: headerTitleColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: AppRadii.borderRadiusFull,
                        border: Border.all(color: badgeBorderColor),
                      ),
                      child: Text(
                        isVerse
                            ? (isMalayalam
                                ? 'ഇന്നത്തെ വചനം'
                                : 'VERSE OF THE DAY')
                            : 'BIBLE TRACKER',
                        style: isVerse && isMalayalam
                            ? GoogleFonts.anekMalayalam(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: badgeTextColor,
                              )
                            : GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: badgeTextColor,
                              ),
                      ),
                    ),
                  ],
                ),
                const Gap(20),

                // Body Content
                if (isVerse && verseText != null) ...[
                  Text(
                    verseText!,
                    style: isMalayalam
                        ? GoogleFonts.anekMalayalam(
                            fontSize: 17.5,
                            height: 1.55,
                            fontWeight: FontWeight.w600,
                            color: mainTextColor,
                          )
                        : GoogleFonts.dmSerifDisplay(
                            fontSize: 19.5,
                            height: 1.45,
                            color: mainTextColor,
                          ),
                  ),
                  const Gap(14),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 2,
                        decoration: BoxDecoration(
                          color: refLineColor,
                          borderRadius: AppRadii.borderRadiusFull,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        isMalayalam
                            ? (verseRef ?? '')
                            : (verseRef ?? '').toUpperCase(),
                        style: isMalayalam
                            ? GoogleFonts.anekMalayalam(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: refTextColor,
                              )
                            : GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                color: refTextColor,
                              ),
                      ),
                    ],
                  ),
                ] else if (mode == ShareCardMode.progress &&
                    completedBookName != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        color: booksColor,
                        size: 28,
                      ),
                      const Gap(10),
                      Expanded(
                        child: Text(
                          completedBookName!,
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 24,
                            color: headerTitleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(6),
                  Text(
                    'Completed all $completedBookChapters chapters on Verso!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: booksColor,
                    ),
                  ),
                ] else if (mode == ShareCardMode.progress) ...[
                  Text(
                    'My Bible Journey',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 21,
                      color: headerTitleColor,
                    ),
                  ),
                  const Gap(14),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _MiniStatMetric(
                          label: 'Streak',
                          value: '${stats?.streak ?? 0}d 🔥',
                          color: streakColor,
                          theme: theme,
                        ),
                        const Gap(10),
                        _MiniStatMetric(
                          label: 'Books completed',
                          value: '${stats?.booksCompleted ?? 0}',
                          color: booksColor,
                          theme: theme,
                        ),
                        const Gap(10),
                        _MiniStatMetric(
                          label: 'Bible completed',
                          value:
                              '${(stats?.totalProgress ?? 0).toStringAsFixed(1)}%',
                          color: progressColor,
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Text(
                    "Let's read the Bible together.",
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 22,
                      height: 1.25,
                      color: mainTextColor,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'A simple, beautiful way to read Bible every day, track your progress, and build a habit that lasts.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      height: 1.45,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF334155),
                    ),
                  ),
                ],

                const Gap(20),
                Divider(
                  color: dividerColor,
                  height: 1,
                ),
                const Gap(12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'versobibletracker.netlify.app',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: footerLinkColor,
                      ),
                    ),
                    Text(
                      'Read with me →',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: footerLabelColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatMetric extends StatelessWidget {
  const _MiniStatMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  final String label;
  final String value;
  final Color color;
  final ShareCardTheme theme;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isAmoled = theme == ShareCardTheme.amoled;
    final isDark = theme == ShareCardTheme.dark || isAmoled;

    final bgColor = isAmoled
        ? const Color(0xFF0D0D0D)
        : (isDark ? color.withValues(alpha: 0.12) : Colors.white);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadii.borderRadiusMD,
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.35 : 0.38),
            width: isDark ? 1.0 : 1.2,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? (isAmoled ? Colors.white : scheme.onSurface)
                    : color,
              ),
            ),
            const Gap(4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: isDark
                    ? (isAmoled
                        ? const Color(0xFFA3A3A3)
                        : scheme.onSurfaceVariant)
                    : const Color(0xFF475569),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeProfilePill extends StatelessWidget {
  const _ThemeProfilePill({
    required this.profile,
    required this.theme,
    required this.onTap,
  });

  final ThemeProfile profile;
  final ShareCardTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = switch (theme) {
      ShareCardTheme.light => profile.light,
      ShareCardTheme.dark => profile.dark,
      ShareCardTheme.amoled => profile.amoled,
    };

    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
      shape: StadiumBorder(
        side: BorderSide(
          color: scheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: SizedBox(
          height: 36,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Two-tone mini swatch
                SizedBox(
                  width: 14,
                  height: 14,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: palette.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: palette.secondary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: scheme.surface,
                              width: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(7),
                Text(
                  profile.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const Gap(2),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeProfilePickerTile extends StatelessWidget {
  const _ThemeProfilePickerTile({
    required this.profile,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  final ThemeProfile profile;
  final bool isSelected;
  final ShareCardTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = switch (theme) {
      ShareCardTheme.light => profile.light,
      ShareCardTheme.dark => profile.dark,
      ShareCardTheme.amoled => profile.amoled,
    };

    return Material(
      color: isSelected
          ? scheme.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      borderRadius: AppRadii.borderRadiusMD,
      child: InkWell(
        borderRadius: AppRadii.borderRadiusMD,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Two-tone swatches
              SizedBox(
                width: 32,
                height: 32,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: palette.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: scheme.surface,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: palette.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: scheme.surface,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: scheme.onSurface,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      profile.tagline,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelected) ...[
                const Gap(8),
                Icon(
                  Icons.check_circle_rounded,
                  color: scheme.primary,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CardThemeToggle extends StatelessWidget {
  const _CardThemeToggle({
    required this.theme,
    required this.onToggle,
  });

  final ShareCardTheme theme;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (emoji, tooltip) = switch (theme) {
      ShareCardTheme.light => ('☀️', 'Light card (tap for Dark)'),
      ShareCardTheme.dark => ('🌙', 'Dark card (tap for AMOLED)'),
      ShareCardTheme.amoled => ('🖤', 'AMOLED card (tap for Light)'),
    };

    return Tooltip(
      message: tooltip,
      child: Material(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        shape: CircleBorder(
          side: BorderSide(
            color: scheme.outline.withValues(alpha: 0.15),
          ),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onToggle,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primary
              : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: AppRadii.borderRadiusFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
            const Gap(6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
