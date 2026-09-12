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
/// | [snappy]   | `easeOut`        | Tab switch, hover feedback             |
/// | [emphasized] | `easeInOutCubicEmphasized` | M3 容器/导航级双向过渡      |
/// | [emphasizedDecelerate] | `Cubic(0.05, 0.7, 0.1, 1)` | M3 元素进场(强调版) |
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

  /// Snappy one-directional animation — tab switch, hover feedback.
  ///
  /// `easeOut` decelerates quickly, feeling responsive.
  static const snappy = Curves.easeOut;

  /// M3 emphasized — container/navigation-level bidirectional transitions.
  ///
  /// Material 3's primary curve for in-screen container/shared-element
  /// transitions (`ThreePointCubic`, path C 0.05,0 0.133,0.06 0.167,0.4
  /// C 0.208,0.82 0.25,1 1,1).
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

  // -- In-widget animations (flutter_animate / explicit) --

  /// Sidebar slide animation.
  static const sidebarSlide = Duration(milliseconds: 200);

  /// Entrance duration for flutter_animate effects (`SlideEffect`).
  ///
  /// The paired `FadeEffect` was removed from the dashboard views: the
  /// route/branch transition and [pageStateSwitch] already fade their content
  /// in, and a second opacity ramp multiplied with them into a visible delay.
  static const widgetEntrance = Duration(milliseconds: 220);

  /// Expand/collapse AnimationController duration.
  static const widgetExpand = Duration(milliseconds: 250);

  /// Quick implicit animation (AnimatedRotation, AnimatedContainer).
  static const widgetQuick = Duration(milliseconds: 200);

  /// Standard implicit animation for larger containers.
  static const widgetStandard = Duration(milliseconds: 300);

  /// Shell tab fade-through transition (in). Long enough for the cross-fade
  /// between branches to read as a deliberate switch instead of a blink;
  /// bounded so `pumpAndSettle` converges.
  static const tabFadeThrough = Duration(milliseconds: 260);

  /// Shell tab fade-through transition (out). Matches [tabFadeThrough] so
  /// incoming and outgoing branches cross-fade symmetrically.
  static const tabFadeThroughOut = Duration(milliseconds: 200);

  /// Settings desktop master-detail pane switch (fade through).
  static const masterDetailSwitch = Duration(milliseconds: 220);

  /// Page state switch (skeleton → content → error …) fade-through.
  static const pageStateSwitch = Duration(milliseconds: 240);
}
