class AppConstants {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Custom URL scheme used for deep linking (avoids collisions with io.supabase.flutter)
  static const String appScheme = 'verso';
  static const String resetCallbackUrl = '$appScheme://reset-callback';
  static const String emailCallbackUrl = '$appScheme://email-callback';

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
