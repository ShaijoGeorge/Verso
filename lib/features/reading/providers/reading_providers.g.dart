// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(databaseService)
const databaseServiceProvider = DatabaseServiceProvider._();

final class DatabaseServiceProvider extends $FunctionalProvider<DatabaseService,
    DatabaseService, DatabaseService> with $Provider<DatabaseService> {
  const DatabaseServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'databaseServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$databaseServiceHash();

  @$internal
  @override
  $ProviderElement<DatabaseService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DatabaseService create(Ref ref) {
    return databaseService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DatabaseService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DatabaseService>(value),
    );
  }
}

String _$databaseServiceHash() => r'323927c4138725be4427216964fece6d70043b46';

@ProviderFor(bibleRepository)
const bibleRepositoryProvider = BibleRepositoryProvider._();

final class BibleRepositoryProvider extends $FunctionalProvider<BibleRepository,
    BibleRepository, BibleRepository> with $Provider<BibleRepository> {
  const BibleRepositoryProvider._()
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

String _$bibleRepositoryHash() => r'f0eccf2369e7457cbbf58d7fdaf55a00119f9a08';

@ProviderFor(bookReadCount)
const bookReadCountProvider = BookReadCountFamily._();

final class BookReadCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  const BookReadCountProvider._(
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
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
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

String _$bookReadCountHash() => r'c99458c93af06788d193ad472838f2dbe0619a30';

final class BookReadCountFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, int> {
  const BookReadCountFamily._()
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
const bookProgressProvider = BookProgressFamily._();

final class BookProgressProvider extends $FunctionalProvider<
        AsyncValue<List<ReadingProgress>>,
        List<ReadingProgress>,
        FutureOr<List<ReadingProgress>>>
    with
        $FutureModifier<List<ReadingProgress>>,
        $FutureProvider<List<ReadingProgress>> {
  const BookProgressProvider._(
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
  $FutureProviderElement<List<ReadingProgress>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<ReadingProgress>> create(Ref ref) {
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

String _$bookProgressHash() => r'c95b213249750fcc655c7649f7245c6b55ee8c96';

final class BookProgressFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ReadingProgress>>, int> {
  const BookProgressFamily._()
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
