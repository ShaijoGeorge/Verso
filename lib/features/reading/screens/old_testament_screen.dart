import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/bible_data.dart';
import '../widgets/book_grid.dart';

class OldTestamentScreen extends StatelessWidget {
  const OldTestamentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Filter the static data to get only OT books
    final otBooks = kBibleBooks
        .where((b) => b.testament == Testament.old)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Old Testament"),
      ),
      body: BookGrid(
        books: otBooks,
        onBookTap: (book) {
          // Use GoRouter to push the new screen
          // We use 'push' so the user can hit 'Back' to return to the list
          GoRouter.of(context).push('/book/${book.id}');
        },
      ),
    );
  }
}