import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/bible_data.dart';
import '../providers/reading_providers.dart';
import 'book_progress_card.dart';

class BookGrid extends StatefulWidget {
  final List<BibleBook> books;
  final Function(BibleBook) onBookTap;

  const BookGrid({
    super.key,
    required this.books,
    required this.onBookTap,
  });

  @override
  State<BookGrid> createState() => _BookGridState();
}

class _BookGridState extends State<BookGrid> {
  // MEMORY: Keeps track of which books have already played their entry animation
  final Set<int> _hasAnimated = {};

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 600 ? 4 : 2;

    return GridView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
      cacheExtent: 500, // Smooth scrolling pre-load
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: widget.books.length,
      itemBuilder: (context, index) {
        final book = widget.books[index];

        return Consumer(
          builder: (context, ref, child) {
            final asyncCount = ref.watch(bookReadCountProvider(book.id));

            return asyncCount.when(
              data: (count) => BookProgressCard(
                book: book,
                chaptersRead: count,
                onTap: () => widget.onBookTap(book),
                // LOGIC: Only animate if it's NOT in our memory set
                shouldAnimateEntry: !_hasAnimated.contains(book.id),
                onAnimationStarted: () {
                  // Mark this book as "seen" so it doesn't animate again on scroll
                  _hasAnimated.add(book.id); 
                },
              ),
              loading: () => BookProgressCard(
                book: book,
                chaptersRead: 0,
                onTap: () {},
                shouldAnimateEntry: false, // Don't animate placeholders
              ),
              error: (_, __) => BookProgressCard(
                book: book,
                chaptersRead: 0,
                onTap: () {},
                shouldAnimateEntry: false,
              ),
            );
          },
        );
      },
    );
  }
}