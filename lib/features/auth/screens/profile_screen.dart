import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:verso/core/design/components/verso_card.dart';
import 'package:verso/core/design/components/verso_snackbar.dart';
import 'package:verso/core/design/tokens/colors.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/spacing.dart';
import 'package:verso/core/router.dart';
import 'package:verso/core/utils/app_error_handler.dart';
import 'package:verso/core/widgets/error_state_widget.dart';
import 'package:verso/core/widgets/verso_avatar.dart';
import 'package:verso/features/auth/providers/auth_providers.dart';
import 'package:verso/features/reading/providers/reading_providers.dart';
import 'package:verso/features/stats/providers/stats_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authUserProvider);

    return userAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: ErrorStateWidget(
          error: err,
          onRetry: () => ref.invalidate(authUserProvider),
        ),
      ),
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text('Not Logged In')));
        }

        final name = (user.userMetadata?['full_name'] as String?) ?? 'Reader';
        final email = user.email ?? 'No Email';
        final readingSince = DateFormat('MMM yyyy')
            .format(DateTime.parse(user.createdAt).toLocal());

        final scheme = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Hero Header
              SliverToBoxAdapter(
                child: _ProfileHeroHeader(
                  name: name,
                  email: email,
                  readingSince: readingSince,
                  isDark: isDark,
                  scheme: scheme,
                ),
              ),

              // Stats Strip
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _ProfileStatsStrip(isDark: isDark, scheme: scheme),
                ),
              ),

              const SliverToBoxAdapter(child: Gap(28)),

              // Account Settings Group
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SettingsGroup(
                    label: 'Account',
                    isDark: isDark,
                    scheme: scheme,
                    items: [
                      _SettingsItem(
                        icon: Icons.email_outlined,
                        iconColor: const Color(0xFF3B82F6),
                        label: 'Change Email',
                        onTap: () => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          builder: (_) => const _ChangeEmailSheet(),
                        ),
                      ),
                      _SettingsItem(
                        icon: Icons.lock_outline_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                        label: 'Change Password',
                        onTap: () => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          builder: (_) => const _ChangePasswordSheet(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: Gap(16)),

              // App Settings Group
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SettingsGroup(
                    label: 'App',
                    isDark: isDark,
                    scheme: scheme,
                    items: [
                      _SettingsItem(
                        icon: Icons.settings_outlined,
                        iconColor: const Color(0xFF6B7280),
                        label: 'Settings',
                        onTap: () => GoRouter.of(context).push('/settings'),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: Gap(24)),

              // Sign Out
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SignOutTile(scheme: scheme, isDark: isDark),
                ),
              ),

              const SliverToBoxAdapter(child: Gap(40)),
            ],
          ),
        );
      },
    );
  }
}

// -- Hero Header --

class _ProfileHeroHeader extends StatelessWidget {
  const _ProfileHeroHeader({
    required this.name,
    required this.email,
    required this.readingSince,
    required this.isDark,
    required this.scheme,
  });

