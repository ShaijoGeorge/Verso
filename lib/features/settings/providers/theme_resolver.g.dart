// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_resolver.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Emits a tick every 60 s so schedule-based theme switching stays current.

@ProviderFor(scheduleTickStream)
final scheduleTickStreamProvider = ScheduleTickStreamProvider._();

/// Emits a tick every 60 s so schedule-based theme switching stays current.

final class ScheduleTickStreamProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Emits a tick every 60 s so schedule-based theme switching stays current.
  ScheduleTickStreamProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'scheduleTickStreamProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$scheduleTickStreamHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return scheduleTickStream(ref);
  }
}

String _$scheduleTickStreamHash() =>
    r'c46cca1fd68c8e9cc63f0775be2728169981a6a1';

/// Provides the [ResolvedTheme] to wire into [MaterialApp].

@ProviderFor(resolvedTheme)
final resolvedThemeProvider = ResolvedThemeFamily._();

/// Provides the [ResolvedTheme] to wire into [MaterialApp].

final class ResolvedThemeProvider
    extends $FunctionalProvider<ResolvedTheme, ResolvedTheme, ResolvedTheme>
    with $Provider<ResolvedTheme> {
  /// Provides the [ResolvedTheme] to wire into [MaterialApp].
  ResolvedThemeProvider._(
      {required ResolvedThemeFamily super.from,
      required Brightness super.argument})
      : super(
          retry: null,
          name: r'resolvedThemeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$resolvedThemeHash();

  @override
  String toString() {
    return r'resolvedThemeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<ResolvedTheme> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ResolvedTheme create(Ref ref) {
    final argument = this.argument as Brightness;
    return resolvedTheme(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ResolvedTheme value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ResolvedTheme>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ResolvedThemeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$resolvedThemeHash() => r'7f3478109527dd8cbb4f31666a100bc452b15f5a';

/// Provides the [ResolvedTheme] to wire into [MaterialApp].

final class ResolvedThemeFamily extends $Family
    with $FunctionalFamilyOverride<ResolvedTheme, Brightness> {
  ResolvedThemeFamily._()
      : super(
          retry: null,
          name: r'resolvedThemeProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provides the [ResolvedTheme] to wire into [MaterialApp].

  ResolvedThemeProvider call(
    Brightness systemBrightness,
  ) =>
      ResolvedThemeProvider._(argument: systemBrightness, from: this);

  @override
  String toString() => r'resolvedThemeProvider';
}

/// Convenience: returns the resolved [AppearanceStyle] for use in UI.

@ProviderFor(effectiveStyle)
final effectiveStyleProvider = EffectiveStyleProvider._();

/// Convenience: returns the resolved [AppearanceStyle] for use in UI.

final class EffectiveStyleProvider extends $FunctionalProvider<AppearanceStyle?,
    AppearanceStyle?, AppearanceStyle?> with $Provider<AppearanceStyle?> {
  /// Convenience: returns the resolved [AppearanceStyle] for use in UI.
  EffectiveStyleProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'effectiveStyleProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$effectiveStyleHash();

  @$internal
  @override
  $ProviderElement<AppearanceStyle?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppearanceStyle? create(Ref ref) {
    return effectiveStyle(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppearanceStyle? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppearanceStyle?>(value),
    );
  }
}

String _$effectiveStyleHash() => r'63360439fc0d580ad02db4622b4c0af60746492d';
