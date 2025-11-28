import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';

part 'auth_providers.g.dart';

// Provide the Repository
@riverpod
AuthRepository authRepository(Ref ref) {
  // Supabase.instance.client is initialized in main.dart
  return AuthRepository(Supabase.instance.client);
}

// Provide the "Current User" Stream
// This is the most important provider. The UI will watch this.
// If it is null = Show Login Screen.
// If it has a User = Show Home Screen.
@riverpod
Stream<User?> authUser(Ref ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges.map((state) => state.session?.user);
}