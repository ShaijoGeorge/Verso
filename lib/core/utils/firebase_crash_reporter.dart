import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:verso/core/utils/app_error_handler.dart';

class FirebaseCrashReporter implements CrashReporter {
  @override
  Future<void> init() async {
    // Disable Crashlytics in debug mode to avoid cluttering your Firebase dashboard.
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? extra,
  }) async {
    if (extra != null) {
      for (final entry in extra.entries) {
        // Custom keys allow you to attach extra metadata to Crashlytics reports.
        if (entry.value != null) {
          FirebaseCrashlytics.instance
              .setCustomKey(entry.key, entry.value as Object);
        }
      }
    }

    await FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  @override
  void logBreadcrumb(String message, {String? category}) {
    FirebaseCrashlytics.instance
        .log(category != null ? '[$category] $message' : message);
  }

  @override
  void setUserContext({required String id, String? email}) {
    FirebaseCrashlytics.instance.setUserIdentifier(id);
    if (email != null) {
      FirebaseCrashlytics.instance.setCustomKey('email', email);
    }
  }
}
