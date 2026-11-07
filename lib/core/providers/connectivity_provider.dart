import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

@Riverpod(keepAlive: true)
class ConnectivityNotifier extends _$ConnectivityNotifier {
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  bool build() {
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      state = !results.contains(ConnectivityResult.none);
    });

    // Check current state immediately
    Connectivity().checkConnectivity().then((results) {
      state = !results.contains(ConnectivityResult.none);
    });

    ref.onDispose(() => _subscription.cancel());
    return true; // Assume online initially; the stream will correct quickly
  }
}
