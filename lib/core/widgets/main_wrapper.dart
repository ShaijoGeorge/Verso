import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verso/core/design/extensions.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/providers/connectivity_provider.dart';
import 'package:verso/core/widgets/verso_avatar.dart';
import 'package:verso/data/local/entities/user_settings.dart';
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
    // 0 = Bible, 1 = Stats, 2 = Home, 3 = History, 4 = Profile

    // Bible Pages Animation Trigger
    if (index == 0 && widget.navigationShell.currentIndex != 0) {
      ref.read(biblePageTriggerProvider.notifier).increment();
    }

    // Stats Tab Trigger - refresh detailed stats and reset to Overview tab
    if (index == 1 && widget.navigationShell.currentIndex != 1) {
      ref.invalidate(detailedStatsProvider);
      ref.read(statsTabResetTriggerProvider.notifier).trigger();
    }

    // Home Page Animation Trigger
    if (index == 2 && widget.navigationShell.currentIndex != 2) {
      ref.invalidate(userStatsProvider);
    }

    // History Trigger
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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Offline indicator banner
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: isOnline
                  ? const SizedBox.shrink()
                  : Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.secondaryContainer.withValues(alpha: 0.9),
                        borderRadius: AppRadii.borderRadiusFull,
                        border: Border.all(
                          color: scheme.secondary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_off_rounded,
                            size: 14,
                            color: scheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Offline mode · Changes will sync when connected',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: scheme.onSecondaryContainer,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            // Main content
            Expanded(child: widget.navigationShell),
          ],
        ),
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
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
      label: 'Bible',
    ),
    _NavItem(
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights_rounded,
      label: 'Stats',
    ),
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      isMiddle: true,
    ),
    _NavItem(
      icon: Icons.history_rounded,
      activeIcon: Icons.history_rounded,
      label: 'History',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
      isAvatar: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isAmoled = context.palette.style == AppearanceStyle.amoled;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final itemCount = _items.length;
    // Map selected index -> alignment x in the range [-1, 1] so the pill sits
    // centered on the selected slot. Formula derived from N equal-width slots.
    final alignX =
        itemCount > 1 ? -1.0 + (2.0 * currentIndex / (itemCount - 1)) : 0.0;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: bottomPadding > 0 ? bottomPadding : 14,
      ),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadii.borderRadiusXXL,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isLight ? 0.08 : 0.35),
                  blurRadius: 32,
                  offset: const Offset(0, 10),
                ),
                if (isLight)
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: AppRadii.borderRadiusXXL,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isAmoled
                        ? scheme.surface.withValues(alpha: 0.92)
                        : scheme.surface
                            .withValues(alpha: isLight ? 0.88 : 0.84),
                    borderRadius: AppRadii.borderRadiusXXL,
                    border: Border.all(
                      color: isAmoled
                          ? scheme.outline.withValues(alpha: 0.8)
                          : (isLight
                              ? scheme.outline.withValues(alpha: 0.55)
                              : Colors.white.withValues(alpha: 0.1)),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Sliding pill: a single element that glides between slots.
                      // FractionallySizedBox sizes it to 1/N of the row, AnimatedAlign
                      // moves it; both together replace N per-item fade-in backgrounds.
                      // Tap targets sit above the pill. They no longer render their
                      // own background - the sliding pill is the selection indicator.
                      Positioned.fill(
                        child: AnimatedAlign(
                          alignment: Alignment(alignX, 0),
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                          child: FractionallySizedBox(
                            widthFactor: 1 / itemCount,
                            heightFactor: 1,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: currentIndex == 2 ? 0.0 : 1.0,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      scheme.primary.withValues(
                                        alpha: isLight ? 0.12 : 0.2,
                                      ),
                                      scheme.primary.withValues(
                                        alpha: isLight ? 0.06 : 0.1,
                                      ),
                                    ],
                                  ),
                                  borderRadius: AppRadii.borderRadiusXL,
                                  border: Border.all(
                                    color: scheme.primary.withValues(
                                      alpha: isLight ? 0.14 : 0.22,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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
            ),
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
    this.isAvatar = false,
    this.isMiddle = false,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isAvatar;
  final bool isMiddle;
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
    final palette = context.palette;

    if (item.isMiddle) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                width: isSelected ? 48 : 44,
                height: isSelected ? 48 : 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSelected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            palette.primary,
                            palette.primaryHover,
                          ],
                        )
                      : null,
                  color:
                      isSelected ? null : scheme.primary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : scheme.primary.withValues(alpha: 0.18),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: scheme.primary.withValues(alpha: 0.38),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: 22,
                  color: isSelected ? scheme.onPrimary : scheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
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
              child: item.isAvatar
                  ? Opacity(
                      opacity: isSelected ? 1.0 : 0.78,
                      child: VersoAvatar(
                        size: isSelected ? 25 : 23,
                        borderWidth: isSelected ? 2.0 : 1.2,
                        borderColor: isSelected
                            ? scheme.primary
                            : scheme.onSurfaceVariant.withValues(alpha: 0.3),
                      ),
                    )
                  : Icon(
                      isSelected ? item.activeIcon : item.icon,
                      key: ValueKey(isSelected),
                      size: isSelected ? 23 : 22,
                      color:
                          isSelected ? scheme.primary : scheme.onSurfaceVariant,
                    ),
            ),
            const SizedBox(height: 3),
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: isSelected ? 11 : 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                letterSpacing: 0.15,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
