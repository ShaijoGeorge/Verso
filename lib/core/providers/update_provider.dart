import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verso/core/providers/package_info_provider.dart';
import 'package:verso/core/services/update_service.dart';

final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService();
});

final updateCheckProvider = FutureProvider<AppUpdateInfo?>((ref) async {
  final packageInfo = ref.watch(packageInfoProvider);
  final service = ref.watch(updateServiceProvider);
  return service.checkForUpdate(
    currentVersion: packageInfo.version,
    currentBuildNumber: packageInfo.buildNumber,
  );
});
