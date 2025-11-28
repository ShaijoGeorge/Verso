import 'package:flutter/material.dart';
import '../../../data/bible_data.dart';

class BookProgressCard extends StatelessWidget {
  final BibleBook book;
  final int chaptersRead;
  final VoidCallback onTap;

  const BookProgressCard({
    super.key,
    required this.book,
    required this.chaptersRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate percentage (0.0 to 1.0)
    // Avoid division by zero if a book somehow has 0 chapters
    final double progress = book.chapters > 0 
        ? chaptersRead / book.chapters 
        : 0.0;
        
    final bool isCompleted = progress >= 1.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // ClipRRect ensures the inner progress bar doesn't spill out of the rounded corners
        clipBehavior: Clip.antiAlias, 
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted 
                ? Theme.of(context).colorScheme.primary 
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // 1. The Progress Bar Layer (Background fill)
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0), 
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? Theme.of(context).colorScheme.primary.withAlpha(77) // Alpha for 30% 
                      : Theme.of(context).colorScheme.primary.withAlpha(38), // Alpha for 15%
                ),
              ),
            ),

            // 2. The Text Content Layer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Book Name
                  Expanded(
                    child: Text(
                      book.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Progress Count (e.g., "5/50")
                  Text(
                    "$chaptersRead / ${book.chapters}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}