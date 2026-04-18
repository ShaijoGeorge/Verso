import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verso/core/design/components/verso_auth_gradient.dart';
import 'package:verso/core/design/components/verso_gradient_button.dart';
import 'package:verso/core/design/components/verso_header_icon.dart';
import 'package:verso/core/design/components/verso_snackbar.dart';
import 'package:verso/core/design/components/verso_text_field.dart';
import 'package:verso/core/design/tokens/colors.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/spacing.dart';
import 'package:verso/core/utils/app_error_handler.dart';
import 'package:verso/core/widgets/confirmation_view.dart';
import 'package:verso/features/auth/providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
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
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
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
        decoration: BoxDecoration(gradient: VersoAuthGradient.of(context)),
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
                                  const VersoHeaderIcon(
                                    icon: Icons.lock_reset_rounded,
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
                                    "Enter your email and we'll send you\na link to reset your password.",
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
                                        color: colorScheme.outline.withValues(
                                          alpha: isDark ? 0.15 : 0.4,
                                        ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        VersoTextField(
                                          controller: _emailController,
                                          label: 'Email',
                                          icon: Icons.mail_outline_rounded,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                        ),
                                        const Gap(Spacing.lg),
                                        VersoGradientButton(
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