  final String name;
  final String email;
  final String readingSince;
  final bool isDark;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  AppColors.primaryContainerDark.withValues(alpha: 0.9),
                  scaffoldBg,
                ]
              : [
                  AppColors.primaryContainerLight,
                  scaffoldBg,
                ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            children: [
              // Avatar with ring
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      if (isDark)
                        AppColors.secondaryDark
                      else
                        AppColors.secondaryLight,
                    ],
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? AppColors.primaryContainerDark
                        : AppColors.primaryContainerLight,
                  ),
                  child: const VersoAvatar(size: 104, borderWidth: 0),
                ),
              ),

              const Gap(20),

              // Name with edit icon
              GestureDetector(
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (_) => _EditNameSheet(currentName: name),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Gap(8),
                    Icon(
                      Icons.edit_rounded,
                      size: 18,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),

              const Gap(4),

              // Email
              Text(
                email,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: scheme.onSurfaceVariant,
                ),
              ),

              const Gap(14),

              // "Reading since" badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withValues(alpha: isDark ? 0.15 : 0.10),
                      (isDark
                              ? AppColors.secondaryDark
                              : AppColors.secondaryLight)
                          .withValues(alpha: isDark ? 0.10 : 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.full),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.18),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 14,
                      color: primaryColor,
                    ),
                    const Gap(6),
                    Text(
                      'Reading since $readingSince',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -- Stats Strip --

class _ProfileStatsStrip extends ConsumerWidget {
  const _ProfileStatsStrip({required this.isDark, required this.scheme});

  final bool isDark;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);

    final chaptersRead = statsAsync.whenOrNull(
          data: (stats) => stats.totalChaptersRead,
        ) ??
        0;

    final booksCompleted = statsAsync.whenOrNull(
          data: (stats) => stats.booksCompleted,
        ) ??
        0;

    final isLoading = statsAsync.isLoading;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.menu_book_rounded,
            iconColor:
                isDark ? AppColors.chaptersDark : AppColors.chaptersLight,
            value: isLoading ? '–' : '$chaptersRead',
            totalScope: isLoading ? null : '/ 1334',
            label: 'Chapters\nRead',
            isDark: isDark,
            scheme: scheme,
          ),
        ),
        const Gap(12),
        Expanded(
          child: _StatCard(
            icon: Icons.library_books_rounded,
            iconColor: isDark ? AppColors.booksDark : AppColors.booksLight,
            value: isLoading ? '–' : '$booksCompleted',
            totalScope: isLoading ? null : '/ 73',
            label: 'Books\nCompleted',
            isDark: isDark,
            scheme: scheme,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.isDark,
    required this.scheme,
    this.totalScope,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String? totalScope;
  final String label;
  final bool isDark;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return VersoCard(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: totalScope != null
                      ? Text.rich(
                          TextSpan(
                            text: value,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                              height: 1,
                            ),
                            children: [
                              TextSpan(
                                text: ' $totalScope',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onSurfaceVariant
                                      .withValues(alpha: 0.8),
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Text(
                          value,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                            height: 1,
                          ),
                        ),
                ),
                const Gap(3),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -- Settings Group --

class _SettingsItem {
  const _SettingsItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({
    required this.label,
    required this.items,
    required this.isDark,
    required this.scheme,
  });

  final String label;
  final List<_SettingsItem> items;
  final bool isDark;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: scheme.onSurfaceVariant,
              letterSpacing: 1.1,
            ),
          ),
        ),
        VersoCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  _SettingsRow(
                    item: items[i],
                    scheme: scheme,
                  ),
                  if (i < items.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 60,
                      color: scheme.outlineVariant
                          .withValues(alpha: isDark ? 0.3 : 0.5),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.item, required this.scheme});

  final _SettingsItem item;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: item.iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(item.icon, size: 18, color: item.iconColor),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -- Sign Out --

class _SignOutTile extends ConsumerWidget {
  const _SignOutTile({
    required this.scheme,
    required this.isDark,
  });

  final ColorScheme scheme;
  final bool isDark;

  @override
  Widget build(BuildContext ctx, WidgetRef widgetRef) {
    final errorColor = isDark ? AppColors.errorDark : AppColors.errorLight;

    return VersoCard(
      padding: EdgeInsets.zero,
      color: errorColor.withValues(alpha: 0.06),
      border: Border.all(color: errorColor.withValues(alpha: 0.2)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          onTap: () => _handleSignOut(ctx, widgetRef),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: errorColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    size: 18,
                    color: errorColor,
                  ),
                ),
                const Gap(14),
                Text(
                  'Sign Out',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: errorColor,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: errorColor.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext ctx, WidgetRef widgetRef) async {
    final cacheService = widgetRef.read(offlineCacheServiceProvider);
    final pendingCount = await cacheService.pendingWriteCount();

    if (!ctx.mounted) return;

    final errorColor = isDark ? AppColors.errorDark : AppColors.errorLight;

    final confirmed = await showDialog<bool>(
      context: ctx,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        final dialogScheme = Theme.of(dialogContext).colorScheme;
        final hasPending = pendingCount > 0;

        return Dialog(
          backgroundColor: dialogScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.borderRadiusXL,
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              Spacing.xl,
              Spacing.lg,
              Spacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: errorColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: errorColor,
                    size: 26,
                  ),
                ),
                const Gap(Spacing.md),
                Text(
                  'Sign out of Verso?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: dialogScheme.onSurface,
                  ),
                ),
                const Gap(Spacing.xs),
                Text(
                  hasPending
                      ? 'Signing out will remove your local data from this device.'
                      : 'Your reading progress is synced. You can sign back in at any time.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: dialogScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                if (hasPending) ...[
                  const Gap(Spacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: errorColor.withValues(alpha: 0.08),
                      borderRadius: AppRadii.borderRadiusMD,
                      border: Border.all(
                        color: errorColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: errorColor,
                        ),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            '$pendingCount unsynced ${pendingCount == 1 ? 'record' : 'records'} will be lost',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: errorColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Gap(Spacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: errorColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.borderRadiusMD,
                      ),
                    ),
                    child: Text(
                      'Sign Out',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const Gap(Spacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    style: TextButton.styleFrom(
                      foregroundColor: dialogScheme.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.borderRadiusMD,
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true) return;

    final router = widgetRef.read(routerProvider);

    await cacheService.clearAll();
    widgetRef.invalidate(globalProgressProvider);
    widgetRef.invalidate(userStatsProvider);
    await widgetRef.read(authRepositoryProvider).signOut();

    Future.delayed(const Duration(milliseconds: 150), () {
      final rootContext = router.routerDelegate.navigatorKey.currentContext;
      if (rootContext != null && rootContext.mounted) {
        VersoSnackbar.success(
          rootContext,
          message: 'Signed out successfully',
        );
      }
    });
  }
}

// --- 1. CHANGE EMAIL SHEET (Bottom Sheet) ---
class _ChangeEmailSheet extends ConsumerStatefulWidget {
  const _ChangeEmailSheet();

  @override
  ConsumerState<_ChangeEmailSheet> createState() => _ChangeEmailSheetState();
}

class _ChangeEmailSheetState extends ConsumerState<_ChangeEmailSheet> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;

  Future<void> _update() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    if (email.isEmpty || !email.contains('@') || pass.isEmpty) {
      VersoSnackbar.error(context, message: 'Invalid input');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      // 1. Verify Identity
      await repo.reauthenticate(pass);
      // 2. Update Email
      await repo.updateEmail(email);

      if (mounted) {
        Navigator.pop(context);
        VersoSnackbar.success(
          context,
          message: 'Check your email (both old and new) to confirm.',
        );
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
    // This padding handles the keyboard automatically
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(24),

            Text(
              'Change Email',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Gap(24),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'New Email Address',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const Gap(16),
            TextField(
              controller: _passwordController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                labelText: 'Current Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _isObscure = !_isObscure),
                ),
              ),
            ),
            const Gap(32),
            FilledButton(
              onPressed: _isLoading ? null : _update,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Update Email'),
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }
}

// --- 2. CHANGE PASSWORD SHEET (Bottom Sheet) ---
class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();

  @override
  ConsumerState<_ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _isLoading = false;
  bool _obsOld = true;
  bool _obsNew = true;
  bool _obsConfirm = true;

  Future<void> _update() async {
    final oldPass = _oldPassController.text.trim();
    final newPass = _newPassController.text.trim();
    final confirmPass = _confirmPassController.text.trim();

    if (newPass.length < 6) {
      VersoSnackbar.error(context, message: 'New password is too short');
      return;
    }
    if (newPass != confirmPass) {
      VersoSnackbar.error(context, message: 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      // 1. Verify Old Password
      await repo.reauthenticate(oldPass);
      // 2. Update to New Password
      await repo.updatePassword(newPass);

      if (mounted) {
        Navigator.pop(context);
        VersoSnackbar.success(
          context,
          message: 'Password updated successfully!',
        );
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
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(24),

            Text(
              'Change Password',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Gap(24),

            TextField(
              controller: _oldPassController,
              obscureText: _obsOld,
              decoration: InputDecoration(
                labelText: 'Current Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obsOld ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obsOld = !_obsOld),
                ),
              ),
            ),

            // --- NEW: FORGOT PASSWORD BUTTON ---
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Close the bottom sheet first
                  Navigator.pop(context);
                  // Navigate to the Forgot Password screen
                  GoRouter.of(context).push('/forgot-password');
                },
                child: const Text('Forgot Password?'),
              ),
            ),

            TextField(
              controller: _newPassController,
              obscureText: _obsNew,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: const Icon(Icons.key),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obsNew ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obsNew = !_obsNew),
                ),
              ),
            ),
            const Gap(16),
            TextField(
              controller: _confirmPassController,
              obscureText: _obsConfirm,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: const Icon(Icons.check_circle_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obsConfirm ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _obsConfirm = !_obsConfirm),
                ),
              ),
            ),
            const Gap(32),
            FilledButton(
              onPressed: _isLoading ? null : _update,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Update Password'),
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }
}

// --- 3. EDIT NAME SHEET (Bottom Sheet) ---
class _EditNameSheet extends ConsumerStatefulWidget {
  const _EditNameSheet({required this.currentName});

  final String currentName;

  @override
  ConsumerState<_EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends ConsumerState<_EditNameSheet> {
  late final TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.currentName == 'Reader' ? '' : widget.currentName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      VersoSnackbar.error(context, message: 'Name cannot be empty');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.updateUserMetadata({'full_name': name});

      if (mounted) {
        Navigator.pop(context);
        VersoSnackbar.success(
          context,
          message: 'Name updated successfully!',
        );
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
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(24),

            Text(
              'Edit Name',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Gap(24),

            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const Gap(32),
            FilledButton(
              onPressed: _isLoading ? null : _update,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Update Name'),
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }
}
