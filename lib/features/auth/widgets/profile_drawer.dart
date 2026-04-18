import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/package_info_provider.dart';
import '../../../core/design/tokens/colors.dart';
import '../../../core/design/tokens/radii.dart';
import '../../../core/design/tokens/spacing.dart';
import '../providers/auth_providers.dart';
import '../../reading/providers/reading_providers.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Get the current user
    final userAsync = ref.watch(authUserProvider);
    final user = userAsync.value;

    // 2. Get user metadata (like the name we saved during sign up)
    final name = (user?.userMetadata?['full_name'] as String?) ?? 'Reader';
    final email = user?.email ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'V';

    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final topPadding = MediaQuery.of(context).padding.top;

    return Drawer(
      backgroundColor:
          isLight ? AppColors.backgroundLight : AppColors.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.horizontal(right: Radius.circular(AppRadii.xl)),
      ),
      child: Column(
        children: [
          // Header
          _DrawerHeader(
            name: name,
            email: email,
            initial: initial,
            topPadding: topPadding,
            scheme: scheme,
            isLight: isLight,
          ),

          const Gap(Spacing.sm),

          // Menu Items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _DrawerMenuItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Profile',
                    subtitle: 'Account & preferences',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                      GoRouter.of(context).push('/profile');
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    subtitle: 'App configuration',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                      GoRouter.of(context).push('/settings');
                    },
                  ),

                  const Spacer(),

                  // App branding
                  Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.sm),
                    child: Text(
                      'Verso v${ref.watch(packageInfoProvider).version}',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                    ),
                  ),

                  // Logout
                  Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.md),
                    child: _LogoutButton(
                      isLight: isLight,
                      onTap: () async {
                        HapticFeedback.mediumImpact();

                        // Check if there are pending (unsynced) offline writes
                        final cacheService =
                            ref.read(offlineCacheServiceProvider);
                        final pendingCount =
                            await cacheService.pendingWriteCount();

                        // Build a context-aware confirmation dialog
                        if (!context.mounted) return;

                        final confirmed = await showDialog<bool>(
                          context: context,
                          barrierColor: Colors.black54,
                          builder: (dialogContext) {
                            final dialogScheme =
                                Theme.of(dialogContext).colorScheme;
                            final dialogIsLight =
                                Theme.of(dialogContext).brightness ==
                                    Brightness.light;
                            final errorColor = dialogIsLight
                                ? AppColors.errorLight
                                : AppColors.errorDark;
                            final hasPending = pendingCount > 0;

                            return Dialog(
                              backgroundColor: dialogScheme.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadii.borderRadiusXL,
                              ),
                              insetPadding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
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
                                    // Icon circle
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color:
                                            errorColor.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.logout_rounded,
                                        color: errorColor,
                                        size: 26,
                                      ),
                                    ),

                                    const Gap(Spacing.md),

                                    // Title
                                    Text(
                                      'Sign out of Verso?',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w700,
                                        color: dialogScheme.onSurface,
                                      ),
                                    ),

                                    const Gap(Spacing.xs),

                                    // Description
                                    Text(
                                      hasPending
                                          ? 'Signing out will remove your '
                                              'local data from this device.'
                                          : 'Your reading progress is synced. '
                                              'You can sign back in at any time.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: dialogScheme.onSurfaceVariant,
                                        height: 1.5,
                                      ),
                                    ),

                                    // Warning chip for unsynced data
                                    if (hasPending) ...[
                                      const Gap(Spacing.md),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: errorColor.withValues(
                                              alpha: 0.08),
                                          borderRadius: AppRadii.borderRadiusMD,
                                          border: Border.all(
                                            color: errorColor.withValues(
                                              alpha: 0.2,
                                            ),
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
                                                '$pendingCount unsynced '
                                                '${pendingCount == 1 ? 'record' : 'records'}'
                                                ' will be lost',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
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

                                    // Sign Out button (destructive, full-width)
                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton(
                                        onPressed: () => Navigator.pop(
                                          dialogContext,
                                          true,
                                        ),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: errorColor,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                AppRadii.borderRadiusMD,
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

                                    // Cancel button (ghost, full-width)
                                    SizedBox(
                                      width: double.infinity,
                                      child: TextButton(
                                        onPressed: () => Navigator.pop(
                                          dialogContext,
                                          false,
                                        ),
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              dialogScheme.onSurfaceVariant,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                AppRadii.borderRadiusMD,
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

                        // Only proceed if user explicitly confirmed
                        if (confirmed != true) return;

                        // Close the drawer, then sign out
                        if (context.mounted) Navigator.pop(context);
                        await cacheService.clearAll();
                        await ref.read(authRepositoryProvider).signOut();
                      },
                    ),
                  ),

                  Gap(MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Header

class _DrawerHeader extends StatelessWidget {
  final String name;
  final String email;
  final String initial;
  final double topPadding;
  final ColorScheme scheme;
  final bool isLight;

  const _DrawerHeader({
    required this.name,
    required this.email,
    required this.initial,
    required this.topPadding,
    required this.scheme,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          Spacing.lg, topPadding + Spacing.lg, Spacing.lg, Spacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? [
                  AppColors.primaryLight,
                  AppColors.primaryLight.withValues(alpha: 0.85),
                ]
              : [
                  AppColors.primaryLight,
                  AppColors.primaryContainerDark,
                ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isLight
                  ? Colors.white.withValues(alpha: 0.2)
                  : AppColors.primaryDark.withValues(alpha: 0.2),
              borderRadius: AppRadii.borderRadiusLG,
              border: Border.all(
                color: isLight
                    ? Colors.white.withValues(alpha: 0.3)
                    : AppColors.primaryDark.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                initial,
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 24,
                  color: isLight ? Colors.white : AppColors.primaryDark,
                ),
              ),
            ),
          ),

          const Gap(Spacing.md),

          // Name
          Text(
            name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isLight ? Colors.white : AppColors.onPrimaryContainerDark,
            ),
          ),

          const Gap(2),

          // Email
          Text(
            email,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: isLight
                  ? Colors.white.withValues(alpha: 0.7)
                  : AppColors.onPrimaryContainerDark.withValues(alpha: 0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Menu Item

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadii.borderRadiusMD,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.borderRadiusMD,
          splashColor: scheme.primary.withValues(alpha: 0.08),
          highlightColor: scheme.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        scheme.primary.withValues(alpha: isLight ? 0.08 : 0.12),
                    borderRadius: AppRadii.borderRadiusSM,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: scheme.primary,
                  ),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: scheme.onSurfaceVariant,
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
      ),
    );
  }
}

// Logout Button

class _LogoutButton extends StatelessWidget {
  final bool isLight;
  final VoidCallback onTap;

  const _LogoutButton({
    required this.isLight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final errorColor = isLight ? AppColors.errorLight : AppColors.errorDark;

    return Material(
      color: errorColor.withValues(alpha: isLight ? 0.06 : 0.1),
      borderRadius: AppRadii.borderRadiusMD,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.borderRadiusMD,
        splashColor: errorColor.withValues(alpha: 0.12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, size: 18, color: errorColor),
              const Gap(8),
              Text(
                'Sign Out',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: errorColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
