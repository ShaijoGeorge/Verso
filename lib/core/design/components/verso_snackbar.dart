import 'package:flutter/material.dart';
import 'package:verso/core/design/extensions.dart';
import 'package:verso/core/design/tokens/radii.dart';

/// Themed snackbar helper - replaces raw ScaffoldMessenger calls.
///
/// ```dart
/// VersoSnackbar.show(context, message: 'Saved!');
/// VersoSnackbar.error(context, message: 'Something went wrong');
/// VersoSnackbar.success(context, message: 'Chapter marked as read!');
/// ```
abstract final class VersoSnackbar {
  /// Shows an informational snackbar.
  static void show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.info_outline_rounded,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Shows a success snackbar with green accent.
  static void success(BuildContext context, {required String message}) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: context.appColors.success,
      textColor: Colors.white,
    );
  }

  /// Shows an error snackbar with red accent.
  static void error(BuildContext context, {required String message}) {
    final scheme = Theme.of(context).colorScheme;
    _show(
      context,
      message: message,
      icon: Icons.error_outline_rounded,
      backgroundColor: scheme.error,
      textColor: scheme.onError,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
    Color? backgroundColor,
    Color? textColor,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final fg = textColor ?? scheme.onInverseSurface;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? scheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderRadiusMD),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: fg,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
}
