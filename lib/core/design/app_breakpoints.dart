/// Responsive layout breakpoints.
///
/// These are layout helpers, not visual design tokens. They define width
/// thresholds where the page structure (columns, sidebars, max content width)
/// changes; color, spacing, radius, and typography values should come from
/// the current Forui theme or the dedicated token files instead.
abstract final class AppBreakpoints {
  static const double mobile = 600;
  static const double tablet = 960;
  static const double desktop = 1200;
  static const double wide = 1400;
}
