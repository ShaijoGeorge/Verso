import 'package:flutter/material.dart';
import '../tokens/radii.dart';

/// Button variants for Verso.
enum VersoButtonVariant { primary, secondary, ghost, destructive }

/// A themed button with Primary, Secondary, Ghost, and Destructive variants.
///
/// ```dart
/// VersoButton(
///   label: 'Save',
///   onPressed: () {},
/// )
/// VersoButton.secondary(label: 'Cancel', onPressed: () {})
/// VersoButton.destructive(label: 'Delete', onPressed: () {})
/// ```
class VersoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final VersoButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  const VersoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = VersoButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = false,
  });

  const VersoButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = false,
  }) : variant = VersoButtonVariant.secondary;

  const VersoButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = false,
  }) : variant = VersoButtonVariant.ghost;

  const VersoButton.destructive({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = false,
  }) : variant = VersoButtonVariant.destructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final effectiveOnPressed = isLoading ? null : onPressed;

    final Widget child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == VersoButtonVariant.primary
                  ? scheme.onPrimary
                  : scheme.primary,
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              )
            : Text(label);

    final shape = RoundedRectangleBorder(
      borderRadius: AppRadii.borderRadiusSM,
    );

    Widget button;

    switch (variant) {
      case VersoButtonVariant.primary:
        button = FilledButton(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(shape: shape),
          child: child,
        );
      case VersoButtonVariant.secondary:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(shape: shape),
          child: child,
        );
      case VersoButtonVariant.ghost:
        button = TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(shape: shape),
          child: child,
        );
      case VersoButtonVariant.destructive:
        button = FilledButton(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
            shape: shape,
          ),
          child: child,
        );
    }

    if (expand) {
      return SizedBox(width: double.infinity, height: 50, child: button);
    }
    return button;
  }
}
