import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verso/core/design/extensions.dart';
import 'package:verso/core/design/tokens/colors.dart';
import 'package:verso/data/bible_book_names.dart';
import 'package:verso/data/bible_data.dart';
import 'package:verso/features/reading/providers/reading_providers.dart';
import 'package:verso/features/settings/providers/settings_providers.dart';

/// A compact mosaic grid showing books for the active canon.
/// Each cell's color intensity represents the completion fraction.
/// Tapping a cell shows a tooltip with the book name and progress.
class BookCompletionGrid extends ConsumerWidget {
  const BookCompletionGrid({required this.bookCompletionMap, super.key});
  final Map<int, double> bookCompletionMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final books = ref.watch(activeCanonBooksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        _Legend(isLight: isLight),
        const SizedBox(height: 14),

        // Grid
        LayoutBuilder(
          builder: (context, constraints) {
            // Aim for ~10 columns — adapt to width
            const crossAxisCount = 10;
            final cellSize = (constraints.maxWidth - (crossAxisCount - 1) * 5) /
                crossAxisCount;

            return Wrap(
              spacing: 5,
              runSpacing: 5,
              children: books.map((book) {
                final fraction = bookCompletionMap[book.id] ?? 0.0;
                return _BookCell(
                  book: book,
                  fraction: fraction,
                  size: cellSize,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _BookCell extends ConsumerWidget {
  const _BookCell({
    required this.book,
    required this.fraction,
    required this.size,
  });
  final BibleBook book;
  final double fraction;
  final double size;

  Color _cellColor(BuildContext context) {
    if (fraction <= 0.0) {
      return context.appColors.completionEmpty;
    }

    // OT = warm orange tones, NT = cool blue tones
    final isOT = book.testament == Testament.old;
    if (isOT) {
      // Orange scale: light at low %, deep at 100%
      return Color.lerp(
        context.appColors.otContainer,
        context.appColors.otColor,
        fraction,
      )!;
    } else {
      // Blue scale
      return Color.lerp(
        context.appColors.ntContainer,
        context.appColors.ntColor,
        fraction,
      )!;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pct = (fraction * 100).toInt();
    final settings = switch (ref.watch(currentSettingsProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final bibleLanguage = settings?.bibleLanguage ?? 'en';
    final canon = settings?.canon ?? CanonType.catholic;
    final bookName = book.getLocalizedName(bibleLanguage, canon);

    return Tooltip(
      message: '$bookName: $pct% complete',
      preferBelow: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _cellColor(context),
          borderRadius: BorderRadius.circular(6),
        ),
        child: fraction >= 1.0
            ? Icon(
                Icons.check_rounded,
                size: size * 0.55,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.isLight});
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        // OT legend
        _LegendDot(
          color: context.appColors.otColor,
          label: 'Old Testament',
        ),
        // NT legend
        _LegendDot(
          color: context.appColors.ntColor,
          label: 'New Testament',
        ),
        // Empty legend
        _LegendDot(
          color: isLight
              ? AppColors.completionEmptyLight
              : AppColors.completionEmptyDark,
          label: 'Unread',
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
