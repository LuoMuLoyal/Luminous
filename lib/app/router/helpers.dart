import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';

CustomTransitionPage<T> fadePage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: DurationTokens.authPageTransitionIn,
    reverseTransitionDuration: DurationTokens.authPageTransitionOut,
  );
}

/// Fade transition helper for shell tab routes.
///
/// Uses the fast [DurationTokens.tabPageTransitionIn] / [tabPageTransitionOut]
/// tokens so tab switching feels instantaneous.
CustomTransitionPage<T> tabFadePage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: DurationTokens.tabPageTransitionIn,
    reverseTransitionDuration: DurationTokens.tabPageTransitionOut,
  );
}

CustomTransitionPage<T> slidePage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.15, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(animation),
            child: child,
          ),
        ),
    transitionDuration: DurationTokens.crudPageTransitionIn,
    reverseTransitionDuration: DurationTokens.crudPageTransitionOut,
  );
}

/// Desktop side-panel transition helper.
///
/// On desktop, CRUD pages (record create/edit, medicine reminder edit, etc.)
/// slide in from the right edge as a panel constrained to [maxWidth] (default
/// 560), keeping the shell sidebar visible underneath a semi-transparent
/// barrier. Tapping the barrier dismisses the panel.
///
/// The [isDesktop] flag is resolved by the caller via
/// `MediaQuery.sizeOf(context).width >= Breakpoints.desktop`.
CustomTransitionPage<T> sidePanelPage<T>({
  required LocalKey key,
  required Widget child,
  required bool isDesktop,
  double maxWidth = 560,
}) {
  if (!isDesktop) {
    return slidePage<T>(key: key, child: child);
  }

  return CustomTransitionPage<T>(
    key: key,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    barrierDismissible: true,
    opaque: false,
    child: Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Material(color: const Color(0x00000000), child: child),
      ),
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(animation),
          child: child,
        ),
      );
    },
    transitionDuration: DurationTokens.crudPageTransitionIn,
    reverseTransitionDuration: DurationTokens.crudPageTransitionOut,
  );
}
