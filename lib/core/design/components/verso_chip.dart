import 'package:flutter/material.dart';
import 'package:verso/core/design/tokens/radii.dart';

/// A themed chip / tag for Activity Log and similar contexts.
///
/// ```dart
/// VersoChip(text: 'Mass Update', color: Colors.orange)
/// VersoChip.icon(text: 'Completed', icon: Icons.star, color: Colors.amber)
/// ```
class VersoChip extends StatelessWidget {
  const VersoChip({
    required this.text,
    required this.color,
    super.key,
    this.textColor,
    this.icon,
  });

  const VersoChip.icon({
    required this.text,
    required this.color,
    required IconData this.icon,
    super.key,
    this.textColor,
  });
  final String text;

  /// Background color (will be applied at 12% opacity with a subtle border).
  final Color color;

  /// Optional explicit text color. If null, uses [color] at full opacity.
  final Color? textColor;

  /// Optional leading icon.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fgColor = textColor ?? color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadii.borderRadiusFull,
        border: Border.all(
          color: color.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fgColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }
}
