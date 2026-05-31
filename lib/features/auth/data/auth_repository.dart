import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(this._supabase);
  final SupabaseClient _supabase;

  // Get the current user (if logged in)
  User? get currentUser => _supabase.auth.currentUser;

  // Listen to auth changes (Logged In <-> Logged Out)
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign Up
  Future<void> signUp(String email, String password, String username) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': username}, // We store the name in metadata
    );
  }

  // Sign In (This was missing before)
  Future<void> signIn(String email, String password) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // --- NEW METHODS FOR PROFESSIONAL AUTH ---

  Future<void> resetPassword(String email) async {
    // This sends the email with a link like: io.supabase.flutter://reset-callback
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.flutter://reset-callback',
    );
  }

  // Update Email
  Future<void> updateEmail(String newEmail) async {
    await _supabase.auth.updateUser(
      UserAttributes(email: newEmail),
      emailRedirectTo: 'io.supabase.flutter://reset-callback',
    );
  }

  // Update Password
  Future<void> updatePassword(String newPassword) async {
    await _supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Merges [data] into the current user's metadata without overwriting
  /// existing fields (e.g. full_name set during sign-up is preserved).
  /// Safe to call even if the user isn't logged in - it's a no-op then.
  Future<void> updateUserMetadata(Map<String, dynamic> data) async {
    if (_supabase.auth.currentUser == null) return;

    // Supabase merges the new map into existing metadata - safe, non-destructive
    await _supabase.auth.updateUser(UserAttributes(data: data));
  }

  // Verify user identity before sensitive changes ---
  Future<void> reauthenticate(String currentPassword) async {
    final email = _supabase.auth.currentUser?.email;
    if (email == null) throw Exception('User not logged in');

    // Attempt to sign in. If it throws, the password is wrong.
    await _supabase.auth.signInWithPassword(
      email: email,
      password: currentPassword,
    );
  }
}
