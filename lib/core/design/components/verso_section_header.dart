import 'package:flutter/material.dart';
import 'package:verso/core/design/tokens/radii.dart';

/// Section title with optional "See All" action.
///
/// ```dart
/// VersoSectionHeader(
///   title: 'Recent Activity',
///   action: 'See All',
///   onAction: () => context.push('/activity'),
/// )
/// ```
class VersoSectionHeader extends StatelessWidget {
  const VersoSectionHeader({
    required this.title,
    super.key,
    this.action,
    this.onAction,
  });
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 3.5,
              height: 16,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scheme.primary,
                    scheme.secondary,
                  ],
                ),
                borderRadius: AppRadii.borderRadiusFull,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        if (action != null && onAction != null)
          Material(
            color: scheme.primary.withValues(alpha: 0.08),
            borderRadius: AppRadii.borderRadiusFull,
            child: InkWell(
              onTap: onAction,
              borderRadius: AppRadii.borderRadiusFull,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      action!,
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 14,
                      color: scheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
