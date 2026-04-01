import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_providers.dart';
import '../../../core/widgets/confirmation_view.dart';
import '../../../core/utils/app_error_handler.dart';
import '../../../core/design/components/verso_snackbar.dart';
import '../../../core/design/components/verso_text_field.dart';
import '../../../core/design/components/verso_gradient_button.dart';
import '../../../core/design/components/verso_header_icon.dart';
import '../../../core/design/components/verso_auth_gradient.dart';
import '../../../core/design/tokens/colors.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/tokens/radii.dart';

class UpdatePasswordScreen extends ConsumerStatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  ConsumerState<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends ConsumerState<UpdatePasswordScreen>
    with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isSuccess = false;
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final newPass = _passwordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    // Validation
    if (newPass.length < 6) {
      VersoSnackbar.error(context, message: 'Password must be at least 6 characters');
      return;
    }

    if (newPass != confirmPass) {
      VersoSnackbar.error(context, message: 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Call Repository
      await ref.read(authRepositoryProvider).updatePassword(newPass);
      if (mounted) {
        // Show Success View instead of immediate navigation
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
                  title: 'Password Updated!',
                  subtitle:
                      'Your password has been changed successfully. You can now continue reading.',
                  buttonText: 'Go to Home',
                  icon: Icons.verified_user_outlined,
                  onPressed: () => context.go('/home'),
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
                                  const VersoHeaderIcon(icon: Icons.shield_outlined),
                                  const Gap(Spacing.lg),
                                  Text(
                                    'Set New Password',
                                    style: GoogleFonts.dmSerifDisplay(
                                      fontSize: 28,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const Gap(Spacing.sm),
                                  Text(
                                    'Your email has been verified.\nChoose a strong new password below.',
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
                                        VersoTextField(
                                          controller: _passwordController,
                                          label: 'New Password',
                                          icon: Icons.lock_outline_rounded,
                                          obscureText: !_isPasswordVisible,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isPasswordVisible
                                                  ? Icons.visibility_outlined
                                                  : Icons.visibility_off_outlined,
                                              size: 20,
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                            onPressed: () {
                                              setState(() =>
                                                  _isPasswordVisible = !_isPasswordVisible);
                                            },
                                          ),
                                        ),
                                        const Gap(Spacing.md),
                                        VersoTextField(
                                          controller: _confirmPasswordController,
                                          label: 'Confirm Password',
                                          icon: Icons.lock_outline_rounded,
                                          obscureText: !_isConfirmVisible,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isConfirmVisible
                                                  ? Icons.visibility_outlined
                                                  : Icons.visibility_off_outlined,
                                              size: 20,
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                            onPressed: () {
                                              setState(
                                                  () => _isConfirmVisible = !_isConfirmVisible);
                                            },
                                          ),
                                        ),
                                        const Gap(Spacing.lg),
                                        VersoGradientButton(
                                          label: 'Update Password',
                                          isLoading: _isLoading,
                                          onPressed: _updatePassword,
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