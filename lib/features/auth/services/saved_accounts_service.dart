import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso/features/auth/models/saved_account.dart';

part 'saved_accounts_service.g.dart';

class SavedAccountsService {
  static const _kSavedAccountsKey = 'verso_saved_accounts_list';

  /// Retrieves all saved accounts stored on this device.
  Future<List<SavedAccount>> getSavedAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSavedAccountsKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((item) => SavedAccount.fromJson(item as Map<String, dynamic>))
          .where((acc) => acc.userId.isNotEmpty && acc.refreshToken.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Saves or updates a saved account on this device.
  Future<void> saveOrUpdateAccount(SavedAccount account) async {
    if (account.userId.isEmpty || account.refreshToken.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final existing = await getSavedAccounts();
    final updated = <SavedAccount>[];
    var found = false;

    for (final acc in existing) {
      if (acc.userId == account.userId) {
        // Update with new tokens and profile metadata
        updated.add(account);
        found = true;
      } else {
        updated.add(acc);
      }
    }

    if (!found) {
      updated.add(account);
    }

    final raw = json.encode(updated.map((a) => a.toJson()).toList());
    await prefs.setString(_kSavedAccountsKey, raw);
  }

  /// Convenience method to sync from a Supabase [Session].
  Future<void> syncCurrentSession(Session session) async {
    final user = session.user;
    final refreshToken = session.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return;

    final fullName = (user.userMetadata?['full_name'] as String?)?.trim();
    final displayName = (fullName != null && fullName.isNotEmpty)
        ? fullName
        : (user.email?.split('@').first ?? 'User');

    final account = SavedAccount(
      userId: user.id,
      email: user.email ?? '',
      displayName: displayName,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      refreshToken: refreshToken,
      lastActive: DateTime.now(),
    );

    await saveOrUpdateAccount(account);
  }

  /// Removes an account completely from this device.
  Future<void> removeAccount(String userId) async {
    if (userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final existing = await getSavedAccounts();
    final updated = existing.where((acc) => acc.userId != userId).toList();
    final raw = json.encode(updated.map((a) => a.toJson()).toList());
    await prefs.setString(_kSavedAccountsKey, raw);
  }

  /// Updates the last active timestamp for an account.
  Future<void> touchAccount(String userId) async {
    final existing = await getSavedAccounts();
    final index = existing.indexWhere((acc) => acc.userId == userId);
    if (index != -1) {
      existing[index] = existing[index].copyWith(lastActive: DateTime.now());
      final prefs = await SharedPreferences.getInstance();
      final raw = json.encode(existing.map((a) => a.toJson()).toList());
      await prefs.setString(_kSavedAccountsKey, raw);
    }
  }
}

@Riverpod(keepAlive: true)
SavedAccountsService savedAccountsService(Ref ref) {
  return SavedAccountsService();
}

@riverpod
class SavedAccountsList extends _$SavedAccountsList {
  static int compareAccounts(
    SavedAccount a,
    SavedAccount b,
    String? currentUserId,
  ) {
    if (a.userId == b.userId) return 0;
    if (a.userId == currentUserId) return -1;
    if (b.userId == currentUserId) return 1;
    final dateComp = b.lastActive.compareTo(a.lastActive);
    if (dateComp != 0) return dateComp;
    return a.userId.compareTo(b.userId);
  }

  @override
  Future<List<SavedAccount>> build() async {
    final service = ref.watch(savedAccountsServiceProvider);
    final accounts = await service.getSavedAccounts();

    // Sort: current user first, then by lastActive descending
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    accounts.sort((a, b) => compareAccounts(a, b, currentUserId));

    return accounts;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(savedAccountsServiceProvider);
      final accounts = await service.getSavedAccounts();
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      accounts.sort((a, b) => compareAccounts(a, b, currentUserId));
      return accounts;
    });
  }

  Future<void> removeAccount(String userId) async {
    final service = ref.read(savedAccountsServiceProvider);
    await service.removeAccount(userId);
    await refresh();
  }
}
