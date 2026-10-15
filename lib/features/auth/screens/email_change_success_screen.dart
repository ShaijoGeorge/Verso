import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verso/core/design/components/verso_auth_gradient.dart';
import 'package:verso/core/design/components/verso_gradient_button.dart';
import 'package:verso/core/design/extensions.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/spacing.dart';
import 'package:verso/features/auth/providers/auth_providers.dart';

class EmailChangeSuccessScreen extends ConsumerStatefulWidget {
  const EmailChangeSuccessScreen({
    super.key,
    this.email,
    this.isStepOne = false,
  });

  final String? email;
  final bool isStepOne;

  @override
  ConsumerState<EmailChangeSuccessScreen> createState() =>
      _EmailChangeSuccessScreenState();
}

class _EmailChangeSuccessScreenState
    extends ConsumerState<EmailChangeSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleIn;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleIn = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();

    // Clear any pending email change record now that the confirmation is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isStepOne) {
        ref.read(authRepositoryProvider).clearPendingEmailChange();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor =
        widget.isStepOne ? (colorScheme.primary) : (context.appColors.success);

    final displayEmail =
        widget.email ?? ref.watch(authUserProvider).value?.email;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/home');
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: VersoAuthGradient.of(context)),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: Spacing.pagePadding,
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: SlideTransition(
                    position: _slideUp,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated Glowing Ring & Icon
                          ScaleTransition(
                            scale: _scaleIn,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accentColor.withValues(alpha: 0.06),
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.15),
                                ),
                              ),
                              child: Container(
                                width: 92,
                                height: 92,
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
                                  widget.isStepOne
                                      ? Icons.mark_email_unread_outlined
                                      : Icons.mark_email_read_outlined,
                                  size: 44,
                                  color: accentColor,
                                ),
                              ),
                            ),
                          ),
                          const Gap(Spacing.xl),

                          // Heading
                          Text(
                            widget.isStepOne
                                ? 'First Step Confirmed'
                                : 'Email Updated!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 32,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const Gap(Spacing.md),

                          // Email Badge (if email is known and this is final confirmation)
                          if (!widget.isStepOne &&
                              displayEmail != null &&
                              displayEmail.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest
                                    .withValues(alpha: isDark ? 0.35 : 0.6),
                                borderRadius: AppRadii.borderRadiusFull,
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    size: 16,
                                    color: accentColor,
                                  ),
                                  const Gap(8),
                                  Flexible(
                                    child: Text(
                                      displayEmail,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Gap(Spacing.md),
                          ],

                          // Subtitle description
                          Text(
                            widget.isStepOne
                                ? 'Confirmation link accepted! To finish updating your email, please check your other email address and click the link sent there.'
                                : 'Your email address has been successfully verified and updated. You can now use your new email address to sign in.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              color: colorScheme.onSurfaceVariant,
                              height: 1.6,
                            ),
                          ),
                          const Gap(Spacing.xxl),

                          // Primary Button
                          SizedBox(
                            width: double.infinity,
                            child: VersoGradientButton(
                              label: widget.isStepOne
                                  ? 'Got It'
                                  : 'Continue to Home',
                              onPressed: () => context.go('/home'),
                            ),
                          ),

                          // Secondary action for confirmed email
                          if (!widget.isStepOne) ...[
                            const Gap(Spacing.sm),
                            TextButton.icon(
                              onPressed: () => context.go('/profile'),
                              icon: Icon(
                                Icons.person_outline_rounded,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                              label: Text(
                                'View Profile',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
