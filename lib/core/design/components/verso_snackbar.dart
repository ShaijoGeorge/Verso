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
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Shows a success snackbar with green accent.
  static void success(BuildContext context, {required String message}) {
    _show(
      context,
      message: message,
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
      backgroundColor: scheme.error,
      textColor: scheme.onError,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Color? backgroundColor,
    Color? textColor,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: textColor != null ? TextStyle(color: textColor) : null,
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderRadiusSM),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: textColor,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
}
