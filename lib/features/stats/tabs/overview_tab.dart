import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:verso/core/design/components/verso_card.dart';
import 'package:verso/core/design/components/verso_circular_progress.dart';
import 'package:verso/core/design/components/verso_section_header.dart';
import 'package:verso/core/design/extensions.dart';
import 'package:verso/data/bible_book_names.dart';
import 'package:verso/data/bible_data.dart';
import 'package:verso/features/settings/providers/settings_providers.dart';
import 'package:verso/features/stats/providers/stats_providers.dart';
import 'package:verso/features/stats/widgets/book_completion_grid.dart';
import 'package:verso/features/stats/widgets/stat_summary_card.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({required this.stats, super.key});
  final DetailedStats stats;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // OT/NT Completion Rings
          _TestamentRings(stats: stats),
          const Gap(24),

          // 4 Summary Cards
          const VersoSectionHeader(title: 'Key Milestones'),
          const Gap(12),
          _SummaryCards(stats: stats),
          const Gap(28),

          // Dynamic Book Completion Grid
          const VersoSectionHeader(title: 'Canon Mosaic'),
          const Gap(6),
          Text(
            'Each cell represents one book · Deeper color indicates higher completion',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(12),
          VersoCard(
            padding: const EdgeInsets.all(18),
            child: BookCompletionGrid(
              bookCompletionMap: stats.bookCompletionMap,
            ),
          ),
        ],
      ),
    );
  }
}

// OT/NT Rings - side by side with animated fill
class _TestamentRings extends ConsumerWidget {
  const _TestamentRings({required this.stats});
  final DetailedStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    final settings = switch (ref.watch(currentSettingsProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final bibleLanguage = settings?.bibleLanguage ?? 'en';

    return VersoCard(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _RingWidget(
              label: Testament.old.getLocalizedName(bibleLanguage),
              progress: stats.otProgress,
              chaptersRead: stats.otRead,
              totalChapters: stats.totalOTChapters,
              booksCompleted: stats.otBooksCompleted,
              totalBooks: stats.totalOTBooks,
              color: context.appColors.otColor,
            ),
          ),
          // Vertical divider
          Container(
            width: 1,
            height: 136,
            color: scheme.outline.withValues(alpha: 0.18),
          ),
          Expanded(
            child: _RingWidget(
              label: Testament.newTestament.getLocalizedName(bibleLanguage),
              progress: stats.ntProgress,
              chaptersRead: stats.ntRead,
              totalChapters: stats.totalNTChapters,
              booksCompleted: stats.ntBooksCompleted,
              totalBooks: stats.totalNTBooks,
              color: context.appColors.ntColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingWidget extends StatelessWidget {
  const _RingWidget({
    required this.label,
    required this.progress,
    required this.chaptersRead,
    required this.totalChapters,
    required this.booksCompleted,
    required this.totalBooks,
    required this.color,
  });
  final String label;
  final double progress; // 0.0 to 1.0
  final int chaptersRead;
  final int totalChapters;
  final int booksCompleted;
  final int totalBooks;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: progress * 100),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOutQuart,
          builder: (context, value, _) {
            return VersoCircularProgress(
              progress: value,
              size: 96,
              strokeWidth: 8.5,
              color: color,
              trackColor: color.withValues(alpha: 0.12),
              child: Text(
                '${value.toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                  letterSpacing: -0.4,
                  color: color,
                ),
              ),
            );
          },
        ),
        const Gap(12),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: scheme.onSurface,
          ),
        ),
        const Gap(4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            '$booksCompleted / $totalBooks Books',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const Gap(4),
        Text(
          '$chaptersRead / $totalChapters Chapters',
          style: TextStyle(
            fontSize: 11,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// 4 Summary Cards - 2x2 grid with count-up
class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.stats});
  final DetailedStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatSummaryCard(
                icon: Icons.local_fire_department_rounded,
                iconColor: context.appColors.streak,
                label: 'Current Streak',
                value: '${stats.streak}',
                subtitle: 'days in a row',
              ),
            ),
            const Gap(12),
            Expanded(
              child: StatSummaryCard(
                icon: Icons.auto_stories_rounded,
                iconColor: context.appColors.chapters,
                label: 'Chapters Read',
                value: '${stats.totalRead}',
                subtitle: 'of ${stats.totalBibleChapters} total',
              ),
            ),
          ],
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(
              child: StatSummaryCard(
                icon: Icons.emoji_events_rounded,
                iconColor: context.appColors.books,
                label: 'Books Done',
                value: '${stats.otBooksCompleted + stats.ntBooksCompleted}',
                subtitle: 'of ${stats.totalBooks} books',
              ),
            ),
            const Gap(12),
            Expanded(
              child: StatSummaryCard(
                icon: Icons.trending_up_rounded,
                iconColor: context.appColors.success,
                label: 'Total Progress',
                value: '${(stats.totalProgress * 100).toStringAsFixed(1)}%',
                subtitle: 'of entire Bible',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
