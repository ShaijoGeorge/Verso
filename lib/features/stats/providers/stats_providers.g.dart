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

String _$userStatsHash() => r'700f6bfa5c6935e4f2dd4a5407f3581108fa67a9';

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

String _$detailedStatsHash() => r'fc4c416cdba5a84bbfc24d3ac138ba87424e54de';

@ProviderFor(WeeklyOffset)
final weeklyOffsetProvider = WeeklyOffsetProvider._();

final class WeeklyOffsetProvider extends $NotifierProvider<WeeklyOffset, int> {
  WeeklyOffsetProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'weeklyOffsetProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$weeklyOffsetHash();

  @$internal
  @override
  WeeklyOffset create() => WeeklyOffset();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$weeklyOffsetHash() => r'e34de43d093f6c3637fbe1ff7bfb52457e20e787';

abstract class _$WeeklyOffset extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element = ref.element
        as $ClassProviderElement<AnyNotifier<int, int>, int, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(weeklyChartStats)
final weeklyChartStatsProvider = WeeklyChartStatsFamily._();

final class WeeklyChartStatsProvider extends $FunctionalProvider<
        AsyncValue<WeeklyChartData>, WeeklyChartData, FutureOr<WeeklyChartData>>
    with $FutureModifier<WeeklyChartData>, $FutureProvider<WeeklyChartData> {
  WeeklyChartStatsProvider._(
      {required WeeklyChartStatsFamily super.from, required int super.argument})
      : super(
          retry: null,
          name: r'weeklyChartStatsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$weeklyChartStatsHash();

  @override
  String toString() {
    return r'weeklyChartStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<WeeklyChartData> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<WeeklyChartData> create(Ref ref) {
    final argument = this.argument as int;
    return weeklyChartStats(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WeeklyChartStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$weeklyChartStatsHash() => r'4a081c10ebabe70e697e402ed8cb5284c043ffd8';

final class WeeklyChartStatsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<WeeklyChartData>, int> {
  WeeklyChartStatsFamily._()
      : super(
          retry: null,
          name: r'weeklyChartStatsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  WeeklyChartStatsProvider call(
    int weeksAgo,
  ) =>
      WeeklyChartStatsProvider._(argument: weeksAgo, from: this);

  @override
  String toString() => r'weeklyChartStatsProvider';
}

@ProviderFor(MonthlyOffset)
final monthlyOffsetProvider = MonthlyOffsetProvider._();

final class MonthlyOffsetProvider
    extends $NotifierProvider<MonthlyOffset, int> {
  MonthlyOffsetProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'monthlyOffsetProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$monthlyOffsetHash();

  @$internal
  @override
  MonthlyOffset create() => MonthlyOffset();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$monthlyOffsetHash() => r'28fb0e31b4841905d141b28aafaf41a00a98e38c';

abstract class _$MonthlyOffset extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element = ref.element
        as $ClassProviderElement<AnyNotifier<int, int>, int, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(monthlyChartStats)
final monthlyChartStatsProvider = MonthlyChartStatsFamily._();

final class MonthlyChartStatsProvider extends $FunctionalProvider<
        AsyncValue<MonthlyChartData>,
        MonthlyChartData,
        FutureOr<MonthlyChartData>>
    with $FutureModifier<MonthlyChartData>, $FutureProvider<MonthlyChartData> {
  MonthlyChartStatsProvider._(
      {required MonthlyChartStatsFamily super.from,
      required int super.argument})
      : super(
          retry: null,
          name: r'monthlyChartStatsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$monthlyChartStatsHash();

  @override
  String toString() {
    return r'monthlyChartStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MonthlyChartData> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<MonthlyChartData> create(Ref ref) {
    final argument = this.argument as int;
    return monthlyChartStats(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyChartStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthlyChartStatsHash() => r'90b69991898b833f88024b43860eea9a9dfb4da4';

final class MonthlyChartStatsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MonthlyChartData>, int> {
  MonthlyChartStatsFamily._()
      : super(
          retry: null,
          name: r'monthlyChartStatsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  MonthlyChartStatsProvider call(
    int monthsAgo,
  ) =>
      MonthlyChartStatsProvider._(argument: monthsAgo, from: this);

  @override
  String toString() => r'monthlyChartStatsProvider';
}

@ProviderFor(YearlyOffset)
final yearlyOffsetProvider = YearlyOffsetProvider._();

final class YearlyOffsetProvider extends $NotifierProvider<YearlyOffset, int> {
  YearlyOffsetProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'yearlyOffsetProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$yearlyOffsetHash();

  @$internal
  @override
  YearlyOffset create() => YearlyOffset();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$yearlyOffsetHash() => r'43685034da1fac30b779158ac181d08b0c8df21e';

abstract class _$YearlyOffset extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element = ref.element
        as $ClassProviderElement<AnyNotifier<int, int>, int, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(yearlyChartStats)
final yearlyChartStatsProvider = YearlyChartStatsFamily._();

final class YearlyChartStatsProvider extends $FunctionalProvider<
        AsyncValue<YearlyChartData>, YearlyChartData, FutureOr<YearlyChartData>>
    with $FutureModifier<YearlyChartData>, $FutureProvider<YearlyChartData> {
  YearlyChartStatsProvider._(
      {required YearlyChartStatsFamily super.from, required int super.argument})
      : super(
          retry: null,
          name: r'yearlyChartStatsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$yearlyChartStatsHash();

  @override
  String toString() {
    return r'yearlyChartStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<YearlyChartData> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<YearlyChartData> create(Ref ref) {
    final argument = this.argument as int;
    return yearlyChartStats(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is YearlyChartStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$yearlyChartStatsHash() => r'e06b6b6b03591e9ff28f24bd0cd12fea6d622af3';

final class YearlyChartStatsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<YearlyChartData>, int> {
  YearlyChartStatsFamily._()
      : super(
          retry: null,
          name: r'yearlyChartStatsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  YearlyChartStatsProvider call(
    int yearsAgo,
  ) =>
      YearlyChartStatsProvider._(argument: yearsAgo, from: this);

  @override
  String toString() => r'yearlyChartStatsProvider';
}
