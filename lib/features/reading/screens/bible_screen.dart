import 'package:flutter/material.dart';
import 'package:verso/core/design/extensions.dart';
import 'package:verso/data/local/entities/user_settings.dart';
import 'package:verso/features/reading/screens/new_testament_screen.dart';
import 'package:verso/features/reading/screens/old_testament_screen.dart';

class BibleScreen extends StatelessWidget {
  const BibleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isAmoled = context.palette.style == AppearanceStyle.amoled;

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
              color: isAmoled
                  ? scheme.surfaceContainerHighest
                  : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent, // Removes standard underline
                indicator: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: scheme.primary,
                labelStyle: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                unselectedLabelColor: scheme.onSurfaceVariant,
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
