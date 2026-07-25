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
}

/// Centralized animation duration tokens.
///
/// All animation durations — route transitions and in-widget effects —
/// live here so they can be audited and tuned in one place.
abstract final class DurationTokens {
  // -- Route transitions (GoRouter page builders) --

  /// Auth page route transition (fade in).
  static const authPageTransitionIn = Duration(milliseconds: 400);

  /// Auth page route transition (fade out).
  static const authPageTransitionOut = Duration(milliseconds: 280);

  /// Shell tab route transition (fade in). Fast to keep tab
  /// switching feeling instantaneous.
  static const tabPageTransitionIn = Duration(milliseconds: 150);

  /// Shell tab route transition (fade out). Zero so outgoing
  /// tab content is removed immediately without flicker.
  static const tabPageTransitionOut = Duration.zero;

  /// CRUD page route transition (slide in).
  static const crudPageTransitionIn = Duration(milliseconds: 220);

  /// CRUD page route transition (slide out).
  static const crudPageTransitionOut = Duration(milliseconds: 150);

  // -- In-widget animations (flutter_animate / explicit) --

  /// Auth form content fade-in (flutter_animate).
  static const authContentFadeIn = Duration(milliseconds: 180);

  /// Sidebar slide animation.
  static const sidebarSlide = Duration(milliseconds: 200);

  /// Fade-in for flutter_animate effects (FadeEffect, SlideEffect).
  static const widgetFadeIn = Duration(milliseconds: 220);

  /// Expand/collapse AnimationController duration.
  static const widgetExpand = Duration(milliseconds: 250);

  /// Quick implicit animation (AnimatedRotation, AnimatedContainer).
  static const widgetQuick = Duration(milliseconds: 200);

  /// Standard implicit animation for larger containers.
  static const widgetStandard = Duration(milliseconds: 300);
}
