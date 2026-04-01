import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';

base class VersoErrorObserver extends ProviderObserver {
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
  }
}
