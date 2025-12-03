// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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

String _$bibleRepositoryHash() => r'5a30c2279c0a8fff477c8f224751fc75df275d08';

@ProviderFor(bookReadCount)
const bookReadCountProvider = BookReadCountFamily._();

final class BookReadCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
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

String _$bookReadCountHash() => r'6da6891e418aede2ad0ea2e641bba8f4d20c3ee0';

final class BookReadCountFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, int> {
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
        Stream<List<ReadingProgress>>>
    with
        $FutureModifier<List<ReadingProgress>>,
        $StreamProvider<List<ReadingProgress>> {
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

String _$bookProgressHash() => r'14e6e01524966da8518d7d07441253b7d00928fd';

final class BookProgressFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ReadingProgress>>, int> {
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
