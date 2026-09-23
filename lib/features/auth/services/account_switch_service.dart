import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verso/core/providers/connectivity_provider.dart';
import 'package:verso/core/services/offline_cache_service.dart';
import 'package:verso/features/auth/providers/auth_providers.dart';
import 'package:verso/features/home/providers/home_providers.dart';
import 'package:verso/features/reading/providers/reading_providers.dart';
import 'package:verso/features/reading/services/reading_service.dart';
import 'package:verso/features/settings/providers/settings_providers.dart';
import 'package:verso/features/stats/providers/activity_providers.dart';
import 'package:verso/features/stats/providers/stats_providers.dart';

part 'account_switch_service.g.dart';

/// Result of an account-switch attempt.
///
/// Using a sealed type instead of throwing gives the UI full control
/// over how each case is presented (dialog, snackbar, inline error).
sealed class SwitchResult {}

class SwitchSuccess extends SwitchResult {}

class SwitchOffline extends SwitchResult {}

class SwitchFlushFailed extends SwitchResult {
  SwitchFlushFailed(this.pendingCount);
  final int pendingCount;
}

class SwitchError extends SwitchResult {
  SwitchError(this.message);
  final String message;
}

/// Orchestrates the "Switch Account" flow:
///
/// 1. Guard: must be online
/// 2. Flush any pending offline writes to Supabase
/// 3. Clear the write queue
/// 4. Sign out via Supabase
/// 5. Invalidate all user-scoped providers so the next login starts fresh
///
/// cached_progress is user-scoped in Drift SQLite by userId, preserving
/// offline progress for returning accounts while preventing data cross-talk.
class AccountSwitchService {
  AccountSwitchService(this._ref, this._cache);
  final Ref _ref;
  final OfflineCacheService _cache;

  /// Attempts to switch accounts. Returns a [SwitchResult] describing
  /// the outcome — the UI layer decides how to present it.
  Future<SwitchResult> switchAccount() async {
    // 1. Online guard
    final isOnline = _ref.read(connectivityProvider);
    if (!isOnline) return SwitchOffline();

    try {
      // 2. Flush pending writes so User A's data reaches Supabase
      final readingService = _ref.read(readingServiceProvider);
      await readingService.flushWriteQueue();

      // 3. Verify the queue is actually empty after flush
      final remaining = await _cache.pendingWriteCount();
      if (remaining > 0) {
        return SwitchFlushFailed(remaining);
      }

      // 4. Clear the write queue (defensive — should already be empty)
      await _cache.clearWriteQueue();

      // 5. Sign out
      await _ref.read(authRepositoryProvider).signOut();

      // 6. Invalidate all user-scoped providers so the next login
      //    rebuilds everything from scratch for the new user.
      _ref.invalidate(globalProgressProvider);
      _ref.invalidate(userStatsProvider);
      _ref.invalidate(detailedStatsProvider);
      _ref.invalidate(currentSettingsProvider);
      _ref.invalidate(activityLogProvider);
      _ref.invalidate(todayChaptersProvider);
      _ref.invalidate(continueReadingProvider);
      _ref.invalidate(userNameProvider);

      return SwitchSuccess();
    } catch (e) {
      return SwitchError(e.toString());
    }
  }
}

@Riverpod(keepAlive: true)
AccountSwitchService accountSwitchService(Ref ref) {
  final cache = ref.watch(offlineCacheServiceProvider);
  return AccountSwitchService(ref, cache);
}
