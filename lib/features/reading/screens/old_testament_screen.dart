import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verso/data/bible_data.dart';
import 'package:verso/features/reading/providers/reading_providers.dart';
import 'package:verso/features/reading/widgets/book_grid.dart';

class OldTestamentScreen extends ConsumerWidget {
  const OldTestamentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the trigger!
    final refreshTrigger = ref.watch(biblePageTriggerProvider);

    return Scaffold(
      body: BookGrid(
        // Forces the Grid to "reset" its memory when you arrive
        key: ValueKey('ot_grid_$refreshTrigger'),

        books: oldTestamentBooks, // Ensure this list is imported
        onBookTap: (book) {
          context.push('/book/${book.id}');
        },
      ),
    );
  }
}
