import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso/core/design/components/verso_card.dart';
import 'package:verso/core/design/components/verso_snackbar.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/spacing.dart';
import 'package:verso/core/router.dart';
import 'package:verso/features/auth/models/saved_account.dart';
import 'package:verso/features/auth/services/account_switch_service.dart';
import 'package:verso/features/auth/services/saved_accounts_service.dart';

class AccountSwitchBottomSheet extends ConsumerStatefulWidget {
  const AccountSwitchBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AccountSwitchBottomSheet(),
    );
  }

  @override
  ConsumerState<AccountSwitchBottomSheet> createState() =>
      _AccountSwitchBottomSheetState();
}

class _AccountSwitchBottomSheetState
    extends ConsumerState<AccountSwitchBottomSheet> {
  String? _switchingUserId;
  bool _isAddingAccount = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final accountsAsync = ref.watch(savedAccountsListProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadii.xl),
          topRight: Radius.circular(AppRadii.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Gap(Spacing.sm),
              // Drag handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: AppRadii.borderRadiusFull,
                ),
              ),
              const Gap(Spacing.md),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      child: const Icon(
                        Icons.swap_horiz_rounded,
                        color: Color(0xFF3B82F6),
                        size: 22,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Switch Account',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                          Text(
                            'Accounts saved on this device',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: scheme.onSurfaceVariant,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Gap(Spacing.md),
              const Divider(height: 1, thickness: 1),

              // Account list
              Flexible(
                child: accountsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: Spacing.xl),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Padding(
                    padding: const EdgeInsets.all(Spacing.lg),
                    child: Center(
                      child: Text(
                        'Could not load accounts',
                        style: GoogleFonts.plusJakartaSans(
                          color: scheme.error,
                        ),
                      ),
                    ),
                  ),
                  data: (accounts) {
                    if (accounts.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.xl,
                          vertical: Spacing.lg,
                        ),
                        child: Text(
                          'No saved accounts found.',
                          style: GoogleFonts.plusJakartaSans(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.lg,
                        vertical: Spacing.md,
                      ),
                      itemCount: accounts.length,
                      separatorBuilder: (_, __) => const Gap(Spacing.sm),
                      itemBuilder: (context, index) {
                        final account = accounts[index];
                        final isCurrent = account.userId == currentUserId;
                        final isSwitching = _switchingUserId == account.userId;
                        final isBusy =
                            _switchingUserId != null || _isAddingAccount;

                        return _AccountCard(
                          account: account,
                          isCurrent: isCurrent,
                          isSwitching: isSwitching,
                          onTap: isBusy || isCurrent
                              ? null
                              : () => _handleSwitchTo(account),
                          onRemove: isBusy || isCurrent
                              ? null
                              : () => _handleRemoveAccount(account),
                        );
                      },
                    );
                  },
                ),
              ),

              const Divider(height: 1, thickness: 1),
              const Gap(Spacing.md),

              // Add Account Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isAddingAccount || _switchingUserId != null
                        ? null
                        : _handleAddAccount,
                    icon: _isAddingAccount
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.person_add_outlined, size: 20),
                    label: Text(
                      'Add another account',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: scheme.outline.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.borderRadiusMD,
                      ),
                    ),
                  ),
                ),
              ),

              const Gap(Spacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSwitchTo(SavedAccount account) async {
    if (_switchingUserId != null || _isAddingAccount) return;
    HapticFeedback.lightImpact();
    setState(() => _switchingUserId = account.userId);

    final switchService = ref.read(accountSwitchServiceProvider);
    final result = await switchService.switchToAccount(account);

    if (!mounted) return;
    setState(() => _switchingUserId = null);

    switch (result) {
      case SwitchSuccess():
        Navigator.of(context).pop();
        VersoSnackbar.success(
          context,
          message: 'Switched to ${account.displayName}',
        );

      case SwitchOffline():
        VersoSnackbar.show(
          context,
          message: 'Connect to the internet to switch accounts',
        );

      case SwitchFlushFailed(:final pendingCount):
        VersoSnackbar.show(
          context,
          message: '$pendingCount records could not sync. Try again later.',
        );

      case SwitchSessionExpired():
        // Sign out current user locally so GoRouter allows navigating to /login
        // without bouncing back to /home, while preserving their session in SavedAccounts.
        final prepResult = await switchService.prepareForAddAccount();
        if (!mounted) return;
        if (prepResult is SwitchFlushFailed) {
          VersoSnackbar.show(
            context,
            message:
                '${prepResult.pendingCount} records could not sync. Try again later.',
          );
          return;
        }

        Navigator.of(context).pop();
        ref.read(routerProvider).go('/login', extra: account.email);
        Future.delayed(const Duration(milliseconds: 150), () {
          final rootContext = ref
              .read(routerProvider)
              .routerDelegate
              .navigatorKey
              .currentContext;
          if (rootContext != null && rootContext.mounted) {
            VersoSnackbar.show(
              rootContext,
              message:
                  'Session expired for ${account.displayName}. Please sign in again.',
            );
          }
        });

      case SwitchError(:final message):
        VersoSnackbar.error(
          context,
          message: 'Switch failed: $message',
        );
    }
  }

  Future<void> _handleRemoveAccount(SavedAccount account) async {
    if (_switchingUserId != null || _isAddingAccount) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Remove account?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Remove "${account.displayName}" (${account.email}) from this device?',
          style: GoogleFonts.plusJakartaSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await ref
          .read(savedAccountsListProvider.notifier)
          .removeAccount(account.userId);
    }
  }

  Future<void> _handleAddAccount() async {
    if (_isAddingAccount || _switchingUserId != null) return;
    HapticFeedback.lightImpact();
    setState(() => _isAddingAccount = true);

    final switchService = ref.read(accountSwitchServiceProvider);
    final result = await switchService.prepareForAddAccount();

    if (!mounted) return;
    setState(() => _isAddingAccount = false);

    switch (result) {
      case SwitchSuccess():
        Navigator.of(context).pop();
        ref.read(routerProvider).go('/login');
        Future.delayed(const Duration(milliseconds: 150), () {
          final rootContext = ref
              .read(routerProvider)
              .routerDelegate
              .navigatorKey
              .currentContext;
          if (rootContext != null && rootContext.mounted) {
            VersoSnackbar.show(
              rootContext,
              message: 'Sign in to add an account to this device',
            );
          }
        });

      case SwitchOffline():
        VersoSnackbar.show(
          context,
          message: 'Connect to the internet to add another account',
        );

      case SwitchFlushFailed(:final pendingCount):
        VersoSnackbar.show(
          context,
          message: '$pendingCount records could not sync. Try again later.',
        );

      case SwitchSessionExpired():
        VersoSnackbar.error(
          context,
          message: 'Could not prepare account switch: session expired',
        );

      case SwitchError(:final message):
        VersoSnackbar.error(
          context,
          message: 'Could not prepare account switch: $message',
        );
    }
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
    required this.isCurrent,
    required this.isSwitching,
    this.onTap,
    this.onRemove,
  });

  final SavedAccount account;
  final bool isCurrent;
  final bool isSwitching;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initial = account.displayName.isNotEmpty
        ? account.displayName[0].toUpperCase()
        : '?';

    final activeColor = scheme.primary;

    return VersoCard(
      padding: EdgeInsets.zero,
      color: isCurrent
          ? activeColor.withValues(alpha: 0.08)
          : scheme.surfaceContainerHighest.withValues(alpha: 0.4),
      border: Border.all(
        color: isCurrent
            ? activeColor.withValues(alpha: 0.4)
            : scheme.outlineVariant.withValues(alpha: 0.2),
        width: isCurrent ? 1.5 : 1,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar circle
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isCurrent
                        ? [activeColor, activeColor.withValues(alpha: 0.7)]
                        : [
                            scheme.onSurfaceVariant.withValues(alpha: 0.2),
                            scheme.onSurfaceVariant.withValues(alpha: 0.35),
                          ],
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isCurrent ? Colors.white : scheme.onSurface,
                  ),
                ),
              ),

              const Gap(14),

              // Name & Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            account.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        if (isCurrent) ...[
                          const Gap(8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: activeColor.withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(AppRadii.full),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 12,
                                  color: activeColor,
                                ),
                                const Gap(4),
                                Text(
                                  'Active',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: activeColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Gap(2),
                    Text(
                      account.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Trailing action
              if (isSwitching)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (!isCurrent) ...[
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  tooltip: 'Remove from device',
                  onPressed: onRemove,
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
