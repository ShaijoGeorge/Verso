import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verso/core/design/components/verso_gradient_button.dart';
import 'package:verso/core/design/extensions.dart';
import 'package:verso/core/design/tokens/spacing.dart';

class ConfirmationView extends StatefulWidget {
  const ConfirmationView({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
    super.key,
    this.icon = Icons.check_circle_outline_rounded,
    this.accentColor,
    this.titleColor,
    this.subtitleColor,
    this.buttonColor,
  });
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;
  final IconData icon;
  final Color? accentColor;
  final Color? titleColor;
  final Color? subtitleColor;
  final Color? buttonColor;

  @override
  State<ConfirmationView> createState() => _ConfirmationViewState();
}

class _ConfirmationViewState extends State<ConfirmationView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleIn;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _scaleIn = Tween<double>(begin: 0.82, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = widget.accentColor ?? context.appColors.success;
    final titleColor = widget.titleColor ?? colorScheme.onSurface;
    final subtitleColor = widget.subtitleColor ?? colorScheme.onSurfaceVariant;

    return Center(
      child: SingleChildScrollView(
        padding: Spacing.pagePadding,
        child: FadeTransition(
          opacity: _fadeIn,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated icon
                ScaleTransition(
                  scale: _scaleIn,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withValues(alpha: 0.08),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.16),
                      ),
                    ),
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            accentColor.withValues(alpha: 0.22),
                            accentColor.withValues(alpha: 0.06),
                          ],
                        ),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 42,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
                const Gap(Spacing.xl),

                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 30,
                    color: titleColor,
                  ),
                ),
                const Gap(Spacing.sm),

                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    color: subtitleColor,
                    height: 1.6,
                  ),
                ),
                const Gap(Spacing.xl),

                // Button
                SizedBox(
                  width: double.infinity,
                  child: VersoGradientButton(
                    label: widget.buttonText,
                    onPressed: widget.onPressed,
                    color: widget.buttonColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
