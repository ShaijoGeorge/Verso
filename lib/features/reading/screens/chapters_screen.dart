import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:verso/core/design/components/verso_circular_progress.dart';
import 'package:verso/core/design/components/verso_confetti.dart';
import 'package:verso/core/design/components/verso_progress_bar.dart';
import 'package:verso/core/design/components/verso_snackbar.dart';
import 'package:verso/core/design/extensions.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/shadows.dart';
import 'package:verso/core/design/tokens/spacing.dart';
import 'package:verso/core/utils/app_error_handler.dart';
import 'package:verso/core/widgets/error_state_widget.dart';
import 'package:verso/data/bible_book_names.dart';
import 'package:verso/data/bible_data.dart';
import 'package:verso/data/local/entities/reading_progress.dart';
import 'package:verso/features/reading/providers/reading_providers.dart';
import 'package:verso/features/reading/services/reading_service.dart';
import 'package:verso/features/settings/providers/settings_providers.dart';

class ChaptersScreen extends ConsumerStatefulWidget {
  const ChaptersScreen({required this.book, super.key});
  final BibleBook book;

  @override
  ConsumerState<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends ConsumerState<ChaptersScreen> {
  bool _isMarkingRead = false;

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(bookProgressProvider(widget.book.id));
    final settings = switch (ref.watch(currentSettingsProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final bibleLanguage = settings?.bibleLanguage ?? 'en';
    final canon = settings?.canon ?? CanonType.catholic;
    final localizedBookName =
        widget.book.getLocalizedName(bibleLanguage, canon);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizedBookName),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed:
                  _isMarkingRead ? null : () => _markAllRead(localizedBookName),
              style: TextButton.styleFrom(
                backgroundColor: scheme.primary.withValues(alpha: 0.1),
                foregroundColor: scheme.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadii.borderRadiusFull,
                ),
              ),
              icon: _isMarkingRead
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.done_all_rounded, size: 17),
              label: const Text(
                'Mark All',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(progressAsync, bibleLanguage, canon, localizedBookName),
    );
  }

  Widget _buildBody(
    AsyncValue<List<ReadingProgress>> progressAsync,
    String bibleLanguage,
    CanonType canon,
    String localizedBookName,
  ) {
    // On first load (no data yet), show spinner.
    // On refresh (provider invalidated but previous data exists), keep
    // showing the grid so tiles don't vanish and blink.
    if (progressAsync.isLoading && !progressAsync.hasValue) {
      return const Center(child: CircularProgressIndicator());
    }
    if (progressAsync.hasError && !progressAsync.hasValue) {
      return ErrorStateWidget(
        error: progressAsync.error!,
        onRetry: () => ref.invalidate(bookProgressProvider(widget.book.id)),
      );
    }

    final progressList = progressAsync.value ?? [];
    final readDataMap = <int, DateTime?>{};
    var readCount = 0;

    for (final p in progressList) {
      if (p.isRead) {
        readDataMap[p.chapterNumber] = p.readAt;
        readCount++;
      }
    }

    final progress =
        widget.book.chapters > 0 ? readCount / widget.book.chapters : 0.0;
    final isComplete = readCount >= widget.book.chapters;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _HeroHeader(
            book: widget.book,
            readCount: readCount,
            progress: progress,
            isComplete: isComplete,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CHAPTERS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  'Tap to log · Long-press for details',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.75),
                      ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 72,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final chapterNum = index + 1;
                final isRead = readDataMap.containsKey(chapterNum);
                final readAt = readDataMap[chapterNum];

                return _ChapterTile(
                  bookName: localizedBookName,
                  chapterNum: chapterNum,
                  isRead: isRead,
                  readAt: readAt,
                  onTap: (newStatus) async {
                    final newStreak =
                        await ref.read(readingServiceProvider).toggleChapter(
                              widget.book.id,
                              chapterNum,
                              newStatus,
                            );
                    if (newStreak != null && context.mounted) {
                      VersoConfetti.show(context, streak: newStreak);
                    }
                  },
                );
              },
              childCount: widget.book.chapters,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _markAllRead(String localizedBookName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderRadiusXL),
        title: const Text('Mark all as read?'),
        content: Text(
          'This will mark all ${widget.book.chapters} chapters of $localizedBookName as read.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Mark Read'),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      setState(() => _isMarkingRead = true);
      try {
        final newStreak = await ref
            .read(readingServiceProvider)
            .markBookAsRead(widget.book.id, widget.book.chapters);
        if (mounted) {
          if (newStreak != null) {
            VersoConfetti.show(context, streak: newStreak);
          } else {
            VersoSnackbar.success(context, message: 'Marked as read!');
          }
        }
      } catch (e) {
        if (mounted) {
          VersoSnackbar.error(
            context,
            message: 'Failed: ${AppErrorHandler.getMessage(e)}',
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isMarkingRead = false);
        }
      }
    }
  }
}

// HERO HEADER

