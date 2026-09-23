import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso/features/auth/models/saved_account.dart';

part 'saved_accounts_service.g.dart';

class SavedAccountsService {
  SavedAccountsService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              iOptions:
                  IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  final FlutterSecureStorage _secureStorage;

  static const _kSavedAccountsKey = 'verso_saved_accounts_list';
  static const _kTokenKeyPrefix = 'verso_refresh_token_';

  String _tokenKey(String userId) => '$_kTokenKeyPrefix$userId';

  /// Retrieves all saved accounts stored on this device.
  ///
  /// Profile metadata is read from SharedPreferences, while sensitive
  /// refresh tokens are loaded from hardware-backed secure storage.
  /// If any legacy plaintext tokens exist in SharedPreferences, they are
  /// automatically migrated to secure storage and stripped from SharedPreferences.
  Future<List<SavedAccount>> getSavedAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSavedAccountsKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = json.decode(raw) as List<dynamic>;
      final accounts = <SavedAccount>[];
      var needsSanitization = false;

      for (final item in list) {
        final acc = SavedAccount.fromJson(item as Map<String, dynamic>);
        if (acc.userId.isEmpty) continue;

        // 1. Fetch token from hardware-backed secure storage
        var token = await _secureStorage.read(key: _tokenKey(acc.userId));

        // 2. Backward compatibility & migration:
        // If secure storage doesn't have it yet, check if legacy SharedPreferences JSON had it.
        if ((token == null || token.isEmpty) && acc.refreshToken.isNotEmpty) {
          token = acc.refreshToken;
          await _secureStorage.write(
            key: _tokenKey(acc.userId),
            value: token,
          );
          needsSanitization = true;
        } else if (acc.refreshToken.isNotEmpty) {
          // If SharedPreferences still has plaintext token even though secure storage has it,
          // mark for sanitization to strip it from SharedPreferences.
          needsSanitization = true;
        }

        if (token != null && token.isNotEmpty) {
          accounts.add(acc.copyWith(refreshToken: token));
        }
      }

      // If any accounts had plaintext tokens in SharedPreferences, rewrite SharedPreferences
      // without tokens (toJson() excludes refreshToken by default).
      if (needsSanitization) {
        final sanitizedRaw =
            json.encode(accounts.map((a) => a.toJson()).toList());
        await prefs.setString(_kSavedAccountsKey, sanitizedRaw);
      }

      return accounts;
    } catch (_) {
      return [];
    }
  }

  /// Saves or updates a saved account on this device.
  Future<void> saveOrUpdateAccount(SavedAccount account) async {
    if (account.userId.isEmpty || account.refreshToken.isEmpty) return;

    // 1. Save sensitive refresh token to hardware-backed secure storage
    await _secureStorage.write(
      key: _tokenKey(account.userId),
      value: account.refreshToken,
    );

    // 2. Save profile metadata to SharedPreferences (toJson() excludes refreshToken)
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

    // 1. Delete token from secure storage
    await _secureStorage.delete(key: _tokenKey(userId));

    // 2. Remove from SharedPreferences
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
