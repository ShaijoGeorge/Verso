import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

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
    await _supabase.auth.updateUser(UserAttributes(email: newEmail));
  }

  // Update Password
  Future<void> updatePassword(String newPassword) async {
    await _supabase.auth.updateUser(UserAttributes(password: newPassword));
  }
}