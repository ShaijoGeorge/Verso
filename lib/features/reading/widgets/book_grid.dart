import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verso/core/design/tokens/colors.dart';
import 'package:verso/data/bible_data.dart';
import 'package:verso/features/reading/providers/reading_providers.dart';
import 'package:verso/features/reading/widgets/book_progress_card.dart';

class BookGrid extends StatefulWidget {
  const BookGrid({
    required this.books,
    required this.onBookTap,
    super.key,
  });
  final List<BibleBook> books;
  final void Function(BibleBook) onBookTap;

  @override
  State<BookGrid> createState() => _BookGridState();
}

class _BookGridState extends State<BookGrid> {
  // MEMORY: Keeps track of which books have already played their entry animation
  final Set<int> _hasAnimated = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Group books by category
  Map<BookCategory, List<BibleBook>> _groupBooks(List<BibleBook> books) {
    final groups = <BookCategory, List<BibleBook>>{};
    for (final book in books) {
      if (book.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        groups.putIfAbsent(book.category, () => []).add(book);
      }
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isAmoled = !isLight && scheme.surface == AppColors.surfaceAmoled;

    final groupedBooks = _groupBooks(widget.books);
    final sortedCategories =
        BookCategory.values.where(groupedBooks.containsKey).toList();

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 600 ? 4 : 2;

    return CustomScrollView(
      slivers: [
        // 1. Search Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search books...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: scheme.primary.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: isAmoled 
                    ? scheme.surfaceContainerHighest 
                    : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),

        // 2. Empty State
        if (sortedCategories.isEmpty && _searchQuery.isNotEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 48,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No matches for '$_searchQuery'",
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.outline),
                  ),
                ],
              ),
            ),
          ),

        // 3. Category Sections
        for (final category in sortedCategories) ...[
          // Sticky Header Equivalent (Non-pinned for now)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                children: [
                  Text(
                    category.displayName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Divider(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Grid for this category
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final book = groupedBooks[category]![index];

                  return Consumer(
                    builder: (context, ref, child) {
                      final asyncCount =
                          ref.watch(bookReadCountProvider(book.id));

                      return asyncCount.when(
                        data: (count) => BookProgressCard(
                          book: book,
                          chaptersRead: count,
                          onTap: () => widget.onBookTap(book),
                          shouldAnimateEntry: !_hasAnimated.contains(book.id),
                          onAnimationStarted: () => _hasAnimated.add(book.id),
                        ),
                        loading: () => BookProgressCard(
                          book: book,
                          chaptersRead: 0,
                          onTap: () {},
                          shouldAnimateEntry: false,
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
                childCount: groupedBooks[category]!.length,
              ),
            ),
          ),
        ],

        // 4. Bottom Spacing
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }
}