class _HeroHeader extends ConsumerWidget {
  const _HeroHeader({
    required this.book,
    required this.readCount,
    required this.progress,
    required this.isComplete,
  });
  final BibleBook book;
  final int readCount;
  final double progress;
  final bool isComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final palette = context.palette;

    final settings = switch (ref.watch(currentSettingsProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final bibleLanguage = settings?.bibleLanguage ?? 'en';
    final canon = settings?.canon ?? CanonType.catholic;
    final localizedBookName = book.getLocalizedName(bibleLanguage, canon);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.surface,
            palette.primary.withValues(alpha: isLight ? 0.08 : 0.16),
          ],
        ),
        borderRadius: AppRadii.borderRadiusXL,
        border: Border.all(
          color: palette.primary.withValues(alpha: isLight ? 0.2 : 0.28),
        ),
        boxShadow: isLight ? AppShadows.md : AppShadows.none,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    palette.primary.withValues(alpha: 0.14),
                    palette.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Row(
              children: [
                // Left: Book info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: palette.primary
                              .withValues(alpha: isLight ? 0.1 : 0.2),
                          borderRadius: AppRadii.borderRadiusFull,
                        ),
                        child: Text(
                          book.category
                              .getLocalizedDisplayName(bibleLanguage)
                              .toUpperCase(),
                          style: textTheme.labelSmall?.copyWith(
                            color: palette.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 9.5,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const Gap(12),

                      // Book name
                      Text(
                        localizedBookName,
                        style: textTheme.displaySmall?.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                      const Gap(4),

                      // Chapter count
                      Text(
                        '${book.chapters} Chapters · $readCount Read',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const Gap(Spacing.md),

                      // Progress bar
                      VersoProgressBar(
                        value: progress,
                        height: 6,
                        color: palette.primary,
                        label: '$readCount / ${book.chapters}',
                      ),

                      // Completion badge
                      if (isComplete) ...[
                        const Gap(Spacing.md),
                        _CompletedBadge(),
                      ],
                    ],
                  ),
                ),
                const Gap(Spacing.md),

                // Right: Circular progress
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: progress * 100),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (context, val, _) {
                    return VersoCircularProgress(
                      progress: val,
                      size: 84,
                      strokeWidth: 7.5,
                      color: palette.primary,
                      child: Text(
                        '${val.toInt()}%',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: palette.primary,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// COMPLETED BADGE

class _CompletedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Vibrant green-teal gradient for the achievement feel
    final gradientColors = [
      context.appColors.success,
      context.appColors.chapters,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
        ),
        borderRadius: AppRadii.borderRadiusFull,
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: 14,
            color: Colors.white,
          ),
          const Gap(Spacing.xs),
          Text(
            'Completed',
            style: textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHAPTER TILE
// ─────────────────────────────────────────────────────────────────────────────

class _ChapterTile extends StatefulWidget {
  const _ChapterTile({
    required this.bookName,
    required this.chapterNum,
    required this.isRead,
    required this.onTap,
    this.readAt,
  });
  final String bookName;
  final int chapterNum;
  final bool isRead;
  final DateTime? readAt;
  final void Function(bool newStatus) onTap;

  @override
  State<_ChapterTile> createState() => _ChapterTileState();
}

class _ChapterTileState extends State<_ChapterTile>
    with SingleTickerProviderStateMixin {
  late bool _isRead;
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  // Guards the optimistic state so intermediate provider rebuilds
  // don't revert the tile and cause visual blinks.
  bool _isOptimistic = false;

  @override
  void initState() {
    super.initState();
    _isRead = widget.isRead;
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1, end: 0.9).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ChapterTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRead != widget.isRead) {
      if (_isOptimistic && widget.isRead != _isRead) {
        // Provider hasn't caught up yet — keep the optimistic state
        return;
      }
      // Provider confirmed or changed externally — accept it without animation
      _isOptimistic = false;
      _isRead = widget.isRead;
    }
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    _scaleCtrl.forward().then((_) => _scaleCtrl.reverse());
    _isOptimistic = true;
    setState(() => _isRead = !_isRead);
    widget.onTap(_isRead);
  }

  // Cache decoration objects to prevent AnimatedContainer from
  // re-animating on every rebuild when the value hasn't changed.
  // ignore: use_late_for_private_fields_and_variables
  BoxDecoration? _cachedDecoration;
  bool? _cachedIsRead;
  Brightness? _cachedBrightness;
  Color? _cachedPrimary;
  Color? _cachedSurface;

  BoxDecoration _getDecoration(ColorScheme scheme, bool isLight) {
    if (_cachedIsRead == _isRead &&
        _cachedBrightness == (isLight ? Brightness.light : Brightness.dark) &&
        _cachedPrimary == context.palette.primary &&
        _cachedSurface == scheme.surface) {
      return _cachedDecoration!;
    }
    _cachedIsRead = _isRead;
    _cachedBrightness = isLight ? Brightness.light : Brightness.dark;
    _cachedPrimary = context.palette.primary;
    _cachedSurface = scheme.surface;
    _cachedDecoration = BoxDecoration(
      gradient: _isRead
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.palette.primary,
                context.palette.primaryHover,
              ],
            )
          : null,
      color: _isRead ? null : scheme.surface,
      borderRadius: AppRadii.borderRadiusMD,
      border: _isRead
          ? Border.all(color: Colors.white.withValues(alpha: 0.18))
          : Border.all(
              color: scheme.outline.withValues(alpha: isLight ? 0.65 : 0.25),
            ),
      boxShadow: _isRead
          ? [
              BoxShadow(
                color: context.palette.primary.withValues(alpha: 0.28),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ]
          : (isLight ? AppShadows.sm : AppShadows.none),
    );
    return _cachedDecoration!;
  }

  void _handleLongPress() {
    HapticFeedback.mediumImpact();
    _showChapterInfoSheet();
  }

  void _showChapterInfoSheet() {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isRead = widget.isRead;
    final readAt = widget.readAt;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: AppRadii.borderRadiusXXL,
            border: Border.all(
              color: scheme.outline.withValues(alpha: isLight ? 0.35 : 0.5),
            ),
            boxShadow: AppShadows.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top accent bar
              Container(
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                decoration: BoxDecoration(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.25),
                  borderRadius: AppRadii.borderRadiusFull,
                ),
              ),

              // Header with gradient
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(Spacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isRead
                        ? (isLight
                            ? [
                                context.palette.primary,
                                context.palette.primaryHover,
                              ]
                            : [
                                context.palette.primary.withValues(alpha: 0.22),
                                context.palette.primary.withValues(alpha: 0.1),
                              ])
                        : [
                            scheme.surfaceContainerHighest,
                            scheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                          ],
                  ),
                  borderRadius: AppRadii.borderRadiusXL,
                ),
                child: Column(
                  children: [
                    // Large chapter number
                    Text(
                      '${widget.chapterNum}',
                      style: textTheme.displayLarge?.copyWith(
                        color: isRead
                            ? (isLight
                                ? scheme.onPrimary
                                : context.palette.primary)
                            : scheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        fontSize: 48,
                        height: 1,
                      ),
                    ),
                    const Gap(Spacing.xs),
                    Text(
                      widget.bookName,
                      style: textTheme.titleSmall?.copyWith(
                        color: isRead
                            ? (isLight
                                ? scheme.onPrimary.withValues(alpha: 0.85)
                                : context.palette.primary
                                    .withValues(alpha: 0.85))
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                    const Gap(Spacing.md),

                    // Status pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isRead
                            ? (isLight
                                ? scheme.onPrimary.withValues(alpha: 0.2)
                                : context.palette.primary
                                    .withValues(alpha: 0.28))
                            : scheme.outline.withValues(alpha: 0.12),
                        borderRadius: AppRadii.borderRadiusFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isRead
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 14,
                            color: isRead
                                ? (isLight
                                    ? scheme.onPrimary
                                    : context.palette.primary)
                                : scheme.onSurfaceVariant,
                          ),
                          const Gap(6),
                          Text(
                            isRead ? 'Read' : 'Not yet read',
                            style: textTheme.labelMedium?.copyWith(
                              color: isRead
                                  ? (isLight
                                      ? scheme.onPrimary
                                      : context.palette.primary)
                                  : scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Timestamp detail (only if read)
              if (isRead && readAt != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(Spacing.md),
                    decoration: BoxDecoration(
                      color: isLight
                          ? scheme.primary.withValues(alpha: 0.05)
                          : scheme.primary.withValues(alpha: 0.09),
                      borderRadius: AppRadii.borderRadiusMD,
                      border: Border.all(
                        color: scheme.primary
                            .withValues(alpha: isLight ? 0.14 : 0.12),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Calendar icon container
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: scheme.primary
                                .withValues(alpha: isLight ? 0.1 : 0.16),
                            borderRadius: AppRadii.borderRadiusSM,
                          ),
                          child: Icon(
                            Icons.calendar_today_rounded,
                            size: 20,
                            color: context.palette.primary,
                          ),
                        ),
                        const Gap(Spacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('EEEE, MMMM d, yyyy').format(readAt),
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: context.palette.primary,
                                ),
                              ),
                              const Gap(2),
                              Text(
                                'Logged at ${DateFormat('h:mm a').format(readAt)}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Unread hint
              if (!isRead)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    'Tap the chapter tile to mark it as read.',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Safe area + bottom padding
              Gap(Spacing.lg + MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return GestureDetector(
      onTap: _handleTap,
      onLongPress: _handleLongPress,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          decoration: _getDecoration(scheme, isLight),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '${widget.chapterNum}',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: _isRead
                      ? scheme.onPrimary
                      : scheme.onSurface.withValues(alpha: 0.85),
                ),
              ),
              if (_isRead)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Icon(
                    Icons.check_rounded,
                    size: 11.5,
                    color: scheme.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
