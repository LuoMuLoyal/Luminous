import 'package:animations/animations.dart';
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

/// Fade-through transition helper for shell tab routes.
///
/// Uses the official Material [FadeThroughTransition] — the outgoing page
/// fades out over the first 30% of the duration, then the incoming page fades
/// in and scales up (0.92 → 1.0) — which is the M3 pattern for peer content
/// without a spatial relationship. This matches the cross-branch fade-through
/// performed by `ShellTabBranchContainer` when switching tabs.
///
/// [DurationTokens.tabFadeThrough] keeps the transition bounded so
/// `pumpAndSettle` converges; the reverse duration stays zero so rapid tab
/// switching never plays a reverse animation.
CustomTransitionPage<T> tabFadePage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        ),
    transitionDuration: DurationTokens.tabFadeThrough,
    reverseTransitionDuration: Duration.zero,
  );
}

/// Drill-down transition helper for full-screen sub-pages.
///
/// Uses the official Material [SharedAxisTransition] on the horizontal axis —
/// the M3 pattern for elements with a spatial/navigational relationship (e.g.
/// a list opening a detail page). The incoming page slides in ~30 logical
/// pixels and fades in; the page underneath slides out ~30 pixels and fades
/// out; popping runs the whole thing in reverse.
///
/// Replaces the previous hand-rolled slide + `secondaryAnimation` pair: the
/// dual enter/exit behaviour is now the package's `DualTransitionBuilder`
/// implementation, so push and pop share one M3 curve set. Durations still come
/// from [DurationTokens.crudPageTransitionIn] / [crudPageTransitionOut] so the
/// transition stays bounded and `pumpAndSettle` converges.
CustomTransitionPage<T> slidePage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
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
    // 侧面板遮罩：固定黑色压暗（系统级 scrim，与主题无关）
    barrierColor: Colors.black.withValues(alpha: 0.4),
    barrierDismissible: true,
    opaque: false,
    child: Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Material(color: Colors.transparent, child: child),
      ),
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: MotionTokens.entrance)).animate(animation),
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
