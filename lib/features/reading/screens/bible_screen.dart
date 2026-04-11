import 'package:flutter/material.dart';

import 'old_testament_screen.dart';
import 'new_testament_screen.dart';

class BibleScreen extends StatelessWidget {
  const BibleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // DefaultTabController automatically manages the state for the TabBar and TabBarView
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // The Segmented Control
          TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurfaceVariant,
            tabs: const [
              Tab(text: 'Old Testament'),
              Tab(text: 'New Testament'),
            ],
          ),
          // The actual content (our existing grids)
          const Expanded(
            child: TabBarView(
              children: [
                OldTestamentScreen(),
                NewTestamentScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
