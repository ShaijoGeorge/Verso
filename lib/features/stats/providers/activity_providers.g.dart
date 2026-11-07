// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ActivityFilterState)
final activityFilterStateProvider = ActivityFilterStateProvider._();

final class ActivityFilterStateProvider
    extends $NotifierProvider<ActivityFilterState, ActivityFilter> {
  ActivityFilterStateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activityFilterStateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activityFilterStateHash();

  @$internal
  @override
  ActivityFilterState create() => ActivityFilterState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActivityFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActivityFilter>(value),
    );
  }
}

String _$activityFilterStateHash() =>
    r'ed891eef1d0d8e288d3ab436bbc2eb85196a4c25';

abstract class _$ActivityFilterState extends $Notifier<ActivityFilter> {
  ActivityFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ActivityFilter, ActivityFilter>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ActivityFilter, ActivityFilter>,
        ActivityFilter,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(activityLog)
final activityLogProvider = ActivityLogProvider._();

final class ActivityLogProvider extends $FunctionalProvider<
        AsyncValue<Map<DateTime, List<ActivityGroup>>>,
        Map<DateTime, List<ActivityGroup>>,
        FutureOr<Map<DateTime, List<ActivityGroup>>>>
    with
        $FutureModifier<Map<DateTime, List<ActivityGroup>>>,
        $FutureProvider<Map<DateTime, List<ActivityGroup>>> {
  ActivityLogProvider._()
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
  $FutureProviderElement<Map<DateTime, List<ActivityGroup>>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<DateTime, List<ActivityGroup>>> create(Ref ref) {
    return activityLog(ref);
  }
}

String _$activityLogHash() => r'47fd5d723f888bb580fe7f526711f4bf0283410b';

@ProviderFor(booksWithActivity)
final booksWithActivityProvider = BooksWithActivityProvider._();

final class BooksWithActivityProvider extends $FunctionalProvider<
        AsyncValue<List<BibleBook>>, List<BibleBook>, FutureOr<List<BibleBook>>>
    with $FutureModifier<List<BibleBook>>, $FutureProvider<List<BibleBook>> {
  BooksWithActivityProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'booksWithActivityProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$booksWithActivityHash();

  @$internal
  @override
  $FutureProviderElement<List<BibleBook>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<BibleBook>> create(Ref ref) {
    return booksWithActivity(ref);
  }
}

String _$booksWithActivityHash() => r'c10737d7320861ddf94f5e562b609329b44ab676';
