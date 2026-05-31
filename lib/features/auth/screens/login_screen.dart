import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verso/core/design/components/verso_auth_gradient.dart';
import 'package:verso/core/design/components/verso_gradient_button.dart';
import 'package:verso/core/design/components/verso_header_icon.dart';
import 'package:verso/core/design/components/verso_snackbar.dart';
import 'package:verso/core/design/components/verso_text_field.dart';
import 'package:verso/core/design/tokens/colors.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/spacing.dart';
import 'package:verso/core/utils/app_error_handler.dart';
import 'package:verso/features/auth/providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // "Remember me" state - true means we save the email for next time
  bool _rememberMe = false;

  // The SharedPreferences key - a constant so we never mistype it
  static const _rememberedEmailKey = 'remembered_email';

  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeIn = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animController.forward();

    // Load any previously remembered email right after the widget initialises
    _loadRememberedEmail();
  }

  // Read the saved email from disk and pre-fills the field + checkbox
  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_rememberedEmailKey);
    if (saved != null && saved.isNotEmpty) {
      // Only run setState if the widget is still mounted
      if (mounted) {
        setState(() {
          _emailController.text = saved;
          _rememberMe = true; // If we have a saved email, tick the box
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final auth = ref.read(authRepositoryProvider);

      if (_isSignUp) {
        await auth.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
        );
        if (mounted) {
          VersoSnackbar.success(
            context,
            message: 'Account created! Please Log In.',
          );
          setState(() => _isSignUp = false);
        }
      } else {
        await auth.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        // Save or clear the email depending on the checkbox
        final prefs = await SharedPreferences.getInstance();
        if (_rememberMe) {
          // We ONLY save the email - never the password
          await prefs.setString(
            _rememberedEmailKey,
            _emailController.text.trim(),
          );
        } else {
          // User opted out - clear any previously saved email
          await prefs.remove(_rememberedEmailKey);
        }

        // Router handles navigation via auth state change
      }
    } catch (e) {
      if (mounted) {
        VersoSnackbar.error(context, message: AppErrorHandler.getMessage(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleMode() {
    setState(() => _isSignUp = !_isSignUp);
    _animController.reset();
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo and branding
                      Column(
                        children: [
                          const VersoHeaderIcon(
                            icon: Icons.auto_stories_rounded,
                            iconSize: 36,
                          ),
                          const Gap(Spacing.md),
                          Text(
                            'Verso',
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 32,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const Gap(Spacing.xxl),

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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Form title
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  _isSignUp ? 'Create Account' : 'Welcome Back',
                                  key: ValueKey(_isSignUp),
                                  style: GoogleFonts.dmSerifDisplay(
                                    fontSize: 26,
                                    color: colorScheme.onSurface,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              const Gap(4),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  _isSignUp
                                      ? 'Start your Bible reading journey'
                                      : 'Sign in to continue reading',
                                  key: ValueKey('sub_$_isSignUp'),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              const Gap(Spacing.lg),

                              // Name Field (Sign Up only)
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                child: _isSignUp
                                    ? Column(
                                        children: [
                                          VersoTextField(
                                            controller: _nameController,
                                            label: 'Full Name',
                                            icon: Icons.person_outline_rounded,
                                            textCapitalization:
                                                TextCapitalization.words,
                                            validator: (value) => value!.isEmpty
                                                ? 'Please enter your name'
                                                : null,
                                          ),
                                          const Gap(Spacing.md),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),

                              // Email
                              VersoTextField(
                                controller: _emailController,
                                label: 'Email',
                                icon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                validator: (value) => value!.contains('@')
                                    ? null
                                    : 'Please enter a valid email',
                              ),
                              const Gap(Spacing.md),

                              // Password
                              VersoTextField(
                                controller: _passwordController,
                                label: 'Password',
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
                                    setState(
                                      () => _isPasswordVisible =
                                          !_isPasswordVisible,
                                    );
                                  },
                                ),
                                validator: (value) => value!.length < 6
                                    ? 'Password must be at least 6 characters'
                                    : null,
                              ),

                              if (!_isSignUp) ...[
                                const Gap(Spacing.sm),
                                // Row holds both "Remember me" and "Forgot password?" side by side
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Remember Me checkbox
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Checkbox(
                                            value: _rememberMe,
                                            // Toggle the flag on tap
                                            onChanged: (value) => setState(
                                              () =>
                                                  _rememberMe = value ?? false,
                                            ),
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        ),
                                        const Gap(Spacing.xs),
                                        Text(
                                          'Remember me',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Forgot Password link
                                    TextButton(
                                      onPressed: () => GoRouter.of(context)
                                          .push('/forgot-password'),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: Spacing.sm,
                                          vertical: Spacing.xs,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Forgot password?',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              const Gap(Spacing.lg),

                              // Submit button
                              VersoGradientButton(
                                label: _isSignUp ? 'Create Account' : 'Sign In',
                                isLoading: _isLoading,
                                onPressed: _submit,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Gap(Spacing.lg),

                      // Toggle sign up / sign in
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isSignUp
                                ? 'Already have an account?'
                                : 'New to Verso?',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: _toggleMode,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Spacing.sm,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              _isSignUp ? 'Sign In' : 'Create Account',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
