/// Centralized animation duration tokens.
///
/// All animation durations — route transitions and in-widget effects —
/// live here so they can be audited and tuned in one place.
class AppAnimationDurations {
  const AppAnimationDurations._();

  // -- Route transitions (GoRouter page builders) --

  /// Auth page route transition (fade in).
  static const authPageTransitionIn = Duration(milliseconds: 400);

  /// Auth page route transition (fade out).
  static const authPageTransitionOut = Duration(milliseconds: 280);

  /// CRUD page route transition (slide in).
  static const crudPageTransitionIn = Duration(milliseconds: 220);

  /// CRUD page route transition (slide out).
  static const crudPageTransitionOut = Duration(milliseconds: 150);

  // -- In-widget animations (flutter_animate / explicit) --

  /// Auth form content fade-in (flutter_animate).
  static const authContentFadeIn = Duration(milliseconds: 180);

  /// Sidebar slide animation.
  static const sidebarSlide = Duration(milliseconds: 200);
}
