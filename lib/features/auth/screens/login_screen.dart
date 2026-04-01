import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_providers.dart';
import '../../../core/utils/app_error_handler.dart';
import '../../../core/design/components/verso_snackbar.dart';
import '../../../core/design/tokens/colors.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/tokens/radii.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  final _storage = const FlutterSecureStorage();

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();

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
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // Load credentials if they exist
  Future<void> _loadSavedCredentials() async {
    try {
      final savedEmail = await _storage.read(key: 'email');
      final savedPassword = await _storage.read(key: 'password');

      if (savedEmail != null && savedPassword != null) {
        setState(() {
          _emailController.text = savedEmail;
          _passwordController.text = savedPassword;
          _rememberMe = true;
        });
      }
    } catch (e) {
      // Silently ignore credential loading errors
    }
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created! Please Log In.')),
          );
          setState(() => _isSignUp = false);
        }
      } else {
        await auth.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        // Handle Remember Me Logic (Save AFTER login succeeds)
        if (_rememberMe) {
          await _storage.write(key: 'email', value: _emailController.text.trim());
          await _storage.write(key: 'password', value: _passwordController.text.trim());
        } else {
          await _storage.delete(key: 'email');
          await _storage.delete(key: 'password');
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0F2640),
                    AppColors.backgroundDark,
                    const Color(0xFF0D0D0F),
                  ]
                : [
                    const Color(0xFFD6E8F5),
                    AppColors.backgroundLight,
                    const Color(0xFFF0F2F5),
                  ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
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
                      _BrandHeader(isDark: isDark, colorScheme: colorScheme),
                      const Gap(Spacing.xxl),

                      // Form card
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: AppRadii.borderRadiusXL,
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.4),
                          ),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: AppColors.primaryLight.withValues(alpha: 0.06),
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
                                          _StyledTextField(
                                            controller: _nameController,
                                            label: 'Full Name',
                                            icon: Icons.person_outline_rounded,
                                            textCapitalization: TextCapitalization.words,
                                            validator: (value) =>
                                                value!.isEmpty ? 'Please enter your name' : null,
                                          ),
                                          const Gap(Spacing.md),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),

                              // Email
                              _StyledTextField(
                                controller: _emailController,
                                label: 'Email',
                                icon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                validator: (value) =>
                                    value!.contains('@') ? null : 'Please enter a valid email',
                              ),
                              const Gap(Spacing.md),

                              // Password
                              _StyledTextField(
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
                                    setState(() => _isPasswordVisible = !_isPasswordVisible);
                                  },
                                ),
                                validator: (value) => value!.length < 6
                                    ? 'Password must be at least 6 characters'
                                    : null,
                              ),

                              // Remember me & Forgot password
                              if (!_isSignUp) ...[
                                const Gap(Spacing.sm),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () => setState(() => _rememberMe = !_rememberMe),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: Checkbox(
                                              value: _rememberMe,
                                              activeColor: colorScheme.primary,
                                              onChanged: (value) {
                                                setState(() => _rememberMe = value ?? false);
                                              },
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize.shrinkWrap,
                                              visualDensity: VisualDensity.compact,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                          const Gap(Spacing.sm),
                                          Text(
                                            'Remember me',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => GoRouter.of(context).push('/forgot-password'),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: Spacing.sm,
                                          vertical: Spacing.xs,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                              _PrimaryButton(
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
                            _isSignUp ? 'Already have an account?' : 'New to Verso?',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: _toggleMode,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
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

// Brand header with icon and app name

class _BrandHeader extends StatelessWidget {
  final bool isDark;
  final ColorScheme colorScheme;

  const _BrandHeader({required this.isDark, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
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
          child: const Icon(
            Icons.auto_stories_rounded,
            size: 36,
            color: Colors.white,
          ),
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
    );
  }
}

// Styled text field with consistent design

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool autocorrect;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _StyledTextField({
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

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      autocorrect: autocorrect,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        color: colorScheme.onSurface,
      ),
      decoration: InputDecoration(
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
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderRadiusMD,
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderRadiusMD,
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderRadiusMD,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderRadiusMD,
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}

// Primary CTA button

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
