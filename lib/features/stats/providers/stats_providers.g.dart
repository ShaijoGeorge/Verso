// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userStats)
final userStatsProvider = UserStatsProvider._();

final class UserStatsProvider extends $FunctionalProvider<AsyncValue<UserStats>,
        UserStats, FutureOr<UserStats>>
    with $FutureModifier<UserStats>, $FutureProvider<UserStats> {
  UserStatsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userStatsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userStatsHash();

  @$internal
  @override
  $FutureProviderElement<UserStats> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UserStats> create(Ref ref) {
    return userStats(ref);
  }
}

String _$userStatsHash() => r'd414c593cfd78bdd98f67970e7561f60bd996c15';

@ProviderFor(detailedStats)
final detailedStatsProvider = DetailedStatsProvider._();

final class DetailedStatsProvider extends $FunctionalProvider<
        AsyncValue<DetailedStats>, DetailedStats, FutureOr<DetailedStats>>
    with $FutureModifier<DetailedStats>, $FutureProvider<DetailedStats> {
  DetailedStatsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'detailedStatsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$detailedStatsHash();

  @$internal
  @override
  $FutureProviderElement<DetailedStats> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DetailedStats> create(Ref ref) {
    return detailedStats(ref);
  }
}

String _$detailedStatsHash() => r'8efbe2fd381713244e33d292f094ffb8497e3586';
