import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:verso/features/stats/providers/stats_providers.dart';
import 'package:verso/features/stats/widgets/book_completion_grid.dart';
import 'package:verso/features/stats/widgets/stat_summary_card.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({required this.stats, super.key});
  final DetailedStats stats;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // OT/NT Completion Rings
          _TestamentRings(stats: stats),
          const Gap(28),

          // 4 Summary Cards
          _SummaryCards(stats: stats),
          const Gap(28),

          // 73-Book Completion Grid
          Text(
            'Book Completion',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Gap(4),
          Text(
            'Each cell is one book - darker means more complete',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(12),
          BookCompletionGrid(bookCompletionMap: stats.bookCompletionMap),
        ],
      ),
    );
  }
}

// OT/NT Rings - side by side with animated fill
class _TestamentRings extends StatelessWidget {
  const _TestamentRings({required this.stats});
  final DetailedStats stats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RingWidget(
              label: 'Old Testament',
              progress: stats.otProgress,
              chaptersRead: stats.otRead,
              totalChapters: 1074,
              booksCompleted: stats.otBooksCompleted,
              totalBooks: 46,
              color:
                  isLight ? const Color(0xFFE65100) : const Color(0xFFFF9800),
            ),
          ),
          // Vertical divider
          Container(
            width: 1,
            height: 120,
            color: scheme.outline.withValues(alpha: 0.15),
          ),
          Expanded(
            child: _RingWidget(
              label: 'New Testament',
              progress: stats.ntProgress,
              chaptersRead: stats.ntRead,
              totalChapters: 260,
              booksCompleted: stats.ntBooksCompleted,
              totalBooks: 27,
              color:
                  isLight ? const Color(0xFF1565C0) : const Color(0xFF64B5F6),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 90,
          width: 90,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutQuart,
            builder: (context, value, _) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: value,
                    strokeWidth: 8,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(color),
                    strokeCap: StrokeCap.round,
                  ),
                  Center(
                    child: Text(
                      '${(value * 100).toInt()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: color,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const Gap(10),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const Gap(2),
        Text(
          '$booksCompleted / $totalBooks Books',
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          '$chaptersRead / $totalChapters Chapters',
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                iconColor: Colors.orange,
                label: 'Current Streak',
                value: '${stats.streak}',
                subtitle: 'days in a row',
              ),
            ),
            const Gap(12),
            Expanded(
              child: StatSummaryCard(
                icon: Icons.auto_stories_rounded,
                iconColor: Colors.blue,
                label: 'Chapters Read',
                value: '${stats.totalRead}',
                subtitle: 'of 1,334 total',
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
                iconColor: Colors.amber.shade700,
                label: 'Books Done',
                value: '${stats.otBooksCompleted + stats.ntBooksCompleted}',
                subtitle: 'of 73 books',
              ),
            ),
            const Gap(12),
            Expanded(
              child: StatSummaryCard(
                icon: Icons.trending_up_rounded,
                iconColor: Colors.green,
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
