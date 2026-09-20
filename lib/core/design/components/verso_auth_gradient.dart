import 'package:flutter/material.dart';
import 'package:verso/core/design/extensions.dart';

/// The shared gradient background used on all auth screens.
///
/// ```dart
/// Container(
///   decoration: BoxDecoration(gradient: VersoAuthGradient.of(context)),
///   child: ...
/// )
/// ```
abstract final class VersoAuthGradient {
  static LinearGradient of(BuildContext context) {
    final palette = context.palette;

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        palette.accentSoft,
        palette.bg,
        palette.bg,
      ],
      stops: const [0.0, 0.4, 1.0],
    );
  }
}
