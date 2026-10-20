import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso/core/constants.dart';

class AuthRepository {
  AuthRepository(this._supabase) {
    _initPendingEmail();
  }

  final SupabaseClient _supabase;
  static const _pendingEmailKey = 'pending_email_change';
  String? _pendingEmail;

  /// Cached pending email change for synchronous access in router guards
  String? get pendingEmail => _pendingEmail;

  Future<void> _initPendingEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _pendingEmail = prefs.getString(_pendingEmailKey);
    } catch (_) {}
  }

  Future<void> savePendingEmailChange(String newEmail) async {
    _pendingEmail = newEmail;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pendingEmailKey, newEmail);
    } catch (_) {}
  }

  Future<String?> getPendingEmailChange() async {
    if (_pendingEmail != null) return _pendingEmail;
    try {
      final prefs = await SharedPreferences.getInstance();
      return _pendingEmail = prefs.getString(_pendingEmailKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearPendingEmailChange() async {
    _pendingEmail = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingEmailKey);
    } catch (_) {}
  }

  // Get the current user (if logged in)
  User? get currentUser => _supabase.auth.currentUser;

  // Listen to auth changes (Logged In <-> Logged Out)
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign Up
  Future<void> signUp(String email, String password, String username) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': username}, // We store the name in metadata
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign In (This was missing before)
  Future<void> signIn(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut({SignOutScope scope = SignOutScope.global}) async {
    try {
      await _supabase.auth.signOut(scope: scope);
    } catch (e) {
      rethrow;
    }
  }

  // --- NEW METHODS FOR PROFESSIONAL AUTH ---

  Future<void> resetPassword(String email) async {
    try {
      // This sends the email with a link like: verso://reset-callback
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: AppConstants.resetCallbackUrl,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Update Email
  Future<void> updateEmail(String newEmail) async {
    try {
      await savePendingEmailChange(newEmail);
      await _supabase.auth.updateUser(
        UserAttributes(email: newEmail),
        emailRedirectTo: AppConstants.resetCallbackUrl,
      );
    } catch (e) {
      await clearPendingEmailChange();
      rethrow;
    }
  }

  // Update Password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      rethrow;
    }
  }

  /// Merges [data] into the current user's metadata without overwriting
  /// existing fields (e.g. full_name set during sign-up is preserved).
  /// Safe to call even if the user isn't logged in - it's a no-op then.
  Future<void> updateUserMetadata(Map<String, dynamic> data) async {
    if (_supabase.auth.currentUser == null) return;

    try {
      // Supabase merges the new map into existing metadata - safe, non-destructive
      await _supabase.auth.updateUser(UserAttributes(data: data));
    } catch (e) {
      rethrow;
    }
  }

  /// Syncs the user's selected Bible canon ('catholic', 'protestant', 'orthodox')
  /// to Supabase cloud. Updates user_metadata and attempts updating 'profiles'
  /// table if one exists.
  Future<void> syncCanonToCloud(String canonType) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // 1. Sync to Supabase Auth user_metadata (default for Verso)
    await updateUserMetadata({'canon_type': canonType});

    // 2. Also attempt updating 'profiles' table if it exists in Supabase
    try {
      await _supabase
          .from('profiles')
          .update({'canon_type': canonType}).eq('id', user.id);
    } catch (_) {
      // Ignore if profiles table does not exist
    }
  }

  // Verify user identity before sensitive changes ---
  Future<void> reauthenticate(String currentPassword) async {
    final email = _supabase.auth.currentUser?.email;
    if (email == null) throw Exception('User not logged in');

    try {
      // Attempt to sign in. If it throws, the password is wrong.
      await _supabase.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Permanently deletes the current user's account and all associated records
  /// by calling the Supabase `delete_user_account` RPC function, then clears
  /// local session credentials.
  Future<void> deleteAccount() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      // 1. Invoke the database RPC function to delete user and cascade records
      await _supabase.rpc<void>('delete_user_account');

      // 2. Clear any pending email change state
      await clearPendingEmailChange();

      // 3. Clear local session tokens
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
