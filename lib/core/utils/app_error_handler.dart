import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class CrashReporter {
  Future<void> init();
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? extra,
  });
  void logBreadcrumb(String message, {String? category});
  void setUserContext({required String id, String? email});
}

class AppErrorHandler {
  static String getMessage(Object error) {
    if (error is AuthException) {
      if (error is AuthRetryableFetchException ||
          error.message.toLowerCase().contains('failed host lookup')) {
        return 'No internet connection. Please check your network.';
      }
      // Supabase specific Auth errors
      if (error.message.contains('Invalid login credentials')) {
        return 'Incorrect email or password. Please try again.';
      }
      if (error.message.contains('User already registered')) {
        return 'This email is already in use. Try logging in.';
      }
      return error.message; // Fallback to Supabase's message (usually readable)
    }

    if (error is SocketException ||
        error.toString().contains('SocketException') ||
        error.toString().contains('AuthRetryableFetchException')) {
      return 'No internet connection. Please check your network.';
    }

    if (error is FormatException) {
      return 'Invalid data format received.';
    }

    // Default cleanup for generic Dart exceptions
    var msg = error.toString();
    if (msg.startsWith('Exception: ')) {
      msg = msg.replaceAll('Exception: ', '');
    }
    return msg;
  }
}
