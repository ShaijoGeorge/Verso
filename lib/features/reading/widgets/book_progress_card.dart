import 'package:flutter/material.dart';
import '../../../data/bible_data.dart';
import '../../../core/design/tokens/spacing.dart';

class BookProgressCard extends StatefulWidget {
  final BibleBook book;
  final int chaptersRead;
  final VoidCallback onTap;
  final bool shouldAnimateEntry;
  final VoidCallback? onAnimationStarted;

  const BookProgressCard({
    super.key,
    required this.book,
    required this.chaptersRead,
    required this.onTap,
    this.shouldAnimateEntry = true,
    this.onAnimationStarted,
  });

  @override
  State<BookProgressCard> createState() => _BookProgressCardState();
}

class _BookProgressCardState extends State<BookProgressCard> {
  double _displayProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _initProgress();
  }

  void _initProgress() {
    final realProgress = widget.book.chapters > 0
        ? widget.chaptersRead / widget.book.chapters
        : 0.0;

    if (widget.shouldAnimateEntry) {
      _displayProgress = 0.0;
      widget.onAnimationStarted?.call();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _displayProgress = realProgress);
      });
    } else {
      _displayProgress = realProgress;
    }
  }

  @override
  void didUpdateWidget(covariant BookProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chaptersRead != widget.chaptersRead) {
      setState(() {
        _displayProgress = widget.book.chapters > 0
            ? widget.chaptersRead / widget.book.chapters
            : 0.0;
      });
    }
  }

  // --- Helper method to determine the status icon ---
  Widget _buildStatusIndicator(
      bool isCompleted, bool isInProgress, ColorScheme scheme) {
    if (isCompleted) {
      return Icon(Icons.check_circle_rounded,
          size: 18, color: Colors.amber.shade600); // ✓
    } else if (isInProgress) {
      return Icon(Icons.tonality_rounded, size: 18, color: scheme.primary); // ◐
    } else {
      return Icon(Icons.radio_button_unchecked_rounded,
          size: 18, color: scheme.outline); // ○
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final realProgress = widget.book.chapters > 0
        ? widget.chaptersRead / widget.book.chapters
        : 0.0;

    final bool isCompleted = realProgress >= 1.0;
    final bool isInProgress = realProgress > 0 && !isCompleted;

    // Define the card styling based on completion
    final borderColor = isCompleted
        ? Colors.amber.shade400
        : scheme.outline.withValues(alpha: 0.2);
    final bgColor = isCompleted
        ? Colors.amber.withValues(alpha: 0.05)
        : scheme.surfaceContainerHighest;

    return GestureDetector(
      onTap: widget.onTap,
      child: RepaintBoundary(
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: isCompleted ? 2 : 1),
            // Add a subtle glow if completed
            boxShadow: isCompleted
                ? [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Progress Fill
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                widthFactor: _displayProgress.clamp(0.0, 1.0),
                alignment: Alignment.centerLeft,
                child: Container(
                  color: isCompleted
                      ? Colors.amber.withValues(alpha: 0.15)
                      : scheme.primary.withValues(alpha: 0.1),
                ),
              ),

              // Content
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Book Name & Icon
                    Expanded(
                      child: Row(
                        children: [
                          _buildStatusIndicator(
                              isCompleted, isInProgress, scheme),
                          const SizedBox(width: Spacing.sm),
                          Expanded(
                            child: Text(
                              widget.book.name,
                              style: TextStyle(
                                fontWeight: isCompleted
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                fontSize: 15,
                                color: scheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Chapter Fraction Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.amber.shade100
                            : scheme.surface.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "${widget.chaptersRead}/${widget.book.chapters}",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isCompleted
                              ? Colors.amber.shade900
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
