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
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // 本页作为"新页":从右 15% 滑入(进入)/ 向右滑出(返回),同时淡入淡出。
      final entering = SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.15, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: MotionTokens.entrance)).animate(animation),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(animation),
          child: child,
        ),
      );
      // 本页作为"被覆盖的旧页"(栈下有页压上来时):向左让位约 12%,
      // 形成 push/pop 的方向感;pop 时随 secondaryAnimation 复位。
      // 本页作为新页时 secondaryAnimation 静止在 0,此层无位移。
      return SlideTransition(
        position: Tween<Offset>(begin: Offset.zero, end: const Offset(-0.12, 0))
            .chain(CurveTween(curve: MotionTokens.standard))
            .animate(secondaryAnimation),
        child: entering,
      );
    },
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
