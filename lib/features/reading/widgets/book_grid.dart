import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/bible_data.dart';
import '../providers/reading_providers.dart';
import 'book_progress_card.dart';

class BookGrid extends StatelessWidget {
  final List<BibleBook> books;
  final Function(BibleBook) onBookTap;

  const BookGrid({
    super.key,
    required this.books,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive Design setup
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 600 ? 4 : 2;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];

        // This Consumer widget listens to the specific provider for *this* book
        return Consumer(
          builder: (context, ref, child) {
            // Ask Riverpod: "How many chapters read for this book ID?"
            final asyncCount = ref.watch(bookReadCountProvider(book.id));

            return asyncCount.when(
              // If data is loaded, show the real card
              data: (count) => BookProgressCard(
                book: book,
                chaptersRead: count,
                onTap: () => onBookTap(book),
              ),
              // If loading/error, show a placeholder card (0 progress)
              loading: () => BookProgressCard(
                book: book,
                chaptersRead: 0,
                onTap: () {}, // Disable tap while loading
              ),
              error: (_, __) => BookProgressCard(
                book: book,
                chaptersRead: 0,
                onTap: () {},
              ),
            );
          },
        );
      },
    );
  }
}