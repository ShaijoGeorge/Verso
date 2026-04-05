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

String _$userStatsHash() => r'0064337a131769b25b6a991921ce49bc73243b83';

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

String _$detailedStatsHash() => r'af245c22be89a0b75e73432d5e64c666d95ef2b0';
