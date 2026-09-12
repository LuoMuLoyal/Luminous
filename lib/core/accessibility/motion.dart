import 'package:flutter/widgets.dart';

/// Whether the user has asked for reduced motion, from either source.
///
/// Two independent flags are checked on purpose:
///
/// * [MediaQueryData.disableAnimations] — the engine/SDK-level accessibility
///   flag (Android's "remove animations", and iOS "Reduce Motion" on the paths
///   that forward it) and the one the framework itself honours;
/// * [MediaQueryData.accessibleNavigation] — where `bootstrap.dart` maps this
///   app's own "reduce animations" setting (`accessibility.reduceAnimations`).
///
/// Framework animations already honour both by themselves: every
/// `AnimationController` with the default `AnimationBehavior.normal` compresses
/// its duration under `disableAnimations`, and implicit animations
/// (`AnimatedOpacity`, `AnimatedSize`, `AnimatedSwitcher`, `AnimatedContainer`)
/// plus the `animations` package transitions are built on those controllers.
///
/// This helper is for the animations that do **not** opt in by themselves:
///
/// * anything driven by `flutter_animate` (`Animate`, `FadeEffect`, a raw
///   `controller.repeat()`), and
/// * the skeleton shimmer, which is a hand-driven infinite `ShaderMask`.
///
/// Without an explicit check the reduce-motion setting silently does nothing for
/// those. See `docs/explanation/motion-hierarchy.md` §4 for the inventory.
bool prefersReducedMotion(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context) ||
    MediaQuery.accessibleNavigationOf(context);
