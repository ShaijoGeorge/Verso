// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(activityLog)
const activityLogProvider = ActivityLogProvider._();

final class ActivityLogProvider extends $FunctionalProvider<
        AsyncValue<List<ActivityGroup>>,
        List<ActivityGroup>,
        FutureOr<List<ActivityGroup>>>
    with
        $FutureModifier<List<ActivityGroup>>,
        $FutureProvider<List<ActivityGroup>> {
  const ActivityLogProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activityLogProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activityLogHash();

  @$internal
  @override
  $FutureProviderElement<List<ActivityGroup>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<ActivityGroup>> create(Ref ref) {
    return activityLog(ref);
  }
}

String _$activityLogHash() => r'1acbc0cdfdcee56c3e83e48441f82e0909a1230d';
