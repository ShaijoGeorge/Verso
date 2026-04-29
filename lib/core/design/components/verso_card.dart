import 'package:flutter/material.dart';
import 'package:verso/core/design/extensions.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/shadows.dart';
import 'package:verso/core/design/tokens/spacing.dart';
import 'package:verso/data/local/entities/user_settings.dart';

/// A themed card that replaces raw Container decorations.
///
/// ```dart
/// VersoCard(
///   child: Text('Hello'),
/// )
/// ```
class VersoCard extends StatelessWidget {
  const VersoCard({
    required this.child,
    super.key,
    this.padding,
    this.color,
    this.shadow,
    this.borderRadius,
    this.border,
    this.onTap,
  });
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final List<BoxShadow>? shadow;
  final BorderRadiusGeometry? borderRadius;
  final Border? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isAmoled = context.palette.style == AppearanceStyle.amoled;

    final content = Container(
      padding: padding ?? Spacing.cardPadding,
      decoration: BoxDecoration(
        color: color ?? scheme.surface,
        borderRadius: borderRadius ?? AppRadii.borderRadiusLG,
        border: border ??
            Border.all(
              color: isAmoled
                  ? scheme.outline
                  : scheme.outline.withValues(alpha: isLight ? 0.5 : 0.15),
            ),
        boxShadow: shadow ?? AppShadows.sm,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}
