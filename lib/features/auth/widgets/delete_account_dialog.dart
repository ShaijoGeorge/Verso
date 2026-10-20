import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso/core/design/components/verso_text_field.dart';
import 'package:verso/core/design/design.dart';
import 'package:verso/core/router.dart';
import 'package:verso/core/utils/app_error_handler.dart';
import 'package:verso/features/auth/providers/auth_providers.dart';
import 'package:verso/features/auth/services/saved_accounts_service.dart';
import 'package:verso/features/home/providers/home_providers.dart';
import 'package:verso/features/reading/providers/reading_providers.dart';
import 'package:verso/features/settings/providers/settings_providers.dart';
import 'package:verso/features/settings/services/notification_service.dart';
import 'package:verso/features/stats/providers/activity_providers.dart';
import 'package:verso/features/stats/providers/stats_providers.dart';

class DeleteAccountDialog extends ConsumerStatefulWidget {
  const DeleteAccountDialog({super.key});

  /// Static helper to display the Delete Account security verification dialog
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: false,
      builder: (_) => const DeleteAccountDialog(),
    );
  }

  @override
  ConsumerState<DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  var _isLoading = false;
  var _isObscure = true;
  String? _errorMessage;
  int _pendingWrites = 0;

  @override
  void initState() {
    super.initState();
    _checkPendingWrites();
    _passwordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkPendingWrites() async {
    try {
      final cacheService = ref.read(offlineCacheServiceProvider);
      final count = await cacheService.pendingWriteCount();
      if (mounted) {
        setState(() {
          _pendingWrites = count;
        });
      }
    } catch (_) {}
  }

  Future<void> _handleDelete() async {
    if (!_formKey.currentState!.validate()) return;

    final password = _passwordController.text.trim();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final cacheService = ref.read(offlineCacheServiceProvider);
    final router = ref.read(routerProvider);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    try {
      // 1. Security Check: Re-authenticate with current password before allowing deletion
      // This strictly prevents third parties holding an unlocked device from deleting the account
      await ref.read(authRepositoryProvider).reauthenticate(password);

      // 2. Invoke the database RPC to permanently remove user and cascade all remote data
      await NotificationService().cancelStreakEscalationAlerts();
      await ref.read(authRepositoryProvider).deleteAccount();

      // 3. Clean up local device storage and saved account entries
      if (currentUserId != null && currentUserId.isNotEmpty) {
        await ref
            .read(savedAccountsServiceProvider)
            .removeAccount(currentUserId);
        await cacheService.clearUserCache(currentUserId);
      }
      await cacheService.clearWriteQueue();

      // 4. Invalidate all active UI and stats providers
      ref.invalidate(globalProgressProvider);
      ref.invalidate(userStatsProvider);
      ref.invalidate(detailedStatsProvider);
      ref.invalidate(currentSettingsProvider);
      ref.invalidate(userSettingsProvider);
      ref.invalidate(activityLogProvider);
      ref.invalidate(todayChaptersProvider);
      ref.invalidate(continueReadingProvider);
      ref.invalidate(userNameProvider);

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Explicitly redirect to login screen
      router.go('/login');

      // 5. Provide friendly feedback on root context
      Future.delayed(const Duration(milliseconds: 150), () {
        final rootContext = router.routerDelegate.navigatorKey.currentContext;
        if (rootContext != null && rootContext.mounted) {
          VersoSnackbar.success(
            rootContext,
            message: 'Your account and data have been permanently deleted.',
          );
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = AppErrorHandler.getMessage(e);
        });
        FocusScope.of(context).unfocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dialogScheme = Theme.of(context).colorScheme;
    final dangerColor = context.palette.danger;

    return PopScope(
      canPop: !_isLoading,
      child: Dialog(
        backgroundColor: dialogScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.borderRadiusXL,
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.xl,
            Spacing.lg,
            Spacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Danger Icon Badge
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: dangerColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_forever_rounded,
                  color: dangerColor,
                  size: 28,
                ),
              ),
              const Gap(Spacing.md),

              // Title
              Text(
                'Delete Account?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: dialogScheme.onSurface,
                ),
              ),
              const Gap(Spacing.sm),

              // Description
              Text(
                'This action is permanent and irreversible. All your reading history, daily streaks, bookmarks, and account credentials will be permanently erased.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.45,
                  color: dialogScheme.onSurfaceVariant,
                ),
              ),

              // Warning for pending offline writes if any
              if (_pendingWrites > 0) ...[
                const Gap(Spacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: dangerColor.withValues(alpha: 0.08),
                    borderRadius: AppRadii.borderRadiusMD,
                    border: Border.all(
                      color: dangerColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: dangerColor,
                      ),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          '$_pendingWrites unsynced record${_pendingWrites == 1 ? '' : 's'} will be discarded',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: dangerColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Gap(Spacing.lg),

              // Security Verification: Password Input
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 6),
                      child: Text(
                        'Confirm with your password',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: dialogScheme.onSurface,
                        ),
                      ),
                    ),
                    VersoTextField(
                      controller: _passwordController,
                      label: 'Account Password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _isObscure,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscure ? Icons.visibility : Icons.visibility_off,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _isObscure = !_isObscure),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your password to proceed';
                        }
                        return null;
                      },
                    ),
                    if (_errorMessage != null) ...[
                      const Gap(10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: dangerColor.withValues(alpha: 0.1),
                          borderRadius: AppRadii.borderRadiusMD,
                          border: Border.all(
                            color: dangerColor.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 18,
                              color: dangerColor,
                            ),
                            const Gap(8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: dangerColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const Gap(Spacing.xl),

              // Delete Button (Danger)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _handleDelete,
                  style: FilledButton.styleFrom(
                    backgroundColor: dangerColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: dangerColor.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.borderRadiusMD,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Permanently Delete Account',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const Gap(Spacing.xs),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context, rootNavigator: true).pop(),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: dialogScheme.onSurfaceVariant,
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
