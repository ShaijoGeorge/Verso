import 'package:flutter/material.dart';

/// Stacks every `StatefulShellRoute` branch navigator and cross-fades between
/// them on tab change.
///
/// All branches are always mounted so Riverpod state, scroll positions, and
/// text inputs survive tab switches. `TickerMode(enabled: isActive)` pauses
/// animations in inactive branches so offscreen work stays quiet.
class AnimatedBranchContainer extends StatelessWidget {
  const AnimatedBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(children.length, (int index) {
        final bool isActive = index == currentIndex;
        // AnimatedOpacity MUST sit above TickerMode: its internal ticker drives
        // the fade, so disabling tickers around it would freeze the animation
        // mid-tween and leave an inactive branch painted at full opacity.
        return IgnorePointer(
          ignoring: !isActive,
          child: AnimatedOpacity(
            opacity: isActive ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOutCubic,
            child: TickerMode(
              enabled: isActive,
              child: children[index],
            ),
          ),
        );
      }),
    );
  }
}
