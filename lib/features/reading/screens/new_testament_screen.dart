import 'package:biblia/features/reading/providers/reading_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/bible_data.dart';
import '../widgets/book_grid.dart';
import 'package:go_router/go_router.dart';


class NewTestamentScreen extends ConsumerWidget {
  const NewTestamentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the trigger!
    final refreshTrigger = ref.watch(biblePageTriggerProvider);

    return Scaffold(
      body: BookGrid(
        // MAGIC KEY: Forces the Grid to "reset" its memory when you arrive.
        key: ValueKey("nt_grid_$refreshTrigger"),
        
        books: newTestamentBooks, // Ensure this list is imported
        onBookTap: (book) {
          context.push('/chapters', extra: book);
        },
      ),
    );
  }
}