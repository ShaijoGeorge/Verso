import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/providers/connectivity_provider.dart';
import 'package:verso/features/auth/widgets/profile_drawer.dart';
import 'package:verso/features/reading/providers/reading_providers.dart';
import 'package:verso/features/stats/providers/activity_providers.dart';
import 'package:verso/features/stats/providers/stats_providers.dart';

class MainWrapper extends ConsumerStatefulWidget {
  const MainWrapper({
    required this.navigationShell,
    super.key,
  });
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends ConsumerState<MainWrapper> {
  void _goBranch(int index) {
    // 0 = Home, 1 = Bible, 2 = Stats, 3 = Journal

    // Home Page Animation Trigger
    if (index == 0 && widget.navigationShell.currentIndex != 0) {
      ref.invalidate(userStatsProvider);
    }

    // Bible Pages Animation Trigger
    if (index == 1 && widget.navigationShell.currentIndex != 1) {
      ref.read(biblePageTriggerProvider.notifier).increment();
    }

    // Stats Tab Trigger — refresh detailed stats
    if (index == 2 && widget.navigationShell.currentIndex != 2) {
      ref.invalidate(detailedStatsProvider);
    }

    // Journal Trigger
    if (index == 3 && widget.navigationShell.currentIndex != 3) {
      ref.invalidate(activityLogProvider);
    }

    HapticFeedback.lightImpact();

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
      case 0:
        title = 'Verso';
      case 1:
        title = 'The Bible';
      case 2:
        title = 'Stats';
      case 3:
        title = 'Reading Journal';
      default:
        title = 'Verso';
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
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_off,
                            size: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
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
      extendBody: true,
      bottomNavigationBar: _VersoBottomNav(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _goBranch,
      ),
    );
  }
}

// CUSTOM BOTTOM NAVIGATION BAR

class _VersoBottomNav extends StatelessWidget {
  const _VersoBottomNav({
    required this.currentIndex,
    required this.onTap,
  });
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
      label: 'Bible',
    ),
    _NavItem(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      label: 'Stats',
    ),
    _NavItem(
      icon: Icons.history_edu_outlined,
      activeIcon: Icons.history_edu_rounded,
      label: 'Journal',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isAmoled = !isLight && scheme.surface == const Color(0xFF000000);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Map selected index -> alignment x in the range [-1, 1] so the pill sits
    // centered on the selected slot. Formula derived from N equal-width slots.
    final itemCount = _items.length;
    final alignX =
        itemCount > 1 ? -1.0 + (2.0 * currentIndex / (itemCount - 1)) : 0.0;

    return Container(
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: bottomPadding > 0 ? bottomPadding : 12,
      ),
      decoration: BoxDecoration(
        color:
            isLight ? scheme.surface : scheme.surface.withValues(alpha: 0.95),
        borderRadius: AppRadii.borderRadiusXL,
        border: Border.all(
          color: isLight 
              ? scheme.outline.withValues(alpha: 0.1) 
              : (isAmoled ? scheme.outline : scheme.outline.withValues(alpha: 0.2)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.08 : 0.25),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
          if (isLight)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadii.borderRadiusXL,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Stack(
            children: [
              // Sliding pill: a single element that glides between slots.
              // FractionallySizedBox sizes it to 1/N of the row, AnimatedAlign
              // moves it; both together replace N per-item fade-in backgrounds.
              Positioned.fill(
                child: AnimatedAlign(
                  alignment: Alignment(alignX, 0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: FractionallySizedBox(
                    widthFactor: 1 / itemCount,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.primary
                            .withValues(alpha: isLight ? 0.1 : 0.15),
                        borderRadius: AppRadii.borderRadiusLG,
                      ),
                    ),
                  ),
                ),
              ),
              // Tap targets sit above the pill. They no longer render their
              // own background — the sliding pill is the selection indicator.
              Row(
                children: List.generate(itemCount, (i) {
                  final item = _items[i];
                  final isSelected = currentIndex == i;

                  return Expanded(
                    child: _NavItemWidget(
                      item: item,
                      isSelected: isSelected,
                      onTap: () => onTap(i),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavItemWidget extends StatelessWidget {
  const _NavItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated icon
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                key: ValueKey(isSelected),
                size: isSelected ? 26 : 24,
                color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: isSelected ? 11.5 : 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                letterSpacing: 0.2,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
