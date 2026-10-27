// Design system barrel — export all design tokens and helpers.
//
// Token files are grouped into subdirectories:
//   color/semantic_color.dart    — SemanticColor enum + resolution extension
//   color/palette.dart           — per-color 10-tone value object (SemanticColorPalette)
//   color/theme_extension.dart   — SemanticColors ThemeExtension for Forui
//   color/high_contrast.dart     — high-contrast accessibility color constants
//   tokens/breakpoints.dart      — responsive breakpoints
//   tokens/elevation.dart        — elevation/shadow tokens (ElevationTokens)
//   tokens/icon_size.dart        — icon size tokens (IconSizeTokens)
//   tokens/markdown_style.dart   — MarkdownStyle factories (legal / ai)
//   tokens/motion.dart           — motion tokens (MotionTokens, DurationTokens)
//   tokens/semantic_icons.dart   — semantic icon registry (SemanticIcons)
//   tokens/spacing.dart          — spacing tokens (Spacing)
//   layout/gradient.dart         — gradient tokens (GradientTokens)
//   layout/layout_scale.dart     — layout scale helpers
//   layout/responsive_sizing.dart — responsive sizing utilities
//   layout/surface.dart          — scaffold background / container border tokens
//
// `tokens/lucide_icon_bridge.dart` is generated (scripts/generate_lucide_bridge.dart)
// and intentionally NOT exported here — import it directly where needed.

export 'color/high_contrast.dart';
export 'color/palette.dart';
export 'color/semantic_color.dart';
export 'color/theme_extension.dart';
export 'layout/gradient.dart';
export 'layout/layout_scale.dart';
export 'layout/responsive_sizing.dart';
export 'layout/surface.dart';
export 'tokens/breakpoints.dart';
export 'tokens/elevation.dart';
export 'tokens/icon_size.dart';
export 'tokens/markdown_style.dart';
export 'tokens/motion.dart';
export 'tokens/semantic_icons.dart';
export 'tokens/spacing.dart';
