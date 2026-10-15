import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:verso/core/design/components/verso_bottom_sheet.dart';
import 'package:verso/core/design/components/verso_card.dart';
import 'package:verso/core/design/components/verso_chip.dart';
import 'package:verso/core/design/components/verso_empty_state.dart';
import 'package:verso/core/design/extensions.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/shadows.dart';
import 'package:verso/core/widgets/error_state_widget.dart';
import 'package:verso/data/bible_book_names.dart';
import 'package:verso/data/bible_data.dart';
import 'package:verso/features/settings/providers/settings_providers.dart';
import 'package:verso/features/stats/providers/activity_providers.dart';
import 'package:verso/features/stats/widgets/shimmer_skeletons.dart';

class ActivityLogScreen extends ConsumerStatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  ConsumerState<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends ConsumerState<ActivityLogScreen> {
  Future<void> _onRefresh() async {
    HapticFeedback.mediumImpact();
    ref.invalidate(activityLogProvider);
    // Wait for the provider to complete its fetch
    await ref.read(activityLogProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final activityAsync = ref.watch(activityLogProvider);
    final filter = ref.watch(activityFilterStateProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Screen Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CHRONOLOGICAL TIMELINE',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.3,
                  fontSize: 10,
                ),
              ),
              const Gap(4),
              Text(
                'Reading Journal',
                style: textTheme.headlineLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),

        // Filter Bar
        _FilterBar(ref: ref, filter: filter, colorScheme: colorScheme),

        // Content
        Expanded(
          child: activityAsync.when(
            loading: () => const ActivityLogShimmer(),
            error: (e, _) => ErrorStateWidget(
              error: e,
              onRetry: () => ref.invalidate(activityLogProvider),
            ),
            data: (grouped) {
              if (grouped.isEmpty) {
                return VersoEmptyState(
                  icon: filter.isActive
                      ? Icons.filter_list_off_rounded
                      : Icons.history_edu_rounded,
                  title: filter.isActive
                      ? 'No Matching Entries'
                      : 'Your Journal is Empty',
                  subtitle: filter.isActive
                      ? 'Try adjusting or clearing your book and date filters.'
                      : 'Chapters you mark as read will appear here in a chronological timeline.',
                  actionLabel: filter.isActive ? 'Clear Filters' : null,
                  onAction: filter.isActive
                      ? () {
                          ref
                              .read(activityFilterStateProvider.notifier)
                              .clearFilters();
                        }
                      : null,
                );
              }

              // Sorted date keys (newest first)
              final dateKeys = grouped.keys.toList()
                ..sort((a, b) => b.compareTo(a));

              return RefreshIndicator(
                onRefresh: _onRefresh,
                color: colorScheme.primary,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // Top padding
                    const SliverPadding(padding: EdgeInsets.only(top: 6)),

                    for (int di = 0; di < dateKeys.length; di++) ...[
                      SliverMainAxisGroup(
                        slivers: [
                          // Sticky Date Header
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _StickyDateHeaderDelegate(
                              date: dateKeys[di],
                              colorScheme: colorScheme,
                            ),
                          ),
                          // Activity Items for this date
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverList.builder(
                              itemCount: grouped[dateKeys[di]]!.length,
                              itemBuilder: (context, index) {
                                final entries = grouped[dateKeys[di]]!;
                                final group = entries[index];
                                final isLast = (di == dateKeys.length - 1) &&
                                    (index == entries.length - 1);

                                return _ActivityCard(
                                  group: group,
                                  isLast: isLast,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Bottom safe area
                    const SliverPadding(padding: EdgeInsets.only(bottom: 110)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// FILTER BAR

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.ref,
    required this.filter,
    required this.colorScheme,
  });
  final WidgetRef ref;
  final ActivityFilter filter;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(booksWithActivityProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: Row(
        children: [
          // Book Filter Chip
          Expanded(
            child: booksAsync.when(
              loading: () => _buildPlaceholder(colorScheme),
              error: (_, __) => _buildPlaceholder(colorScheme),
              data: (books) {
                final settings = switch (ref.watch(currentSettingsProvider)) {
                  AsyncData(:final value) => value,
                  _ => null,
                };
                final bibleLanguage = settings?.bibleLanguage ?? 'en';
                final canon = settings?.canon ?? CanonType.catholic;

                final selectedBook = filter.bookId != null
                    ? BibleData.findBookById(filter.bookId!)
                    : null;

                final isActive = filter.bookId != null;

                return GestureDetector(
                  onTap: () => _showBookPicker(
                    context,
                    books,
                    bibleLanguage,
                    canon,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? colorScheme.primary.withValues(alpha: 0.1)
                          : colorScheme.surface,
                      borderRadius: AppRadii.borderRadiusMD,
                      border: Border.all(
                        color: isActive
                            ? colorScheme.primary.withValues(alpha: 0.35)
                            : colorScheme.outline.withValues(
                                alpha: isLight ? 0.65 : 0.25,
                              ),
                      ),
                      boxShadow: isLight ? AppShadows.sm : AppShadows.none,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 16,
                          color: isActive
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                        const Gap(8),
                        Flexible(
                          child: Text(
                            selectedBook?.getLocalizedName(
                                  bibleLanguage,
                                  canon,
                                ) ??
                                'All Books',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  isActive ? FontWeight.w700 : FontWeight.w600,
                              color: isActive
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Gap(4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Gap(8),

          // Date Range Chip
          GestureDetector(
            onTap: () => _showDatePicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: filter.startDate != null
                    ? colorScheme.primary.withValues(alpha: 0.1)
                    : colorScheme.surface,
                borderRadius: AppRadii.borderRadiusMD,
                border: Border.all(
                  color: filter.startDate != null
                      ? colorScheme.primary.withValues(alpha: 0.35)
                      : colorScheme.outline.withValues(
                          alpha: isLight ? 0.65 : 0.25,
                        ),
                ),
                boxShadow: isLight ? AppShadows.sm : AppShadows.none,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: filter.startDate != null
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  const Gap(6),
                  Text(
                    _dateLabel(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: filter.startDate != null
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: filter.startDate != null
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Clear Filters button
          if (filter.isActive) ...[
            const Gap(8),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(activityFilterStateProvider.notifier).clearFilters();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: AppRadii.borderRadiusMD,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: AppRadii.borderRadiusMD,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 16,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const Gap(8),
          Flexible(
            child: Text(
              'All Books',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _dateLabel() {
    if (filter.startDate == null) return 'All Time';

    final now = DateTime.now();
    final start = filter.startDate!;
    final end = filter.endDate;

    final startFmt = DateFormat(start.year == now.year ? 'MMM d' : 'MMM d, y');

    if (end == null) {
      return 'From ${startFmt.format(start)}';
    }

    // If both dates are in the same year, but NOT the current year,
    // only append the year to the end date (e.g. "Dec 1 - Dec 31, 2025").
    if (start.year == end.year && start.year != now.year) {
      final startFmtNoYear = DateFormat('MMM d');
      final endFmtYear = DateFormat('MMM d, y');
      return '${startFmtNoYear.format(start)} – ${endFmtYear.format(end)}';
    }

    final endFmt = DateFormat(end.year == now.year ? 'MMM d' : 'MMM d, y');
    return '${startFmt.format(start)} – ${endFmt.format(end)}';
  }

  void _showBookPicker(
    BuildContext context,
    List<BibleBook> books,
    String bibleLanguage,
    CanonType canon,
  ) {
    VersoBottomSheet.show<void>(
      context: context,
      title: 'Filter by Book',
      contentPadding: EdgeInsets.zero,
      child: Builder(
        builder: (ctx) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: ListView(
              children: [
                // "All Books" option
                ListTile(
                  leading: Icon(
                    Icons.library_books_rounded,
                    color: filter.bookId == null ? colorScheme.primary : null,
                  ),
                  title: const Text('All Books'),
                  selected: filter.bookId == null,
                  selectedColor: colorScheme.primary,
                  onTap: () {
                    ref
                        .read(activityFilterStateProvider.notifier)
                        .setBookFilter(null);
                    Navigator.pop(ctx);
                  },
                ),
                const Divider(),
                ...books.map(
                  (book) => ListTile(
                    leading: Icon(
                      Icons.book_rounded,
                      color:
                          filter.bookId == book.id ? colorScheme.primary : null,
                    ),
                    title: Text(
                      book.getLocalizedName(bibleLanguage, canon),
                    ),
                    selected: filter.bookId == book.id,
                    selectedColor: colorScheme.primary,
                    onTap: () {
                      ref
                          .read(activityFilterStateProvider.notifier)
                          .setBookFilter(book.id);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDateRange: filter.startDate != null && filter.endDate != null
          ? DateTimeRange(start: filter.startDate!, end: filter.endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      ref
          .read(activityFilterStateProvider.notifier)
          .setDateRange(result.start, result.end);
    }
  }
}

// STICKY DATE HEADER DELEGATE

class _StickyDateHeaderDelegate extends SliverPersistentHeaderDelegate {
  _StickyDateHeaderDelegate({required this.date, required this.colorScheme});
  final DateTime date;
  final ColorScheme colorScheme;

  @override
  double get minExtent => 46;
  @override
  double get maxExtent => 46;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      color: scaffoldBg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: AppRadii.borderRadiusFull,
              boxShadow: overlapsContent
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              _formatDateLabel(date),
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Divider(
              color: colorScheme.outline.withValues(alpha: 0.16),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Using calendar math instead of subtract(Duration())
    // prevents Daylight Saving Time 23/25 hour bugs!
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) return 'Today';
    if (checkDate == yesterday) return 'Yesterday';
    return DateFormat('MMMM d, y').format(date);
  }

  @override
  bool shouldRebuild(covariant _StickyDateHeaderDelegate oldDelegate) {
    return date != oldDelegate.date || colorScheme != oldDelegate.colorScheme;
  }
}

// ACTIVITY CARD (TIMELINE ENTRY)

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.group, required this.isLast});
  final ActivityGroup group;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isBulk = group.isBulkAction;

    final nodeColor = group.isFinish
        ? context.appColors.books
        : (isBulk ? context.appColors.otColor : context.appColors.chapters);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline
          Column(
            children: [
              Container(
                width: 2,
                height: 16,
                color: colorScheme.outline.withValues(alpha: 0.25),
              ),
              // Icon badge
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: nodeColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: nodeColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Icon(
                  group.isFinish
                      ? Icons.emoji_events_rounded
                      : (isBulk
                          ? Icons.done_all_rounded
                          : Icons.auto_stories_rounded),
                  size: 15,
                  color: nodeColor,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast
                      ? Colors.transparent
                      : colorScheme.outline.withValues(alpha: 0.25),
                ),
              ),
            ],
          ),
          const Gap(14),

          // Card Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: group.isFinish
                  ? _CompletionCard(group: group)
                  : _StandardCard(group: group, isBulk: isBulk),
            ),
          ),
        ],
      ),
    );
  }
}

// STANDARD CARD

class _StandardCard extends ConsumerWidget {
  const _StandardCard({required this.group, required this.isBulk});
  final ActivityGroup group;
  final bool isBulk;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final settings = switch (ref.watch(currentSettingsProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final bibleLanguage = settings?.bibleLanguage ?? 'en';
    final canon = settings?.canon ?? CanonType.catholic;

    return VersoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  group.book.getLocalizedName(bibleLanguage, canon),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15.5,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                DateFormat('h:mm a').format(group.timestamp),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const Gap(8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              VersoChip(
                text: group.timeOfDay,
                color: colorScheme.primary,
              ),
              if (isBulk)
                VersoChip.icon(
                  text: 'Mass Update',
                  icon: Icons.done_all_rounded,
                  color: context.appColors.otColor,
                ),
            ],
          ),
          const Gap(8),
          Text(
            group.description,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ENHANCED COMPLETION CARD

class _CompletionCard extends ConsumerWidget {
  const _CompletionCard({required this.group});
  final ActivityGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final goldColor = context.appColors.books;

    final settings = switch (ref.watch(currentSettingsProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final bibleLanguage = settings?.bibleLanguage ?? 'en';
    final canon = settings?.canon ?? CanonType.catholic;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: AppRadii.borderRadiusLG,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  goldColor.withValues(alpha: 0.16),
                  scheme.surface,
                ]
              : [
                  goldColor.withValues(alpha: 0.1),
                  scheme.surface,
                ],
        ),
        border: Border.all(
          color: goldColor.withValues(alpha: isDark ? 0.4 : 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: goldColor.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative sparkles
          Positioned(
            right: 14,
            top: 10,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: goldColor.withValues(alpha: 0.3),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    // Glowing trophy
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: goldColor.withValues(alpha: 0.16),
                        borderRadius: AppRadii.borderRadiusSM,
                      ),
                      child: Icon(
                        Icons.emoji_events_rounded,
                        size: 22,
                        color: goldColor,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.book.getLocalizedName(bibleLanguage, canon),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16.5,
                              color: scheme.onSurface,
                            ),
                          ),
                          const Gap(2),
                          Text(
                            'Book Completed!',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: goldColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      DateFormat('h:mm a').format(group.timestamp),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Gap(12),
                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    VersoChip(
                      text: group.timeOfDay,
                      color: goldColor,
                    ),
                    VersoChip.icon(
                      text: '${group.book.chapters} Chapters',
                      icon: Icons.star_rounded,
                      color: goldColor,
                    ),
                  ],
                ),
                const Gap(8),
                Text(
                  group.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
