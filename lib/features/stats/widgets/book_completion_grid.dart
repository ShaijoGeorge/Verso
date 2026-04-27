import 'package:flutter/material.dart';
import 'package:verso/core/design/extensions.dart';
import 'package:verso/core/design/tokens/colors.dart';
import 'package:verso/data/bible_data.dart';

/// A compact mosaic grid showing all 73 Bible books.
/// Each cell's color intensity represents the completion fraction.
/// Tapping a cell shows a tooltip with the book name and progress.
class BookCompletionGrid extends StatelessWidget {
  const BookCompletionGrid({required this.bookCompletionMap, super.key});
  final Map<int, double> bookCompletionMap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        _Legend(isLight: isLight),
        const SizedBox(height: 12),

        // Grid
        LayoutBuilder(
          builder: (context, constraints) {
            // Aim for ~10 columns — adapt to width
            const crossAxisCount = 10;
            final cellSize = (constraints.maxWidth - (crossAxisCount - 1) * 4) /
                crossAxisCount;

            return Wrap(
              spacing: 4,
              runSpacing: 4,
              children: kBibleBooks.map((book) {
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

class _BookCell extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final pct = (fraction * 100).toInt();

    return Tooltip(
      message: '${book.name}: $pct% complete',
      preferBelow: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _cellColor(context),
          borderRadius: BorderRadius.circular(4),
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
    return Row(
      children: [
        // OT legend
        _LegendDot(
          color: context.appColors.otColor,
          label: 'OT',
        ),
        const SizedBox(width: 16),
        // NT legend
        _LegendDot(
          color: context.appColors.ntColor,
          label: 'NT',
        ),
        const SizedBox(width: 16),
        // Empty legend
        _LegendDot(
          color: isLight
              ? AppColors.completionEmptyLight
              : AppColors.completionEmptyDark,
          label: 'Not started',
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
