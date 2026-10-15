import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/shadows.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadii.borderRadiusLG,
        border: Border.all(
          color: scheme.outline.withValues(alpha: isLight ? 0.65 : 0.25),
        ),
        boxShadow: isLight ? AppShadows.sm : AppShadows.none,
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
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: scheme.onSurface,
                    ),
                  ),
                  if (!_isAtPresent)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Tap to return to present',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
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
              ? scheme.primary.withValues(alpha: isLight ? 0.1 : 0.16)
              : scheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: AppRadii.borderRadiusSM,
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled
              ? scheme.primary
              : scheme.onSurfaceVariant.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
