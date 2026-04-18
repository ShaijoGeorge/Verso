import 'package:flutter/material.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/spacing.dart';

/// Standardized bottom sheet with drag handle and optional title.
///
/// ```dart
/// VersoBottomSheet.show(
///   context: context,
///   title: 'Choose Option',
///   child: Column(...),
/// );
/// ```
class VersoBottomSheet extends StatelessWidget {
  const VersoBottomSheet({
    required this.child,
    super.key,
    this.title,
  });
  final String? title;
  final Widget child;

  /// Shows this bottom sheet as a modal.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadii.xl),
          topRight: Radius.circular(AppRadii.xl),
        ),
      ),
      builder: (_) => VersoBottomSheet(title: title, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: Spacing.sm),
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: AppRadii.borderRadiusFull,
            ),
          ),
          if (title != null) ...[
            const SizedBox(height: Spacing.md),
            Text(title!, style: textTheme.titleMedium),
          ],
          const SizedBox(height: Spacing.md),
          Flexible(
            child: Padding(
              padding: Spacing.horizontalLG,
              child: child,
            ),
          ),
          const SizedBox(height: Spacing.lg),
        ],
      ),
    );
  }
}
