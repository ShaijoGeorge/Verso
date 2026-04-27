import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verso/core/design/tokens/colors.dart';
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
  /// Defaults to the app's primary (deep navy / soft sky) based on theme.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary =
        color ?? (isDark ? AppColors.primaryDark : AppColors.primaryLight);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: AppRadii.borderRadiusMD,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLoading
                  ? [
                      primary.withValues(alpha: 0.6),
                      primary.withValues(alpha: 0.5),
                    ]
                  : [primary, primary.withValues(alpha: 0.85)],
            ),
            borderRadius: AppRadii.borderRadiusMD,
            boxShadow: isLoading
                ? []
                : [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
