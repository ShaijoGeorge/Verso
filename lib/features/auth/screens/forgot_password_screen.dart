import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_providers.dart';
import '../../../core/widgets/confirmation_view.dart';
import '../../../core/utils/app_error_handler.dart';
import '../../../core/design/components/verso_snackbar.dart';
import '../../../core/design/tokens/colors.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/tokens/radii.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;

  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      VersoSnackbar.error(context, message: 'Please enter a valid email');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authRepositoryProvider).resetPassword(email);
      if (mounted) {
        setState(() => _isSuccess = true);
      }
    } catch (e) {
      if (mounted) {
        VersoSnackbar.error(context, message: AppErrorHandler.getMessage(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0F2640), AppColors.backgroundDark, const Color(0xFF0D0D0F)]
                : [const Color(0xFFD6E8F5), AppColors.backgroundLight, const Color(0xFFF0F2F5)],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: _isSuccess
              ? ConfirmationView(
                  title: 'Check your inbox',
                  subtitle:
                      'We sent a password reset link to ${_emailController.text}. Follow the link to create a new password.',
                  buttonText: 'Back to Login',
                  icon: Icons.mark_email_read_outlined,
                  onPressed: () => Navigator.pop(context),
                )
              : Column(
                  children: [
                    // Custom app bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm,
                        vertical: Spacing.sm,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: Spacing.pagePadding,
                          child: FadeTransition(
                            opacity: _fadeIn,
                            child: SlideTransition(
                              position: _slideUp,
                              child: Column(
                                children: [
                                  // Icon
                                  _HeaderIcon(
                                    icon: Icons.lock_reset_rounded,
                                    isDark: isDark,
                                  ),
                                  const Gap(Spacing.lg),

                                  Text(
                                    'Reset Password',
                                    style: GoogleFonts.dmSerifDisplay(
                                      fontSize: 28,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const Gap(Spacing.sm),
                                  Text(
                                    'Enter your email and we\'ll send you\na link to reset your password.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      color: colorScheme.onSurfaceVariant,
                                      height: 1.6,
                                    ),
                                  ),
                                  const Gap(Spacing.xl),

                                  // Form card
                                  Container(
                                    decoration: BoxDecoration(
                                      color: colorScheme.surface,
                                      borderRadius: AppRadii.borderRadiusXL,
                                      border: Border.all(
                                        color: colorScheme.outline
                                            .withValues(alpha: isDark ? 0.15 : 0.4),
                                      ),
                                      boxShadow: isDark
                                          ? []
                                          : [
                                              BoxShadow(
                                                color: AppColors.primaryLight
                                                    .withValues(alpha: 0.06),
                                                blurRadius: 40,
                                                offset: const Offset(0, 16),
                                              ),
                                            ],
                                    ),
                                    padding: const EdgeInsets.all(Spacing.lg),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        _StyledTextField(
                                          controller: _emailController,
                                          label: 'Email',
                                          icon: Icons.mail_outline_rounded,
                                          keyboardType: TextInputType.emailAddress,
                                        ),
                                        const Gap(Spacing.lg),
                                        _PrimaryButton(
                                          label: 'Send Reset Link',
                                          isLoading: _isLoading,
                                          onPressed: _submit,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// Shared styled widgets

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final bool isDark;

  const _HeaderIcon({required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF7EB8E0), const Color(0xFF4A8BBF)]
              : [const Color(0xFF1B3A5C), const Color(0xFF2A5580)],
        ),
        borderRadius: AppRadii.borderRadiusXL,
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF7EB8E0) : const Color(0xFF1B3A5C))
                .withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, size: 32, color: Colors.white),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  const _StyledTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.plusJakartaSans(fontSize: 15, color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: colorScheme.onSurfaceVariant),
        prefixIcon: Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : colorScheme.primary.withValues(alpha: 0.04),
        contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.md),
        border: OutlineInputBorder(
          borderRadius: AppRadii.borderRadiusMD,
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderRadiusMD,
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderRadiusMD,
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? const Color(0xFF7EB8E0) : const Color(0xFF1B3A5C);

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
                  ? [primary.withValues(alpha: 0.6), primary.withValues(alpha: 0.5)]
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
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
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