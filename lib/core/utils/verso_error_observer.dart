import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verso/core/utils/app_error_handler.dart';

base class VersoErrorObserver extends ProviderObserver {
  const VersoErrorObserver(this.crashReporter);

  final CrashReporter crashReporter;

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    dev.log(
      'Provider ${context.provider.name ?? context.provider.runtimeType} failed',
      error: error,
      stackTrace: stackTrace,
      name: 'VersoErrorObserver',
    );
    crashReporter.recordError(
      error,
      stackTrace,
      reason:
          'Provider failure: ${context.provider.name ?? context.provider.runtimeType}',
    );
  }
}
