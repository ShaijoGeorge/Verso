import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/widgets/profile_drawer.dart';
import '../../features/stats/providers/stats_providers.dart';
import '../../features/reading/providers/reading_providers.dart';

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
  
  // No explicit sync needed for Realtime Streams

  void _goBranch(int index) {

    // Home Page Animation Trigger
    if (index == 1 && widget.navigationShell.currentIndex != 1) {
      ref.read(homeRefreshTriggerProvider.notifier).state++;
    }

    // Bible Pages Animation Trigger
    if ((index == 0 || index == 2) && widget.navigationShell.currentIndex != index) {
      ref.read(biblePageTriggerProvider.notifier).state++;
    }

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    String title;
    switch (widget.navigationShell.currentIndex) {
      case 0: title = 'Old Testament'; break;
      case 1: title = 'Biblia'; break;
      case 2: title = 'New Testament'; break;
      default: title = 'Biblia';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      drawer: const ProfileDrawer(),
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Old Testament',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'New Testament',
          ),
        ],
      ),
    );
  }
}