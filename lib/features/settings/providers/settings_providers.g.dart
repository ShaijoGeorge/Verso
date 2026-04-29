// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider extends $FunctionalProvider<
    SettingsRepository,
    SettingsRepository,
    SettingsRepository> with $Provider<SettingsRepository> {
  SettingsRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'settingsRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'5849d89f9468753266ce5aa638352968fc190910';

@ProviderFor(CurrentSettings)
final currentSettingsProvider = CurrentSettingsProvider._();

final class CurrentSettingsProvider
    extends $AsyncNotifierProvider<CurrentSettings, UserSettings> {
  CurrentSettingsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentSettingsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentSettingsHash();

  @$internal
  @override
  CurrentSettings create() => CurrentSettings();
}

String _$currentSettingsHash() => r'ba9cdf9d50ae487a56bc17fd0582fe10a1977d4f';

abstract class _$CurrentSettings extends $AsyncNotifier<UserSettings> {
  FutureOr<UserSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UserSettings>, UserSettings>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<UserSettings>, UserSettings>,
        AsyncValue<UserSettings>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
