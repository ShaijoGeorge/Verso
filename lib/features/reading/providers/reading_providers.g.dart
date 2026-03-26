// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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

String _$globalProgressHash() => r'b3ea4eddbdc9ce75d85d6400bc2454ab01e440aa';

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
