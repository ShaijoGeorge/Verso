import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/bible_data.dart';
import '../providers/reading_providers.dart';
import '../../../core/widgets/error_state_widget.dart';

class ChaptersScreen extends ConsumerWidget {
  final BibleBook book;

  const ChaptersScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the database for this book's progress
    final progressAsync = ref.watch(bookProgressProvider(book.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(book.name),
      ),
      body: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorStateWidget(
          error: err,
          onRetry: () {
             // This forces Riverpod to re-fetch the data
             ref.invalidate(bookProgressProvider(book.id));
          },
        ),
        data: (progressList) {
          // 2. Convert the list of "ReadingProgress" objects into a Set of read chapter numbers
          // This makes checking "isRead" extremely fast (O(1))
          final readChapters = progressList
              .where((p) => p.isRead)
              .map((p) => p.chapterNumber)
              .toSet();

          // 3. Build the Grid
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 80, // Size of the boxes
              childAspectRatio: 1.0,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: book.chapters,
            itemBuilder: (context, index) {
              final chapterNum = index + 1;
              final isRead = readChapters.contains(chapterNum);

              return _ChapterBox(
                chapterNum: chapterNum,
                isRead: isRead,
                onTap: () {
                  // 4. Toggle the chapter status in the database
                  ref.read(bibleRepositoryProvider).toggleChapter(
                        book.id,
                        chapterNum,
                        !isRead,
                      );
                  
                  // 5. Invalidate the provider to refresh the UI immediately
                  ref.invalidate(bookReadCountProvider(book.id));
                  ref.invalidate(bookProgressProvider(book.id));
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
          color: isRead ? colorScheme.primary : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isRead 
            ? null 
            : Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
          boxShadow: isRead 
            ? [BoxShadow(color: colorScheme.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] 
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