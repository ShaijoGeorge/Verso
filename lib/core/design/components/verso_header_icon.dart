import 'package:flutter/material.dart';
import '../tokens/radii.dart';

/// A gradient rounded-square icon used as the header on auth screens.
///
/// ```dart
/// VersoHeaderIcon(icon: Icons.lock_reset_rounded)
/// ```
class VersoHeaderIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;

  const VersoHeaderIcon({
    super.key,
    required this.icon,
    this.size = 72,
    this.iconSize = 32,
  });

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
              ? [const Color(0xFF7EB8E0), const Color(0xFF4A8BBF)]
              : [const Color(0xFF1B3A5C), const Color(0xFF2A5580)],
        ),
        borderRadius: AppRadii.borderRadiusXL,
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF7EB8E0) : const Color(0xFF1B3A5C))
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
