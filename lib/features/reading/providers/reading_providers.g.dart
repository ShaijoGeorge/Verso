// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BiblePageTrigger)
final biblePageTriggerProvider = BiblePageTriggerProvider._();

final class BiblePageTriggerProvider
    extends $NotifierProvider<BiblePageTrigger, int> {
  BiblePageTriggerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'biblePageTriggerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$biblePageTriggerHash();

  @$internal
  @override
  BiblePageTrigger create() => BiblePageTrigger();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$biblePageTriggerHash() => r'34b43e36e59afd9b0808b7ff6ec55aac8d2d7eb0';

abstract class _$BiblePageTrigger extends $Notifier<int> {
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

@ProviderFor(bibleRepository)
final bibleRepositoryProvider = BibleRepositoryProvider._();

final class BibleRepositoryProvider extends $FunctionalProvider<BibleRepository,
    BibleRepository, BibleRepository> with $Provider<BibleRepository> {
  BibleRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'bibleRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$bibleRepositoryHash();

  @$internal
  @override
  $ProviderElement<BibleRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BibleRepository create(Ref ref) {
    return bibleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BibleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BibleRepository>(value),
    );
  }
}

String _$bibleRepositoryHash() => r'5a30c2279c0a8fff477c8f224751fc75df275d08';

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appDatabaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'448adad5717e7b1c0b3ca3ca7e03d0b2116237af';

@ProviderFor(offlineCacheService)
final offlineCacheServiceProvider = OfflineCacheServiceProvider._();

final class OfflineCacheServiceProvider extends $FunctionalProvider<
    OfflineCacheService,
    OfflineCacheService,
    OfflineCacheService> with $Provider<OfflineCacheService> {
  OfflineCacheServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'offlineCacheServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$offlineCacheServiceHash();

  @$internal
  @override
  $ProviderElement<OfflineCacheService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OfflineCacheService create(Ref ref) {
    return offlineCacheService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OfflineCacheService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OfflineCacheService>(value),
    );
  }
}

String _$offlineCacheServiceHash() =>
    r'0693a5b02cc1367ac3a836abc4c7f55721d84ccb';

@ProviderFor(globalProgress)
final globalProgressProvider = GlobalProgressProvider._();

final class GlobalProgressProvider extends $FunctionalProvider<
        AsyncValue<List<ReadingProgress>>,
        List<ReadingProgress>,
        Stream<List<ReadingProgress>>>
    with
        $FutureModifier<List<ReadingProgress>>,
        $StreamProvider<List<ReadingProgress>> {
  GlobalProgressProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'globalProgressProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$globalProgressHash();

  @$internal
  @override
  $StreamProviderElement<List<ReadingProgress>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<ReadingProgress>> create(Ref ref) {
    return globalProgress(ref);
  }
}

String _$globalProgressHash() => r'bbaa5600dfe5d1579aa666a07fa7d1b973f33601';

@ProviderFor(bookReadCount)
final bookReadCountProvider = BookReadCountFamily._();

final class BookReadCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  BookReadCountProvider._(
      {required BookReadCountFamily super.from, required int super.argument})
      : super(
          retry: null,
          name: r'bookReadCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$bookReadCountHash();

  @override
  String toString() {
    return r'bookReadCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    final argument = this.argument as int;
    return bookReadCount(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BookReadCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookReadCountHash() => r'c859087e1586a5622d92fc99972608111e698b5b';

final class BookReadCountFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, int> {
  BookReadCountFamily._()
      : super(
          retry: null,
          name: r'bookReadCountProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  BookReadCountProvider call(
    int bookId,
  ) =>
      BookReadCountProvider._(argument: bookId, from: this);

  @override
  String toString() => r'bookReadCountProvider';
}

@ProviderFor(bookProgress)
final bookProgressProvider = BookProgressFamily._();

final class BookProgressProvider extends $FunctionalProvider<
        AsyncValue<List<ReadingProgress>>,
        List<ReadingProgress>,
        Stream<List<ReadingProgress>>>
    with
        $FutureModifier<List<ReadingProgress>>,
        $StreamProvider<List<ReadingProgress>> {
  BookProgressProvider._(
      {required BookProgressFamily super.from, required int super.argument})
      : super(
          retry: null,
          name: r'bookProgressProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$bookProgressHash();

  @override
  String toString() {
    return r'bookProgressProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ReadingProgress>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<ReadingProgress>> create(Ref ref) {
    final argument = this.argument as int;
    return bookProgress(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BookProgressProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookProgressHash() => r'98018fb7f85fbe32b428516ff98681f38111f2ae';

final class BookProgressFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ReadingProgress>>, int> {
  BookProgressFamily._()
      : super(
          retry: null,
          name: r'bookProgressProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  BookProgressProvider call(
    int bookId,
  ) =>
      BookProgressProvider._(argument: bookId, from: this);

  @override
  String toString() => r'bookProgressProvider';
}
