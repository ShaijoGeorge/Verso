import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../data/bible_data.dart';
import '../providers/activity_providers.dart';
import '../../../core/widgets/error_state_widget.dart';

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

    return Column(
      children: [
        // Filter Bar
        _FilterBar(ref: ref, filter: filter, colorScheme: colorScheme),

        // Content
        Expanded(
          child: activityAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorStateWidget(
              error: e,
              onRetry: () => ref.invalidate(activityLogProvider),
            ),
            data: (grouped) {
              if (grouped.isEmpty) {
                return _EmptyState(
                  isFiltered: filter.isActive,
                  onClearFilters: () {
                    ref
                        .read(activityFilterStateProvider.notifier)
                        .clearFilters();
                  },
                );
              }

              // Sorted date keys (newest first)
              final dateKeys = grouped.keys.toList()
                ..sort((a, b) => b.compareTo(a));

              return RefreshIndicator(
                onRefresh: _onRefresh,
                displacement: 40,
                color: colorScheme.primary,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // Top padding
                    const SliverPadding(padding: EdgeInsets.only(top: 8)),

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
                    const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
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
  final WidgetRef ref;
  final ActivityFilter filter;
  final ColorScheme colorScheme;

  const _FilterBar({
    required this.ref,
    required this.filter,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(booksWithActivityProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          // Book Filter Chip
          Expanded(
            child: booksAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (books) {
                final selectedBook = filter.bookId != null
                    ? kBibleBooks.firstWhere((b) => b.id == filter.bookId)
                    : null;

                return GestureDetector(
                  onTap: () => _showBookPicker(context, books),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: filter.bookId != null
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: filter.bookId != null
                          ? Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.3))
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 16,
                          color: filter.bookId != null
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                        const Gap(6),
                        Flexible(
                          child: Text(
                            selectedBook?.name ?? 'All Books',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: filter.bookId != null
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: filter.bookId != null
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: filter.startDate != null
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
                border: filter.startDate != null
                    ? Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.3))
                    : null,
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
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: filter.startDate != null
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Clear Filters button
          if (filter.isActive) ...[
            const Gap(8),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: Icon(Icons.filter_list_off,
                    size: 20, color: colorScheme.error),
                tooltip: 'Clear Filters',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(activityFilterStateProvider.notifier).clearFilters();
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _dateLabel() {
    if (filter.startDate == null) return 'All Time';
    final fmt = DateFormat('MMM d');
    if (filter.endDate == null) return 'From ${fmt.format(filter.startDate!)}';
    return '${fmt.format(filter.startDate!)} – ${fmt.format(filter.endDate!)}';
  }

  void _showBookPicker(BuildContext context, List<BibleBook> books) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 0.8,
          minChildSize: 0.3,
          expand: false,
          builder: (_, controller) {
            return Column(
              children: [
                const Gap(8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Filter by Book',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: controller,
                    children: [
                      // "All Books" option
                      ListTile(
                        leading: Icon(
                          Icons.library_books_rounded,
                          color: filter.bookId == null
                              ? colorScheme.primary
                              : null,
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
                      ...books.map((book) => ListTile(
                            leading: Icon(
                              Icons.book_rounded,
                              color: filter.bookId == book.id
                                  ? colorScheme.primary
                                  : null,
                            ),
                            title: Text(book.name),
                            selected: filter.bookId == book.id,
                            selectedColor: colorScheme.primary,
                            onTap: () {
                              ref
                                  .read(activityFilterStateProvider.notifier)
                                  .setBookFilter(book.id);
                              Navigator.pop(ctx);
                            },
                          )),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDatePicker(BuildContext context) async {
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
  final DateTime date;
  final ColorScheme colorScheme;

  _StickyDateHeaderDelegate({required this.date, required this.colorScheme});

  @override
  double get minExtent => 48.0;
  @override
  double get maxExtent => 48.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      color: scaffoldBg,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: overlapsContent
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              _formatDateLabel(date),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Divider(
              color: colorScheme.outline.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) return 'Today';
    if (checkDate == yesterday) return 'Yesterday';
    return DateFormat('MMMM d, y').format(date);
  }

  @override
  bool shouldRebuild(covariant _StickyDateHeaderDelegate oldDelegate) {
    return date != oldDelegate.date;
  }
}

// ACTIVITY CARD (TIMELINE ENTRY)

class _ActivityCard extends StatelessWidget {
  final ActivityGroup group;
  final bool isLast;

  const _ActivityCard({required this.group, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isBulk = group.chapters.length > 5;

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
                color: Colors.grey.withValues(alpha: 0.3),
              ),
              // Icon badge
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: group.isFinish
                      ? Colors.amber.shade100
                      : (isBulk
                          ? Colors.orange.withValues(alpha: 0.2)
                          : colorScheme.primaryContainer),
                  shape: BoxShape.circle,
                  boxShadow: group.isFinish
                      ? [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  group.isFinish
                      ? Icons.emoji_events
                      : (isBulk ? Icons.done_all : Icons.auto_stories),
                  size: 16,
                  color: group.isFinish
                      ? Colors.amber.shade800
                      : (isBulk ? Colors.orange : colorScheme.primary),
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast
                      ? Colors.transparent
                      : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
          const Gap(16),

          // Card Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
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

class _StandardCard extends StatelessWidget {
  final ActivityGroup group;
  final bool isBulk;

  const _StandardCard({required this.group, required this.isBulk});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                group.book.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Text(
                DateFormat('h:mm a').format(group.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
          const Gap(8),
          Wrap(
            spacing: 8,
            children: [
              _Tag(
                text: group.timeOfDay,
                color: colorScheme.surfaceContainerHighest,
              ),
              if (isBulk)
                _Tag(
                  text: 'Mass Update',
                  color: Colors.orange.withValues(alpha: 0.1),
                  textColor: Colors.orange,
                ),
            ],
          ),
          const Gap(8),
          Text(
            group.description,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ENHANCED COMPLETION CARD

class _CompletionCard extends StatelessWidget {
  final ActivityGroup group;

  const _CompletionCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF3D2E00),
                  const Color(0xFF2A2000),
                  const Color(0xFF1E1800),
                ]
              : [
                  Colors.amber.shade50,
                  Colors.orange.shade50,
                  Colors.yellow.shade50,
                ],
        ),
        border: Border.all(
          color: isDark
              ? Colors.amber.shade700.withValues(alpha: 0.5)
              : Colors.amber.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: isDark ? 0.15 : 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative sparkles
          Positioned(
            right: 12,
            top: 8,
            child: Icon(Icons.auto_awesome,
                size: 16, color: Colors.amber.withValues(alpha: 0.3)),
          ),
          Positioned(
            right: 40,
            top: 20,
            child: Icon(Icons.auto_awesome,
                size: 10, color: Colors.amber.withValues(alpha: 0.2)),
          ),
          Positioned(
            right: 24,
            bottom: 16,
            child: Icon(Icons.auto_awesome,
                size: 12, color: Colors.amber.withValues(alpha: 0.25)),
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        size: 20,
                        color: Colors.amber.shade800,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.book.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: isDark
                                  ? Colors.amber.shade200
                                  : Colors.amber.shade900,
                            ),
                          ),
                          const Gap(2),
                          Text(
                            '🎉 Book Completed!',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.amber.shade300
                                  : Colors.amber.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      DateFormat('h:mm a').format(group.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.amber.shade400
                            : Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
                const Gap(12),

                // Tags
                Wrap(
                  spacing: 8,
                  children: [
                    _Tag(
                      text: group.timeOfDay,
                      color: Colors.amber.shade100.withValues(alpha: 0.5),
                      textColor: isDark
                          ? Colors.amber.shade300
                          : Colors.amber.shade800,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded,
                              size: 12, color: Colors.amber.shade800),
                          const Gap(4),
                          Text(
                            '${group.book.chapters} Chapters',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Text(
                  group.description,
                  style: TextStyle(
                    color: isDark
                        ? Colors.amber.shade400
                        : Colors.amber.shade800.withValues(alpha: 0.7),
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

// EMPTY STATE

class _EmptyState extends StatelessWidget {
  final bool isFiltered;
  final VoidCallback onClearFilters;

  const _EmptyState({required this.isFiltered, required this.onClearFilters});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFiltered ? Icons.filter_list_off_rounded : Icons.history_edu,
            size: 64,
            color: Colors.grey,
          ),
          const Gap(16),
          Text(
            isFiltered
                ? 'No activity matches these filters'
                : 'No activity yet. Start reading!',
            style: TextStyle(
              fontSize: 15,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (isFiltered) ...[
            const Gap(16),
            FilledButton.tonal(
              onPressed: onClearFilters,
              child: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }
}

// TAG CHIP

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  final Color? textColor;

  const _Tag({required this.text, required this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: textColor),
      ),
    );
  }
}
