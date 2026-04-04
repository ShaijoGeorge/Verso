// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns the most recently read book that isn't fully completed,
/// so the user can quickly jump back in.

@ProviderFor(continueReading)
final continueReadingProvider = ContinueReadingProvider._();

/// Returns the most recently read book that isn't fully completed,
/// so the user can quickly jump back in.

final class ContinueReadingProvider extends $FunctionalProvider<
        AsyncValue<ContinueReadingInfo?>,
        ContinueReadingInfo?,
        FutureOr<ContinueReadingInfo?>>
    with
        $FutureModifier<ContinueReadingInfo?>,
        $FutureProvider<ContinueReadingInfo?> {
  /// Returns the most recently read book that isn't fully completed,
  /// so the user can quickly jump back in.
  ContinueReadingProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'continueReadingProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$continueReadingHash();

  @$internal
  @override
  $FutureProviderElement<ContinueReadingInfo?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ContinueReadingInfo?> create(Ref ref) {
    return continueReading(ref);
  }
}

String _$continueReadingHash() => r'5d1340f17735ae98b6d6ee449d98b2d8fa823843';

/// Number of chapters read today.

@ProviderFor(todayChapters)
final todayChaptersProvider = TodayChaptersProvider._();

/// Number of chapters read today.

final class TodayChaptersProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Number of chapters read today.
  TodayChaptersProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'todayChaptersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$todayChaptersHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return todayChapters(ref);
  }
}

String _$todayChaptersHash() => r'306f69f7c2c13a9b125048e71bb945f2516f07a9';

/// Returns the user's first name from Supabase auth metadata.

@ProviderFor(userName)
final userNameProvider = UserNameProvider._();

/// Returns the user's first name from Supabase auth metadata.

final class UserNameProvider extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Returns the user's first name from Supabase auth metadata.
  UserNameProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userNameProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userNameHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return userName(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$userNameHash() => r'368b25efe2692f4c23e975c656b647bc14eb75d3';

@ProviderFor(verseRepository)
final verseRepositoryProvider = VerseRepositoryProvider._();

final class VerseRepositoryProvider extends $FunctionalProvider<VerseRepository,
    VerseRepository, VerseRepository> with $Provider<VerseRepository> {
  VerseRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'verseRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$verseRepositoryHash();

  @$internal
  @override
  $ProviderElement<VerseRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VerseRepository create(Ref ref) {
    return verseRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VerseRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VerseRepository>(value),
    );
  }
}

String _$verseRepositoryHash() => r'd3970a185123a91743181b28453438309cded8a9';

@ProviderFor(dailyVerse)
final dailyVerseProvider = DailyVerseProvider._();

final class DailyVerseProvider extends $FunctionalProvider<
        AsyncValue<Map<String, dynamic>>,
        Map<String, dynamic>,
        FutureOr<Map<String, dynamic>>>
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  DailyVerseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dailyVerseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dailyVerseHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    return dailyVerse(ref);
  }
}

String _$dailyVerseHash() => r'e8280c5400cd7bcb01b7e040694ddc999ac57ab7';
