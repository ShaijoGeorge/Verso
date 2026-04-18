import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimePeriodNavigator extends StatelessWidget {
  // tap label to jump back to "now"

  const TimePeriodNavigator({
    required this.label,
    required this.onPrevious,
    super.key,
    this.onNext,
    this.onReset,
  });
  final String label;
  final VoidCallback onPrevious;
  final VoidCallback? onNext; // null = at present, disable forward
  final VoidCallback? onReset;

  bool get _isAtPresent => onNext == null;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          // Back arrow
          _NavButton(
            icon: Icons.chevron_left_rounded,
            onTap: () {
              HapticFeedback.selectionClick();
              onPrevious();
            },
            scheme: scheme,
            isLight: isLight,
          ),

          // Center label - tappable to reset when not at present
          Expanded(
            child: GestureDetector(
              onTap: !_isAtPresent
                  ? () {
                      HapticFeedback.selectionClick();
                      onReset?.call();
                    }
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  if (!_isAtPresent)
                    Text(
                      'Tap to return to now',
                      style: TextStyle(
                        fontSize: 10,
                        color: scheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Forward arrow
          _NavButton(
            icon: Icons.chevron_right_rounded,
            onTap: onNext != null
                ? () {
                    HapticFeedback.selectionClick();
                    onNext!();
                  }
                : null,
            scheme: scheme,
            isLight: isLight,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.scheme,
    required this.isLight,
  });
  final IconData icon;
  final VoidCallback? onTap;
  final ColorScheme scheme;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: enabled
              ? scheme.primary.withValues(alpha: isLight ? 0.1 : 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 22,
          color: enabled
              ? scheme.primary
              : scheme.onSurfaceVariant.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
