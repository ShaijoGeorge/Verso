import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:verso/core/design/extensions.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/shadows.dart';
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
    final textTheme = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
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
      physics: const BouncingScrollPhysics(),
      slivers: [
        // 1. Search Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
            child: Container(
              decoration: BoxDecoration(
                color:
                    isAmoled ? scheme.surfaceContainerHighest : scheme.surface,
                borderRadius: AppRadii.borderRadiusLG,
                border: Border.all(
                  color:
                      scheme.outline.withValues(alpha: isLight ? 0.65 : 0.25),
                ),
                boxShadow: isLight ? AppShadows.sm : AppShadows.none,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Search books...',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: scheme.primary.withValues(alpha: 0.7),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: scheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
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
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary.withValues(alpha: 0.08),
                    ),
                    child: Icon(
                      Icons.search_off_rounded,
                      size: 32,
                      color: scheme.primary,
                    ),
                  ),
                  const Gap(14),
                  Text(
                    "No books matching '$_searchQuery'",
                    style: textTheme.titleSmall?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    'Try searching with another book name',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
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
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 14,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: AppRadii.borderRadiusFull,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    category.getLocalizedDisplayName(bibleLanguage),
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Gap(8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.1),
                      borderRadius: AppRadii.borderRadiusFull,
                    ),
                    child: Text(
                      '${groupedBooks[category]!.length}',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: Divider(
                      color: scheme.outline.withValues(alpha: 0.2),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Grid for this category
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.52,
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
        const SliverPadding(padding: EdgeInsets.only(bottom: 110)),
      ],
    );
  }
}
