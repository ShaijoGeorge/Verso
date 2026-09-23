import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso/core/providers/connectivity_provider.dart';
import 'package:verso/core/services/offline_cache_service.dart';
import 'package:verso/features/auth/models/saved_account.dart';
import 'package:verso/features/auth/providers/auth_providers.dart';
import 'package:verso/features/auth/services/saved_accounts_service.dart';
import 'package:verso/features/home/providers/home_providers.dart';
import 'package:verso/features/reading/providers/reading_providers.dart';
import 'package:verso/features/reading/services/reading_service.dart';
import 'package:verso/features/settings/providers/settings_providers.dart';
import 'package:verso/features/stats/providers/activity_providers.dart';
import 'package:verso/features/stats/providers/stats_providers.dart';

part 'account_switch_service.g.dart';

/// Result of an account-switch attempt.
sealed class SwitchResult {}

class SwitchSuccess extends SwitchResult {
  SwitchSuccess([this.targetAccount]);
  final SavedAccount? targetAccount;
}

class SwitchOffline extends SwitchResult {}

class SwitchFlushFailed extends SwitchResult {
  SwitchFlushFailed(this.pendingCount);
  final int pendingCount;
}

class SwitchSessionExpired extends SwitchResult {
  SwitchSessionExpired(this.account);
  final SavedAccount account;
}

class SwitchError extends SwitchResult {
  SwitchError(this.message);
  final String message;
}

/// Orchestrates multi-account operations:
/// - 1-tap switching between saved accounts without returning to the login screen
/// - Safely flushing current user writes before swapping sessions
/// - Adding new accounts while preserving the current account on the device
class AccountSwitchService {
  AccountSwitchService(this._ref, this._cache);
  final Ref _ref;
  final OfflineCacheService _cache;

  /// Switches directly to a [targetAccount] in 1 tap:
  /// 1. Verifies device is online
  /// 2. Flushes User A's pending writes to Supabase
  /// 3. Backs up User A's session in SavedAccounts
  /// 4. Restores User B's session via Supabase `setSession`
  /// 5. Invalidates user-scoped Riverpod providers
  Future<SwitchResult> switchToAccount(
    SavedAccount targetAccount, {
    bool force = false,
  }) async {
    final isOnline = _ref.read(connectivityProvider);
    if (!isOnline) return SwitchOffline();

    try {
      // 1. If someone is currently logged in, flush their pending writes and preserve session
      final currentSession = Supabase.instance.client.auth.currentSession;
      if (currentSession != null) {
        final readingService = _ref.read(readingServiceProvider);
        await readingService.flushWriteQueue();

        final remaining = await _cache.pendingWriteCount();
        if (!force && remaining > 0) {
          return SwitchFlushFailed(remaining);
        }

        await _ref
            .read(savedAccountsServiceProvider)
            .syncCurrentSession(currentSession);
      }

      // 4. Restore target user session
      try {
        final response = await Supabase.instance.client.auth.setSession(
          targetAccount.refreshToken,
        );
        final newSession = response.session;
        if (newSession == null) {
          return SwitchSessionExpired(targetAccount);
        }
        await _ref
            .read(savedAccountsServiceProvider)
            .syncCurrentSession(newSession);
      } on AuthException {
        return SwitchSessionExpired(targetAccount);
      }

      // 5. Restore target user canon and local DB settings
      final user = Supabase.instance.client.auth.currentUser;
      var remoteCanon = user?.userMetadata?['canon_type'] as String?;

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

      // 1. Save fetched canon to local Drift DB
      await _ref.read(localDatabaseProvider).updateLocalCanon(canonToRestore);

      // 2. Save to SharedPreferences and refresh Riverpod settings
      await _ref
          .read(currentSettingsProvider.notifier)
          .setCanonType(canonToRestore);

      // 6. Invalidate all user-scoped providers to re-render for new user
      _invalidateUserProviders();

      // 7. Refresh the saved accounts list state
      await _ref.read(savedAccountsListProvider.notifier).refresh();

      // 8. Trigger cloud sync to pull latest reading progress for this account
      unawaited(_ref.read(readingServiceProvider).syncOnResume(force: true));

      return SwitchSuccess(targetAccount);
    } catch (e) {
      return SwitchError(e.toString());
    }
  }

  /// Prepares the app to add another account by syncing the current user,
  /// preserving their saved account, and navigating to the Login screen.
  Future<SwitchResult> prepareForAddAccount({bool force = false}) async {
    final isOnline = _ref.read(connectivityProvider);
    if (!isOnline) return SwitchOffline();

    try {
      // 1. Flush pending writes
      final readingService = _ref.read(readingServiceProvider);
      await readingService.flushWriteQueue();

      final remaining = await _cache.pendingWriteCount();
      if (!force && remaining > 0) {
        return SwitchFlushFailed(remaining);
      }

      // 2. Preserve current user in saved accounts
      final currentSession = Supabase.instance.client.auth.currentSession;
      if (currentSession != null) {
        await _ref
            .read(savedAccountsServiceProvider)
            .syncCurrentSession(currentSession);
      }

      // 3. Sign out locally to navigate to login screen without revoking tokens on the server
      await _ref
          .read(authRepositoryProvider)
          .signOut(scope: SignOutScope.local);

      // 4. Invalidate providers
      _invalidateUserProviders();

      // 5. Refresh the saved accounts list state
      await _ref.read(savedAccountsListProvider.notifier).refresh();

      return SwitchSuccess();
    } catch (e) {
      return SwitchError(e.toString());
    }
  }

  /// Legacy switch account method (signs out to login screen).
  Future<SwitchResult> switchAccount() => prepareForAddAccount();

  void _invalidateUserProviders() {
    _ref.invalidate(globalProgressProvider);
    _ref.invalidate(userStatsProvider);
    _ref.invalidate(detailedStatsProvider);
    _ref.invalidate(currentSettingsProvider);
    _ref.invalidate(userSettingsProvider);
    _ref.invalidate(activityLogProvider);
    _ref.invalidate(todayChaptersProvider);
    _ref.invalidate(continueReadingProvider);
    _ref.invalidate(userNameProvider);
  }
}

@Riverpod(keepAlive: true)
AccountSwitchService accountSwitchService(Ref ref) {
  final cache = ref.watch(offlineCacheServiceProvider);
  return AccountSwitchService(ref, cache);
}
