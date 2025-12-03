// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userStats)
const userStatsProvider = UserStatsProvider._();

final class UserStatsProvider extends $FunctionalProvider<AsyncValue<UserStats>,
        UserStats, FutureOr<UserStats>>
    with $FutureModifier<UserStats>, $FutureProvider<UserStats> {
  const UserStatsProvider._()
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

String _$userStatsHash() => r'c9ad9667cbd47e455da8c8c31f40ac188c5e6942';

@ProviderFor(detailedStats)
const detailedStatsProvider = DetailedStatsProvider._();

final class DetailedStatsProvider extends $FunctionalProvider<
        AsyncValue<DetailedStats>, DetailedStats, FutureOr<DetailedStats>>
    with $FutureModifier<DetailedStats>, $FutureProvider<DetailedStats> {
  const DetailedStatsProvider._()
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

String _$detailedStatsHash() => r'8b477ef35e4ccff3cb48c70b7474ba0f07f61f71';
