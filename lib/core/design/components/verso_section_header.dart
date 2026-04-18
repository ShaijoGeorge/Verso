import 'package:flutter/material.dart';

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
        Text(
          title,
          style: textTheme.titleMedium,
        ),
        if (action != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: textTheme.labelMedium?.copyWith(
                color: scheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}
