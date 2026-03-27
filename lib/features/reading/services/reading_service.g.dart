// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(readingService)
final readingServiceProvider = ReadingServiceProvider._();

final class ReadingServiceProvider
    extends $FunctionalProvider<ReadingService, ReadingService, ReadingService>
    with $Provider<ReadingService> {
  ReadingServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'readingServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$readingServiceHash();

  @$internal
  @override
  $ProviderElement<ReadingService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReadingService create(Ref ref) {
    return readingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadingService>(value),
    );
  }
}

String _$readingServiceHash() => r'da30ad8ff0c43c9738886512e70bdd6c50f459bc';
