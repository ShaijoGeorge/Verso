import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/bible_data.dart';
import '../providers/reading_providers.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/utils/app_error_handler.dart'; // Make sure this import is correct

// Convert to ConsumerStatefulWidget to track loading state
class ChaptersScreen extends ConsumerStatefulWidget {
  final BibleBook book;

  const ChaptersScreen({super.key, required this.book});

  @override
  ConsumerState<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends ConsumerState<ChaptersScreen> {
  // Local state to track the button's loading status
  bool _isMarkingRead = false;

  @override
  Widget build(BuildContext context) {
    // Note: Use 'widget.book' to access the book in a StatefulWidget
    final progressAsync = ref.watch(bookProgressProvider(widget.book.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.name),
        actions: [
          // 2. The Smart "Mark All" Button
          IconButton(
            // If loading, show a small spinner. Otherwise, show the check icon.
            icon: _isMarkingRead
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.grey, // Subtle color for app bar
                    ),
                  )
                : const Icon(Icons.done_all),
            
            tooltip: 'Mark all as read',
            
            // Disable the button while loading (onPressed = null)
            onPressed: _isMarkingRead
                ? null
                : () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Mark all as read?'),
                        content: Text(
                            'This will mark all ${widget.book.chapters} chapters of ${widget.book.name} as read.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Mark Read'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      // Start Loading
                      setState(() => _isMarkingRead = true);

                      try {
                        await ref
                            .read(bibleRepositoryProvider)
                            .markBookAsRead(widget.book.id, widget.book.chapters);

                        // Invalidate providers to refresh
                        ref.invalidate(bookReadCountProvider(widget.book.id));
                        ref.invalidate(bookProgressProvider(widget.book.id));

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Marked as read!')),
                          );
                        }
                      } catch (e) {
                        debugPrint('Error marking read: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Failed: ${AppErrorHandler.getMessage(e)}')),
                          );
                        }
                      } finally {
                        // Stop Loading (whether success or failure)
                        if (mounted) {
                          setState(() => _isMarkingRead = false);
                        }
                      }
                    }
                  },
          ),
        ],
      ),
      body: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorStateWidget(
          error: err,
          onRetry: () {
            ref.invalidate(bookProgressProvider(widget.book.id));
          },
        ),
        data: (progressList) {
          // Convert the list of "ReadingProgress" objects into a Set of read chapter numbers
          // This makes checking "isRead" extremely fast (O(1))
          final readChapters = progressList
              .where((p) => p.isRead)
              .map((p) => p.chapterNumber)
              .toSet();

          // Build the Grid
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 80, // Size of the boxes
              childAspectRatio: 1.0,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: widget.book.chapters,
            itemBuilder: (context, index) {
              final chapterNum = index + 1;
              final isRead = readChapters.contains(chapterNum);

              return _ChapterBox(
                chapterNum: chapterNum,
                isRead: isRead,
                onTap: () {
                  // Toggle the chapter status in the database
                  ref.read(bibleRepositoryProvider).toggleChapter(
                        widget.book.id,
                        chapterNum,
                        !isRead,
                      );
                  ref.invalidate(bookReadCountProvider(widget.book.id));
                  ref.invalidate(bookProgressProvider(widget.book.id));
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ChapterBox extends StatelessWidget {
  final int chapterNum;
  final bool isRead;
  final VoidCallback onTap;

  const _ChapterBox({
    required this.chapterNum,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isRead
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isRead
              ? null
              : Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
          boxShadow: isRead
              ? [
                  BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '$chapterNum',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isRead ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}