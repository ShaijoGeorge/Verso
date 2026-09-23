import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verso/core/design/extensions.dart';
import 'package:verso/data/bible_book_names.dart';
import 'package:verso/data/bible_data.dart';
import 'package:verso/data/local/entities/user_settings.dart';
import 'package:verso/features/reading/providers/reading_providers.dart';
import 'package:verso/features/reading/widgets/book_progress_card.dart';
import 'package:verso/features/settings/providers/settings_providers.dart';

class BookGrid extends ConsumerStatefulWidget {
  const BookGrid({
    required this.books,
    required this.onBookTap,
    super.key,
  });
  final List<BibleBook> books;
  final void Function(BibleBook) onBookTap;

  @override
  ConsumerState<BookGrid> createState() => _BookGridState();
}

class _BookGridState extends ConsumerState<BookGrid> {
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
  Map<BookCategory, List<BibleBook>> _groupBooks(
    List<BibleBook> books,
    String bibleLanguage,
    CanonType canon,
  ) {
    final groups = <BookCategory, List<BibleBook>>{};
    for (final book in books) {
      if (book.matchesQuery(_searchQuery, bibleLanguage, canon)) {
        groups.putIfAbsent(book.category, () => []).add(book);
      }
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isAmoled = context.palette.style == AppearanceStyle.amoled;

    final settings = switch (ref.watch(currentSettingsProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final bibleLanguage = settings?.bibleLanguage ?? 'en';
    final canon = settings?.canon ?? CanonType.catholic;

    final groupedBooks = _groupBooks(widget.books, bibleLanguage, canon);
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
                hintText: bibleLanguage == 'ml'
                    ? 'പുസ്തകം തിരയുക...'
                    : 'Search books...',
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
                    category.getLocalizedDisplayName(bibleLanguage),
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
                          bibleLanguage: bibleLanguage,
                          canon: canon,
                        ),
                        loading: () => BookProgressCard(
                          book: book,
                          chaptersRead: 0,
                          onTap: () {},
                          shouldAnimateEntry: false,
                          bibleLanguage: bibleLanguage,
                          canon: canon,
                        ),
                        error: (_, __) => BookProgressCard(
                          book: book,
                          chaptersRead: 0,
                          onTap: () {},
                          shouldAnimateEntry: false,
                          bibleLanguage: bibleLanguage,
                          canon: canon,
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
