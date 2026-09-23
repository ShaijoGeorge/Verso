// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_accounts_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(savedAccountsService)
final savedAccountsServiceProvider = SavedAccountsServiceProvider._();

final class SavedAccountsServiceProvider extends $FunctionalProvider<
    SavedAccountsService,
    SavedAccountsService,
    SavedAccountsService> with $Provider<SavedAccountsService> {
  SavedAccountsServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'savedAccountsServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$savedAccountsServiceHash();

  @$internal
  @override
  $ProviderElement<SavedAccountsService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SavedAccountsService create(Ref ref) {
    return savedAccountsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavedAccountsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavedAccountsService>(value),
    );
  }
}

String _$savedAccountsServiceHash() =>
    r'59bb581ab93692437f512da4c352a8c8d313b1de';

@ProviderFor(SavedAccountsList)
final savedAccountsListProvider = SavedAccountsListProvider._();

final class SavedAccountsListProvider
    extends $AsyncNotifierProvider<SavedAccountsList, List<SavedAccount>> {
  SavedAccountsListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'savedAccountsListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$savedAccountsListHash();

  @$internal
  @override
  SavedAccountsList create() => SavedAccountsList();
}

String _$savedAccountsListHash() => r'c65b7af6d6aef2050b023220ca7f6f069dfec6fb';

abstract class _$SavedAccountsList extends $AsyncNotifier<List<SavedAccount>> {
  FutureOr<List<SavedAccount>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<SavedAccount>>, List<SavedAccount>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<SavedAccount>>, List<SavedAccount>>,
        AsyncValue<List<SavedAccount>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
