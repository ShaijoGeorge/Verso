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
    this.contentPadding,
  });
  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? contentPadding;

  /// Shows this bottom sheet as a modal.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    Color? backgroundColor,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadii.xxl),
          topRight: Radius.circular(AppRadii.xxl),
        ),
      ),
      builder: (_) => VersoBottomSheet(
        title: title,
        contentPadding: contentPadding,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomInset > 0 ? bottomInset : bottomPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.25),
              borderRadius: AppRadii.borderRadiusFull,
            ),
          ),
          if (title != null) ...[
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: Text(
                title!,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 14),
            Divider(
              height: 1,
              color: scheme.outline.withValues(alpha: 0.15),
            ),
          ],
          const SizedBox(height: Spacing.sm),
          Flexible(
            child: Padding(
              padding: contentPadding ?? Spacing.horizontalLG,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
