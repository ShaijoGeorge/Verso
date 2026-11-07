import 'package:flutter/material.dart';
import 'package:verso/core/design/extensions.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/shadows.dart';
import 'package:verso/data/bible_book_names.dart';
import 'package:verso/data/bible_data.dart';
import 'package:verso/data/local/entities/user_settings.dart';

class BookProgressCard extends StatefulWidget {
  const BookProgressCard({
    required this.book,
    required this.chaptersRead,
    required this.onTap,
    super.key,
    this.shouldAnimateEntry = true,
    this.onAnimationStarted,
    this.bibleLanguage = 'en',
    this.canon = CanonType.catholic,
  });
  final BibleBook book;
  final int chaptersRead;
  final VoidCallback onTap;
  final bool shouldAnimateEntry;
  final VoidCallback? onAnimationStarted;
  final String bibleLanguage;
  final CanonType canon;

  @override
  State<BookProgressCard> createState() => _BookProgressCardState();
}

class _BookProgressCardState extends State<BookProgressCard> {
  double _displayProgress = 0;

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
    bool isCompleted,
    bool isInProgress,
    ColorScheme scheme,
  ) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: scheme.secondary.withValues(alpha: 0.16),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_rounded,
          size: 13,
          color: scheme.secondary,
        ),
      ); // ✓
    } else if (isInProgress) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.auto_stories_rounded,
          size: 13,
          color: scheme.primary,
        ),
      ); // ◐
    } else {
      return Container(
        width: 21,
        height: 21,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: scheme.outline.withValues(alpha: 0.45),
            width: 1.5,
          ),
        ),
      ); // ○
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isAmoled = context.palette.style == AppearanceStyle.amoled;
    final realProgress = widget.book.chapters > 0
        ? widget.chaptersRead / widget.book.chapters
        : 0.0;

    final isCompleted = realProgress >= 1.0;
    final isInProgress = realProgress > 0 && !isCompleted;

    // Define the card styling based on completion
    final borderColor = isCompleted
        ? scheme.secondary.withValues(alpha: 0.55)
        : (isInProgress
            ? scheme.primary.withValues(alpha: 0.35)
            : (isAmoled
                ? scheme.outline.withValues(alpha: 0.7)
                : scheme.outline.withValues(alpha: isLight ? 0.65 : 0.25)));

    final bgColor = isCompleted
        ? scheme.secondaryContainer.withValues(alpha: isLight ? 0.45 : 0.25)
        : scheme.surface;

    return GestureDetector(
      onTap: widget.onTap,
      child: RepaintBoundary(
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadii.borderRadiusMD,
            border: Border.all(
              color: borderColor,
              width: isCompleted ? 1.5 : 1,
            ),
            // Add a subtle glow if completed
            boxShadow: isCompleted
                ? [
                    BoxShadow(
                      color: scheme.secondary.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : (isLight ? AppShadows.sm : null),
          ),
          child: Stack(
            children: [
              // Progress Fill
              Positioned.fill(
                child: AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  widthFactor: _displayProgress.clamp(0.0, 1.0),
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isCompleted
                            ? [
                                scheme.secondary.withValues(alpha: 0.16),
                                scheme.secondary.withValues(alpha: 0.08),
                              ]
                            : [
                                scheme.primary.withValues(alpha: 0.1),
                                scheme.primary.withValues(alpha: 0.04),
                              ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom progress bar strip
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 3.5,
                child: ColoredBox(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  child: AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    widthFactor: _displayProgress.clamp(0.0, 1.0),
                    alignment: Alignment.centerLeft,
                    child: ColoredBox(
                      color: isCompleted ? scheme.secondary : scheme.primary,
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top row: status badge + chapter fraction pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusIndicator(
                          isCompleted,
                          isInProgress,
                          scheme,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? scheme.secondaryContainer
                                : scheme.surfaceContainerHighest
                                    .withValues(alpha: 0.75),
                            borderRadius: AppRadii.borderRadiusFull,
                          ),
                          child: Text(
                            '${widget.chaptersRead}/${widget.book.chapters}',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isCompleted
                                  ? context.appColors.secondaryOnContainer
                                  : (isInProgress
                                      ? scheme.primary
                                      : scheme.onSurfaceVariant),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Bottom row: Book Name
                    Text(
                      widget.book.getLocalizedName(
                        widget.bibleLanguage,
                        widget.canon,
                      ),
                      style: TextStyle(
                        fontWeight:
                            isCompleted ? FontWeight.w800 : FontWeight.w700,
                        fontSize: 14.5,
                        letterSpacing: -0.2,
                        color: scheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
