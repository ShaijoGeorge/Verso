// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(settingsRepository)
const settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider extends $FunctionalProvider<
    SettingsRepository,
    SettingsRepository,
    SettingsRepository> with $Provider<SettingsRepository> {
  const SettingsRepositoryProvider._()
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
    r'47444fce5017fd8c86f1ede068a2d31573cc5628';

@ProviderFor(CurrentSettings)
const currentSettingsProvider = CurrentSettingsProvider._();

final class CurrentSettingsProvider
    extends $AsyncNotifierProvider<CurrentSettings, UserSettings> {
  const CurrentSettingsProvider._()
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

String _$currentSettingsHash() => r'fedd4e35a05e628f170d277f7e4ec9ed87aff15e';

abstract class _$CurrentSettings extends $AsyncNotifier<UserSettings> {
  FutureOr<UserSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<UserSettings>, UserSettings>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<UserSettings>, UserSettings>,
        AsyncValue<UserSettings>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
