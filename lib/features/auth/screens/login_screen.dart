import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso/core/design/components/verso_auth_gradient.dart';
import 'package:verso/core/design/components/verso_gradient_button.dart';
import 'package:verso/core/design/components/verso_header_icon.dart';
import 'package:verso/core/design/components/verso_snackbar.dart';
import 'package:verso/core/design/components/verso_text_field.dart';
import 'package:verso/core/design/tokens/colors.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/spacing.dart';
import 'package:verso/core/utils/app_error_handler.dart';
import 'package:verso/features/auth/models/saved_account.dart';
import 'package:verso/features/auth/providers/auth_providers.dart';
import 'package:verso/features/auth/services/account_switch_service.dart';
import 'package:verso/features/auth/services/saved_accounts_service.dart';
import 'package:verso/features/home/providers/home_providers.dart';
import 'package:verso/features/reading/providers/reading_providers.dart';
import 'package:verso/features/reading/services/reading_service.dart';
import 'package:verso/features/settings/providers/settings_providers.dart';
import 'package:verso/features/stats/providers/activity_providers.dart';
import 'package:verso/features/stats/providers/stats_providers.dart';

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

        // ── Data Restoration on Login ─────────────────────────────────────────
        final user = Supabase.instance.client.auth.currentUser;
        var remoteCanon = user?.userMetadata?['canon_type'] as String?;

        // Fallback: check remote 'profiles' table if configured in Supabase
        if (remoteCanon == null && user != null) {
          try {
            final userData = await Supabase.instance.client
                .from('profiles')
                .select('canon_type')
                .eq('id', user.id)
                .maybeSingle();
            remoteCanon = userData?['canon_type'] as String?;
          } catch (_) {
            // Optional profiles table fallback
          }
        }

        final canonToRestore = remoteCanon ?? 'catholic';

        // 1. Save the fetched canon to local Drift DB before routing to the home screen
        await ref.read(localDatabaseProvider).updateLocalCanon(canonToRestore);

        // 2. Save to SharedPreferences and refresh Riverpod settings
        await ref
            .read(currentSettingsProvider.notifier)
            .setCanonType(canonToRestore);
        ref.invalidate(userSettingsProvider);

        // 3. Invalidate user-scoped providers to rebuild with the new account's data
        ref.invalidate(globalProgressProvider);
        ref.invalidate(userStatsProvider);
        ref.invalidate(detailedStatsProvider);
        ref.invalidate(activityLogProvider);
        ref.invalidate(todayChaptersProvider);
        ref.invalidate(continueReadingProvider);
        ref.invalidate(userNameProvider);

        // 4. Trigger cloud sync to pull latest reading progress for this account
        unawaited(ref.read(readingServiceProvider).syncOnResume());

        // 5. Sync session to saved accounts list
        final currentSession = Supabase.instance.client.auth.currentSession;
        if (currentSession != null) {
          await ref
              .read(savedAccountsServiceProvider)
              .syncCurrentSession(currentSession);
          await ref.read(savedAccountsListProvider.notifier).refresh();
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

  Future<void> _quickSignIn(SavedAccount account) async {
    setState(() => _isLoading = true);
    try {
      final switchService = ref.read(accountSwitchServiceProvider);
      final result = await switchService.switchToAccount(account);
      if (!mounted) return;

      switch (result) {
        case SwitchSuccess():
          VersoSnackbar.success(
            context,
            message: 'Signed in as ${account.displayName}',
          );
        case SwitchOffline():
          VersoSnackbar.show(
            context,
            message: 'Connect to the internet to sign in',
          );
        case SwitchSessionExpired():
          VersoSnackbar.show(
            context,
            message:
                'Session expired for ${account.displayName}. Please enter your password.',
          );
          setState(() {
            _emailController.text = account.email;
          });
        case SwitchFlushFailed():
          VersoSnackbar.error(
            context,
            message: 'Could not sync pending changes',
          );
        case SwitchError(:final message):
          VersoSnackbar.error(context, message: 'Could not sign in: $message');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final savedAccountsAsync = ref.watch(savedAccountsListProvider);
    final savedAccounts = savedAccountsAsync.value ?? [];

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

                              // Quick Sign In with saved accounts
                              if (!_isSignUp && savedAccounts.isNotEmpty) ...[
                                Text(
                                  'Saved Accounts',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurfaceVariant,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const Gap(Spacing.xs),
                                ...savedAccounts.map((account) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _QuickAccountTile(
                                      account: account,
                                      isLoading: _isLoading,
                                      onTap: () => _quickSignIn(account),
                                      onRemove: () => ref
                                          .read(
                                            savedAccountsListProvider.notifier,
                                          )
                                          .removeAccount(account.userId),
                                    ),
                                  );
                                }),
                                const Gap(Spacing.xs),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: colorScheme.outline
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        'or sign in with password',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: colorScheme.onSurfaceVariant
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: colorScheme.outline
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(Spacing.md),
                              ],

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
                                // Responsive Wrap holds both "Remember me" and "Forgot password?"
                                Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 8,
                                  runSpacing: 4,
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

class _QuickAccountTile extends StatelessWidget {
  const _QuickAccountTile({
    required this.account,
    required this.isLoading,
    required this.onTap,
    required this.onRemove,
  });

  final SavedAccount account;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initial = account.displayName.isNotEmpty
        ? account.displayName[0].toUpperCase()
        : '?';

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.md),
          onTap: isLoading ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      Text(
                        account.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  tooltip: 'Forget account',
                  visualDensity: VisualDensity.compact,
                  onPressed: onRemove,
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: scheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
