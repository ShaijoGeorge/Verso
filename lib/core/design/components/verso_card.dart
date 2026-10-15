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
    this.gradient,
    this.shadow,
    this.borderRadius,
    this.border,
    this.onTap,
  });
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Gradient? gradient;
  final List<BoxShadow>? shadow;
  final BorderRadiusGeometry? borderRadius;
  final Border? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isAmoled = context.palette.style == AppearanceStyle.amoled;
    final resolvedRadius = borderRadius ?? AppRadii.borderRadiusLG;

    final effectiveBorder = border ??
        Border.all(
          color: isAmoled
              ? scheme.outline.withValues(alpha: 0.85)
              : scheme.outline.withValues(alpha: isLight ? 0.65 : 0.25),
        );

    final decoration = BoxDecoration(
      color: gradient == null ? (color ?? scheme.surface) : null,
      gradient: gradient,
      borderRadius: resolvedRadius,
      border: effectiveBorder,
      boxShadow: shadow ?? (isLight ? AppShadows.sm : AppShadows.none),
    );

    if (onTap != null) {
      return Container(
        decoration: decoration,
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius:
                resolvedRadius is BorderRadius ? resolvedRadius : null,
            splashColor: scheme.primary.withValues(alpha: 0.06),
            highlightColor: scheme.primary.withValues(alpha: 0.03),
            child: Padding(
              padding: padding ?? Spacing.cardPadding,
              child: child,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: padding ?? Spacing.cardPadding,
      decoration: decoration,
      child: child,
    );
  }
}
