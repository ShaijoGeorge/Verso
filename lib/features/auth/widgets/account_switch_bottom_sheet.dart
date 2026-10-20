import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso/core/design/components/verso_bottom_sheet.dart';
import 'package:verso/core/design/components/verso_snackbar.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/spacing.dart';
import 'package:verso/core/router.dart';
import 'package:verso/features/auth/models/saved_account.dart';
import 'package:verso/features/auth/services/account_switch_service.dart';
import 'package:verso/features/auth/services/saved_accounts_service.dart';
import 'package:verso/features/auth/widgets/saved_account_tile.dart';

class AccountSwitchBottomSheet extends ConsumerStatefulWidget {
  const AccountSwitchBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return VersoBottomSheet.show<void>(
      context: context,
      contentPadding: EdgeInsets.zero,
      child: const AccountSwitchBottomSheet(),
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

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                var displayAccounts = accounts;
                final session = Supabase.instance.client.auth.currentSession;

                if (session != null) {
                  final hasCurrent =
                      displayAccounts.any((a) => a.userId == session.user.id);
                  if (!hasCurrent) {
                    final user = session.user;
                    final fullName =
                        (user.userMetadata?['full_name'] as String?)?.trim();
                    final displayName =
                        (fullName != null && fullName.isNotEmpty)
                            ? fullName
                            : (user.email?.split('@').first ?? 'User');

                    final synthesizedAccount = SavedAccount(
                      userId: user.id,
                      email: user.email ?? '',
                      displayName: displayName,
                      avatarUrl: user.userMetadata?['avatar_url'] as String?,
                      refreshToken: session.refreshToken ?? '',
                      lastActive: DateTime.now(),
                    );

                    displayAccounts = [
                      synthesizedAccount,
                      ...displayAccounts,
                    ];
                  }
                }

                if (displayAccounts.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.xl,
                      vertical: Spacing.xl,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(Spacing.lg),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.group_off_rounded,
                            size: 32,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const Gap(Spacing.md),
                        Text(
                          'No saved accounts',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        const Gap(Spacing.xs),
                        Text(
                          'Accounts you sign into will appear here for quick switching.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.lg,
                    vertical: Spacing.md,
                  ),
                  itemCount: displayAccounts.length,
                  separatorBuilder: (_, __) => const Gap(Spacing.sm),
                  itemBuilder: (context, index) {
                    final account = displayAccounts[index];
                    final isCurrent = account.userId == currentUserId;
                    final isSwitching = _switchingUserId == account.userId;
                    final isBusy = _switchingUserId != null || _isAddingAccount;

                    return SavedAccountTile(
                      account: account,
                      isCurrent: isCurrent,
                      isLoading: isSwitching,
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
    );
  }

  Future<void> _handleSwitchTo(
    SavedAccount account, {
    bool force = false,
  }) async {
    if (_switchingUserId != null || _isAddingAccount) return;
    HapticFeedback.lightImpact();
    setState(() => _switchingUserId = account.userId);

    final switchService = ref.read(accountSwitchServiceProvider);
    final result = await switchService.switchToAccount(account, force: force);

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
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              'Sync in progress',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
            content: Text(
              'Could not sync $pendingCount offline records. Switch anyway and sync them later, or Cancel?',
              style: GoogleFonts.plusJakartaSans(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Switch anyway'),
              ),
            ],
          ),
        );
        if ((confirmed ?? false) && mounted) {
          await _handleSwitchTo(account, force: true);
        }

      case SwitchSessionExpired():
        // Keep the current user signed in while opening the special add-account
        // login route. Signing out would revoke their refresh token.
        var prepResult = await switchService.prepareForAddAccount();
        if (!mounted) return;
        if (prepResult case SwitchFlushFailed(:final pendingCount)) {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(
                'Sync in progress',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
              content: Text(
                'Could not sync $pendingCount offline records. Continue anyway and sync them later, or Cancel?',
                style: GoogleFonts.plusJakartaSans(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Continue anyway'),
                ),
              ],
            ),
          );
          if (!(confirmed ?? false) || !mounted) return;
          prepResult = await switchService.prepareForAddAccount(force: true);
          if (!mounted) return;
        }

        Navigator.of(context).pop();
        ref
            .read(routerProvider)
            .go('/login?addAccount=true', extra: account.email);
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

      if (mounted) {
        final container = ProviderScope.containerOf(context);
        Navigator.of(context).pop();

        VersoSnackbar.show(
          context,
          message: 'Removed ${account.displayName} from this device',
          actionLabel: 'Undo',
          onAction: () async {
            await container
                .read(savedAccountsServiceProvider)
                .saveOrUpdateAccount(account);
            await container.read(savedAccountsListProvider.notifier).refresh();
          },
        );
      }
    }
  }

  Future<void> _handleAddAccount({bool force = false}) async {
    if (_isAddingAccount || _switchingUserId != null) return;
    HapticFeedback.lightImpact();
    setState(() => _isAddingAccount = true);

    final switchService = ref.read(accountSwitchServiceProvider);
    final result = await switchService.prepareForAddAccount(force: force);

    if (!mounted) return;
    setState(() => _isAddingAccount = false);

    switch (result) {
      case SwitchSuccess():
        Navigator.of(context).pop();
        ref.read(routerProvider).go('/login?addAccount=true');
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
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              'Sync in progress',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
            content: Text(
              'Could not sync $pendingCount offline records. Continue anyway and sync them later, or Cancel?',
              style: GoogleFonts.plusJakartaSans(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Continue anyway'),
              ),
            ],
          ),
        );
        if ((confirmed ?? false) && mounted) {
          await _handleAddAccount(force: true);
        }

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
