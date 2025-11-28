import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/bible_data.dart';
import '../widgets/book_grid.dart';

class NewTestamentScreen extends StatelessWidget {
  const NewTestamentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Filter the static data to get only NT books
    final ntBooks = kBibleBooks
        .where((b) => b.testament == Testament.newTestament)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Testament"),
      ),
      body: BookGrid(
        books: ntBooks,
        onBookTap: (book) {
          // Use GoRouter to push the new screen
          // We use 'push' so the user can hit 'Back' to return to the list
          GoRouter.of(context).push('/book/${book.id}');
        },
      ),
    );
  }
}