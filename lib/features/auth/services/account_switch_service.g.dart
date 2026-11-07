// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_switch_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(accountSwitchService)
final accountSwitchServiceProvider = AccountSwitchServiceProvider._();

final class AccountSwitchServiceProvider extends $FunctionalProvider<
    AccountSwitchService,
    AccountSwitchService,
    AccountSwitchService> with $Provider<AccountSwitchService> {
  AccountSwitchServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'accountSwitchServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$accountSwitchServiceHash();

  @$internal
  @override
  $ProviderElement<AccountSwitchService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AccountSwitchService create(Ref ref) {
    return accountSwitchService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountSwitchService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountSwitchService>(value),
    );
  }
}

String _$accountSwitchServiceHash() =>
    r'724af9ad1d599e64fb0b9003beb8014ad9b85c49';
