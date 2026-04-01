import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tokens/spacing.dart';
import '../tokens/radii.dart';

/// Styled text field used across auth and form screens.
///
/// Supports both [TextFormField] (with [validator]) and plain [TextField] usage.
///
/// ```dart
/// VersoTextField(
///   controller: _emailController,
///   label: 'Email',
///   icon: Icons.mail_outline_rounded,
///   keyboardType: TextInputType.emailAddress,
/// )
/// ```
class VersoTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool autocorrect;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const VersoTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.autocorrect = true,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final decoration = InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        color: colorScheme.onSurfaceVariant,
      ),
      prefixIcon: Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : colorScheme.primary.withValues(alpha: 0.04),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: AppRadii.borderRadiusMD,
        borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadii.borderRadiusMD,
        borderSide: BorderSide(
          color: colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadii.borderRadiusMD,
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadii.borderRadiusMD,
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadii.borderRadiusMD,
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
    );

    final style = GoogleFonts.plusJakartaSans(
      fontSize: 15,
      color: colorScheme.onSurface,
    );

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      autocorrect: autocorrect,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      style: style,
      decoration: decoration,
      validator: validator,
    );
  }
}