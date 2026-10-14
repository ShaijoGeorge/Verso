import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verso/core/design/extensions.dart';
import 'package:verso/core/design/tokens/radii.dart';

/// A gradient-filled CTA button with a glow shadow, used on auth screens.
///
/// ```dart
/// VersoGradientButton(
///   label: 'Sign In',
///   isLoading: _isLoading,
///   onPressed: _submit,
/// )
/// ```
class VersoGradientButton extends StatelessWidget {
  const VersoGradientButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.color,
  });
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  /// Override the default primary gradient color.
  /// Defaults to the app's primary based on theme palette.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final primary = color ?? palette.primary;
    final secondaryStop =
        color != null ? primary.withValues(alpha: 0.85) : palette.primaryHover;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: AppRadii.borderRadiusMD,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isLoading
                  ? [
                      primary.withValues(alpha: 0.6),
                      secondaryStop.withValues(alpha: 0.5),
                    ]
                  : [primary, secondaryStop],
            ),
            borderRadius: AppRadii.borderRadiusMD,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
            ),
            boxShadow: isLoading
                ? []
                : [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.32),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: primary.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withValues(alpha: 0.9),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
