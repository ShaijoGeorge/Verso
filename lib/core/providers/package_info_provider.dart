import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// A global provider that synchronously provides [PackageInfo].
/// It MUST be overridden in `ProviderScope` when the app starts.
final packageInfoProvider = Provider<PackageInfo>((ref) {
  throw UnimplementedError(
      'packageInfoProvider must be overridden in main.dart');
});
