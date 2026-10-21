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

  static const String _appUrl = 'https://versobibletracker.netlify.app/';

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.completedBookName != null
        ? ShareCardMode.progress
        : widget.initialMode;
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
    final stats = ref.watch(userStatsProvider).value;
    final verse = ref.watch(dailyVerseProvider).value;
    final settings = ref.watch(currentSettingsProvider).value;

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
          const Gap(16),

          // Capturable Visual Card
          RepaintBoundary(
            key: _boundaryKey,
            child: _ShareCardPreview(
              mode: _selectedMode,
              stats: stats,
              verseText: verseText,
              verseRef: verseRef,
              isMalayalam: isMalayalam,
              completedBookName: widget.completedBookName,
              completedBookChapters: widget.completedBookChapters,
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

class _ShareCardPreview extends StatelessWidget {
  const _ShareCardPreview({
    required this.mode,
    required this.stats,
    required this.verseText,
    required this.verseRef,
    required this.isMalayalam,
    this.completedBookName,
    this.completedBookChapters,
  });

  final ShareCardMode mode;
  final UserStats? stats;
  final String? verseText;
  final String? verseRef;
  final bool isMalayalam;
  final String? completedBookName;
  final int? completedBookChapters;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isAmoled = context.palette.style == AppearanceStyle.amoled;
    final isVerse = mode == ShareCardMode.dailyVerse;

    final accentColor = isVerse ? scheme.secondary : scheme.primary;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isAmoled ? const Color(0xFF0B0D14) : scheme.surface,
        borderRadius: AppRadii.borderRadiusXL,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isAmoled
              ? [const Color(0xFF0B0D14), Colors.black]
              : [
                  scheme.surface,
                  scheme.primaryContainer.withValues(alpha: 0.48),
                ],
        ),
        border: Border.all(
          color: accentColor.withValues(alpha: isLight ? 0.35 : 0.3),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Top-right radial glow matching _DailyVerseCard
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
                    accentColor.withValues(alpha: 0.18),
                    accentColor.withValues(alpha: 0),
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
                  color: accentColor.withValues(alpha: 0.08),
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
                            color: scheme.onSurface,
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
                        color: accentColor.withValues(alpha: 0.14),
                        borderRadius: AppRadii.borderRadiusFull,
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
                                color: accentColor,
                              )
                            : GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: accentColor,
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
                            fontWeight: FontWeight.w500,
                            color: scheme.onSurface,
                          )
                        : GoogleFonts.dmSerifDisplay(
                            fontSize: 19.5,
                            height: 1.4,
                            color: scheme.onSurface,
                          ),
                  ),
                  const Gap(14),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 1.5,
                        color: scheme.secondary.withValues(alpha: 0.8),
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
                                color: scheme.secondary,
                              )
                            : GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                color: scheme.secondary,
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
                        color: context.appColors.books,
                        size: 28,
                      ),
                      const Gap(10),
                      Expanded(
                        child: Text(
                          completedBookName!,
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 24,
                            color: scheme.onSurface,
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
                      color: context.appColors.books,
                    ),
                  ),
                ] else if (mode == ShareCardMode.progress) ...[
                  Text(
                    'My Bible Journey',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 21,
                      color: scheme.onSurface,
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
                          color: context.appColors.streak,
                        ),
                        const Gap(10),
                        _MiniStatMetric(
                          label: 'Books completed',
                          value: '${stats?.booksCompleted ?? 0}',
                          color: context.appColors.books,
                        ),
                        const Gap(10),
                        _MiniStatMetric(
                          label: 'Bible completed',
                          value:
                              '${(stats?.totalProgress ?? 0).toStringAsFixed(1)}%',
                          color: context.appColors.success,
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
                      color: scheme.onSurface,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'A simple, beautiful way to read Bible every day, track your progress, and build a habit that lasts.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      height: 1.45,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],

                const Gap(20),
                Divider(
                  color: scheme.outline.withValues(alpha: 0.18),
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
                        color: accentColor,
                      ),
                    ),
                    Text(
                      'Read with me →',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
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
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: AppRadii.borderRadiusMD,
          border: Border.all(color: color.withValues(alpha: 0.25)),
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
                color: scheme.onSurface,
              ),
            ),
            const Gap(4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: scheme.onSurfaceVariant,
              ),
              maxLines: 2,
            ),
          ],
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
