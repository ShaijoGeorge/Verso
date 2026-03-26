import 'package:flutter/material.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';

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
  final String? title;
  final Widget child;

  const VersoBottomSheet({
    super.key,
    this.title,
    required this.child,
  });

  /// Shows this bottom sheet as a modal.
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
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
