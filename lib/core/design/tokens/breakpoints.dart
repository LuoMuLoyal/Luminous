/// Responsive layout breakpoints.
///
/// These are layout helpers, not visual design tokens. They define width
/// thresholds where the page structure (columns, sidebars, max content width)
/// changes; color, spacing, radius, and typography values should come from
/// the current Forui theme or the dedicated token files instead.
abstract final class Breakpoints {
  /// Very small phones (≤360px). Text may need extra truncation.
  static const double compact = 360;

  static const double mobile = 600;
  static const double tablet = 960;

  /// Small laptops / large tablets (960–1200). Uses a transitional
  /// "small tablet" layout — 2-column card grid rather than full desktop
  /// dual-pane.
  static const double smallDesktop = 1080;

  static const double desktop = 1200;
  static const double wide = 1400;

  /// Ultra-wide monitors (≥1920). Content may use 3 columns or wider
  /// max-width.
  static const double ultrawide = 1920;

  /// Fixed max-width for assistant panels and auth forms.
  static const double assistantContent = 560;
}
