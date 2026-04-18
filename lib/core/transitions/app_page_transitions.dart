import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Centralized page transition factory for Verso.
///
/// Transitions live here at the routing layer — not inside individual screens —
/// so the same destination opened from two different places can have different
/// entry animations. Think iOS `UIModalPresentationStyle`: the navigation act
/// owns the animation, not the destination.
class AppPageTransitions {
  AppPageTransitions._();

  static const Duration _slide = Duration(milliseconds: 350);
  static const Duration _ceremonial = Duration(milliseconds: 500);
  static const Duration _fastReverse = Duration(milliseconds: 250);

  /// Pure opacity fade. Reserved for ceremonial one-shots (splash → home,
  /// reset-callback spinner).
  static CustomTransitionPage<T> fade<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: _ceremonial,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          ),
          child: child,
        );
      },
    );
  }

  /// Material 3 fade-through pattern: the outgoing page fades out while the
  /// incoming page fades in with a subtle 0.94 → 1.0 upscale. Use for sibling
  /// screens that share a peer relationship (auth flow, onboarding).
  static CustomTransitionPage<T> fadeThrough<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      reverseTransitionDuration: _fastReverse,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final enter = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final exit = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeInCubic,
        );
        return FadeTransition(
          // Outer fade drives "this page exiting because a new one pushed on top"
          opacity: Tween<double>(begin: 1, end: 0).animate(exit),
          child: FadeTransition(
            // Inner fade drives "this page entering"
            opacity: enter,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1).animate(enter),
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// Horizontal push: incoming slides in from the right edge while the outgoing
  /// page parallax-slides left by 25% and dims to 0.7 opacity. Use for forward
  /// detail navigation (Bible → book chapters).
  static CustomTransitionPage<T> slideFromRight<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: _slide,
      reverseTransitionDuration: _fastReverse,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final enter = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final exit = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeInOutCubic,
        );
        return SlideTransition(
          // Parallax: when another page pushes on top, this one drifts left
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(-0.25, 0),
          ).animate(exit),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0.7).animate(exit),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(enter),
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// Vertical sheet-style presentation: slides up from the bottom with a
  /// coupled fade-in. Use for modal-like overlays (profile, settings) that
  /// cover the root navigator.
  static CustomTransitionPage<T> slideFromBottom<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: _slide,
      reverseTransitionDuration: _fastReverse,
      transitionsBuilder: (_, animation, __, child) {
        final enter = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(enter),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(enter),
            child: child,
          ),
        );
      },
    );
  }
}
