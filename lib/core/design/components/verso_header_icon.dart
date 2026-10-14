import 'package:flutter/material.dart';
import 'package:verso/core/design/extensions.dart';
import 'package:verso/core/design/tokens/radii.dart';

/// A gradient rounded-square icon used as the header on auth screens.
///
/// ```dart
/// VersoHeaderIcon(icon: Icons.lock_reset_rounded)
/// ```
class VersoHeaderIcon extends StatelessWidget {
  const VersoHeaderIcon({
    required this.icon,
    super.key,
    this.size = 76,
    this.iconSize = 34,
  });
  final IconData icon;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.xl + 6),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [palette.primary, palette.primaryHover],
          ),
          borderRadius: AppRadii.borderRadiusXL,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: palette.primary.withValues(alpha: 0.32),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}
