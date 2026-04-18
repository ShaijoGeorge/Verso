import 'package:flutter/material.dart';
import 'package:verso/features/reading/screens/new_testament_screen.dart';
import 'package:verso/features/reading/screens/old_testament_screen.dart';

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
          // The Segmented Control
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent, // Removes standard underline
                indicator: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: Theme.of(context).colorScheme.primary,
                labelStyle: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                unselectedLabelColor:
                    Theme.of(context).colorScheme.onSurfaceVariant,
                tabs: const [
                  Tab(
                    height: 40,
                    text: 'Old Testament',
                  ),
                  Tab(
                    height: 40,
                    text: 'New Testament',
                  ),
                ],
              ),
            ),
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
