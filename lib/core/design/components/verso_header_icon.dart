import 'package:flutter/material.dart';
import 'package:verso/core/design/tokens/colors.dart';
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
    this.size = 72,
    this.iconSize = 32,
  });
  final IconData icon;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.primaryDark, AppColors.primaryAccentDark]
              : [AppColors.primaryLight, AppColors.primaryAccentLight],
        ),
        borderRadius: AppRadii.borderRadiusXL,
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                .withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, size: iconSize, color: Colors.white),
    );
  }
}
