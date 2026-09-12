import 'package:flutter/animation.dart';

/// Motion token system — curves and durations unified.
///
/// All animation curves and durations live here so they can be audited and
/// tuned in one place. [MotionTokens] holds curve constants; [DurationTokens]
/// (migrated from `durations.dart`) holds duration constants.
///
/// ## Curves
///
/// | Token      | Curve            | Use case                              |
/// |------------|------------------|---------------------------------------|
/// | [entrance] | `easeOutCubic`   | Route slide-in, panel expand          |
/// | [exit]     | `easeInCubic`    | Route slide-out, panel collapse        |
/// | [standard] | `easeInOut`      | Expand/collapse, bidirectional         |
/// | [snappy]   | `easeOut`        | Cross-fade, tab switch, hover feedback |
/// | [emphasized] | `easeInOutCubicEmphasized` | M3 容器/导航级单边进出,勿用于交叉淡化 |
/// | [emphasizedDecelerate] | `Cubic(0.05, 0.7, 0.1, 1)` | M3 元素进场(强调版) |
///
/// Pick [snappy] for anything where **both** sides of a transition are on
/// screen at once (cross-fades): the M3 emphasized curves front-load almost
/// their whole range, so a cross-fade driven by them dips in the middle with
/// both sides washed out. Emphasized is for a single element entering or
/// leaving.
abstract final class MotionTokens {
  /// Entrance animation — route slide-in, panel expand.
  ///
  /// `easeOutCubic` starts fast and decelerates, giving a "settling" feel.
  static const entrance = Curves.easeOutCubic;

  /// Exit animation — route slide-out, panel collapse.
  ///
  /// `easeInCubic` starts slow and accelerates, giving a "leaving" feel.
  static const exit = Curves.easeInCubic;

  /// Standard bidirectional animation — expand/collapse, toggle.
  ///
  /// `easeInOut` accelerates then decelerates, symmetric.
  static const standard = Curves.easeInOut;

  /// Snappy one-directional animation — cross-fades, tab switch, hover.
  ///
  /// `easeOut` decelerates quickly, feeling responsive. Also the right curve
  /// for a cross-fade, where both sides are visible at once: it fills the
  /// middle of the ramp instead of leaving it washed out. See the class doc.
  static const snappy = Curves.easeOut;

  /// M3 emphasized — a single container/navigation element entering or
  /// leaving.
  ///
  /// Material 3's primary curve for in-screen container/shared-element
  /// transitions (`ThreePointCubic`, path C 0.05,0 0.133,0.06 0.167,0.4
  /// C 0.208,0.82 0.25,1 1,1).
  ///
  /// Front-loads its range: it reaches 1.0 at t/T≈0.25, so the remaining three
  /// quarters of the duration are a near-invisible settle. Intended for one
  /// element moving on its own — for a cross-fade use [snappy].
  static const emphasized = Curves.easeInOutCubicEmphasized;

  /// M3 emphasizedDecelerate — emphasized element entrance.
  ///
  /// `cubic-bezier(0.05, 0.7, 0.1, 1)`; new-page entrance in navigation
  /// transitions (M3 easing spec).
  static const emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1);
}

/// Centralized animation duration tokens.
///
/// All animation durations — route transitions and in-widget effects —
/// live here so they can be audited and tuned in one place.
abstract final class DurationTokens {
  // -- Route transitions (GoRouter page builders) --

  /// Auth page route transition (fade in). Short enough that the page shows up
  /// promptly, long enough that the cross-fade from the outgoing page reads as
  /// a transition rather than a cut.
  static const authPageTransitionIn = Duration(milliseconds: 300);

  /// Auth page route transition (fade out). Kept close to the entry duration so
  /// leaving the auth flow is as visible as entering it.
  static const authPageTransitionOut = Duration(milliseconds: 240);

  /// CRUD page route transition (slide in).
  static const crudPageTransitionIn = Duration(milliseconds: 220);

  /// CRUD page route transition (slide out).
  static const crudPageTransitionOut = Duration(milliseconds: 150);

  // -- In-widget animations (explicit / implicit) --

  /// Sidebar slide animation.
  static const sidebarSlide = Duration(milliseconds: 200);

  /// Expand/collapse AnimationController duration.
  static const widgetExpand = Duration(milliseconds: 250);

  /// Quick implicit animation (AnimatedRotation, AnimatedContainer).
  static const widgetQuick = Duration(milliseconds: 200);

  /// Standard implicit animation for larger containers.
  static const widgetStandard = Duration(milliseconds: 300);

  /// Shell tab cross-fade (incoming branch). Only
  /// `ShellTabBranchContainer` consumes it — tab root routes are
  /// `NoTransitionPage`, so this is the sole duration of a tab switch.
  ///
  /// Deliberately longer than the outgoing half so the new branch finishes
  /// settling after the old one is gone, and bounded so `pumpAndSettle`
  /// converges.
  static const tabFadeThrough = Duration(milliseconds: 260);

  /// Shell tab cross-fade (outgoing branch). Shorter than
  /// [tabFadeThrough] on purpose — the outgoing branch should be clear of the
  /// screen before the incoming one finishes, so the two are *not*
  /// symmetrical.
  static const tabFadeThroughOut = Duration(milliseconds: 200);

  /// Settings desktop master-detail pane switch: fade the incoming pane and
  /// resize the scroll extent to its height in one motion.
  static const masterDetailSwitch = Duration(milliseconds: 220);

  /// Curve for [masterDetailSwitch]. `easeInOut` because the switch animates
  /// both a faked fade and the container height — a single bidirectional move.
  static const masterDetailSwitchCurve = Curves.easeInOut;

  /// Page state switch (skeleton → content → error …) fade-through.
  static const pageStateSwitch = Duration(milliseconds: 240);
}
