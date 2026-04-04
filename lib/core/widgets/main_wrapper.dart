import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/widgets/profile_drawer.dart';
import '../../features/stats/providers/stats_providers.dart';
import '../../features/stats/providers/activity_providers.dart';
import '../../features/reading/providers/reading_providers.dart';
import '../providers/connectivity_provider.dart';

class MainWrapper extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapper({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends ConsumerState<MainWrapper> {

  void _goBranch(int index) {
    // 0 = Home, 1 = Bible, 2 = Journal
    
    // Home Page Animation Trigger
    if (index == 0 && widget.navigationShell.currentIndex != 0) {
      ref.invalidate(userStatsProvider);
    }

    // Bible Pages Animation Trigger
    if (index == 1 && widget.navigationShell.currentIndex != 1) {
      ref.read(biblePageTriggerProvider.notifier).increment();
    }
    
    // Journal Trigger (Optional, but good for fresh data)
    if (index == 2 && widget.navigationShell.currentIndex != 2) {
      ref.invalidate(activityLogProvider);
    }

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(connectivityProvider);

    String title;
    switch (widget.navigationShell.currentIndex) {
      case 0: title = 'Verso'; break;
      case 1: title = 'The Bible'; break;
      case 2: title = 'Reading Journal'; break;
      default: title = 'Verso';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,

        actions: const [],
      ),
      drawer: const ProfileDrawer(),
      body: Column(
        children: [
          // Offline indicator banner
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isOnline
                ? const SizedBox.shrink()
                : Material(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_off,
                              size: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer),
                          const SizedBox(width: 8),
                          Text(
                            'Reading in offline mode. Changes will sync when connected.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          // Main content
          Expanded(child: widget.navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Bible',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_edu_outlined),
            selectedIcon: Icon(Icons.history_edu),
            label: 'Journal',
          ),
        ],
      ),
    );
  }
}
