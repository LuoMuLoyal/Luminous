import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:forui/forui.dart';
import 'package:luminous/core/design/color/palette.dart';
import 'package:luminous/core/design/color/theme_extension.dart';
import 'package:luminous/core/design/layout/surface.dart';
import 'package:luminous/core/design/tokens/elevation.dart';
import 'package:luminous/core/design/tokens/spacing.dart';
import 'package:material_ui/material_ui.dart';

const AppThemeFamily appDefaultThemeFamily = AppThemeFamily.blue;

enum AppThemeFamily {
  blue('blue'),
  green('green'),
  neutral('neutral'),
  orange('orange'),
  red('red'),
  rose('rose'),
  slate('slate'),
  violet('violet'),
  yellow('yellow'),
  zinc('zinc');

  const AppThemeFamily(this.storageValue);

  final String storageValue;

  static AppThemeFamily fromStorage(String? value) {
    for (final family in AppThemeFamily.values) {
      if (family.storageValue == value) {
        return family;
      }
    }
    return appDefaultThemeFamily;
  }
}

/// Returns the base [FThemeData] for a given family and brightness, before
/// semantic color extensions are injected.
///
/// Forui 0.24.0 removed all predefined color schemes except neutral. Non-neutral
/// families are emulated by overriding [FColors.primary] / [FColors.primaryForeground]
/// on the neutral base, preserving the color variety the app has always offered.
///
/// ## Compact baseline
///
/// The theme deliberately uses Forui's **desktop** (compact) size baseline
/// rather than its touch variant. The touch baseline inflates every dimension
/// — field heights 36→44, list items 30→44, and the body typeface by one step
/// (12→14, 14→16, 16→18) — which made Luminous visibly larger than peer apps on
/// real phones.
///
/// **Typography is compacted together with the geometry.** An earlier revision
/// kept a touch [FTypography] while switching components to `touch: false`, on
/// the theory that text should stay at its "readable" size. That reinstated one
/// of the two inflation axes: body text stayed one step larger than desktop
/// *and* kept the looser touch line-height (`xs` 1.25 vs 1.0, `sm` 1.5 vs 1.25),
/// which reads as noticeably bigger, airier copy. The mixed baseline was the
/// oversight; both axes now come from the desktop typeface.
FThemeData _baseThemeData(AppThemeFamily family, Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final base = isDark
      ? FTheme.neutral.dark.desktop
      : FTheme.neutral.light.desktop;
  final override = _familyColorOverride(family, isDark);

  if (override == null) return base;

  return FThemeData(
    touch: false,
    debugLabel: '${family.storageValue} ${isDark ? 'Dark' : 'Light'} Compact',
    colors: base.colors.copyWith(
      primary: override.primary,
      primaryForeground: override.primaryForeground,
    ),
  );
}

/// Primary color override for each non-neutral family.
///
/// Color values are taken from the Forui 0.23.x predefined schemes that were
/// removed in 0.24.0. Returns `null` for neutral (no override needed).
class _ColorOverride {
  const _ColorOverride(this.primary, this.primaryForeground);
  final Color primary;
  final Color primaryForeground;
}

_ColorOverride? _familyColorOverride(AppThemeFamily family, bool isDark) {
  return switch (family) {
    AppThemeFamily.neutral => null,
    AppThemeFamily.blue => const _ColorOverride(
      Color(0xFF1447E6),
      Color(0xFFEFF6FF),
    ),
    AppThemeFamily.green => const _ColorOverride(
      Color(0xFF5EA500),
      Color(0xFFF7FEE7),
    ),
    AppThemeFamily.orange => _ColorOverride(
      isDark ? const Color(0xFFFF6900) : const Color(0xFFF54A00),
      const Color(0xFFFFF7ED),
    ),
    AppThemeFamily.red => _ColorOverride(
      isDark ? const Color(0xFFFB2C36) : const Color(0xFFE7000B),
      const Color(0xFFFEF2F2),
    ),
    AppThemeFamily.rose => _ColorOverride(
      isDark ? const Color(0xFFFF2056) : const Color(0xFFEC003F),
      const Color(0xFFFFF1F2),
    ),
    AppThemeFamily.slate => _ColorOverride(
      isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172B),
      const Color(0xFFF8FAFC),
    ),
    AppThemeFamily.violet => _ColorOverride(
      isDark ? const Color(0xFF8E51FF) : const Color(0xFF7F22FE),
      const Color(0xFFF5F3FF),
    ),
    AppThemeFamily.yellow => _ColorOverride(
      isDark ? const Color(0xFFEFB100) : const Color(0xFFFCC800),
      const Color(0xFF733E0A),
    ),
    AppThemeFamily.zinc => _ColorOverride(
      isDark ? const Color(0xFFE4E4E7) : const Color(0xFF18181B),
      const Color(0xFFFAFAFA),
    ),
  };
}

/// Creates the [FThemeData] for the app, with [SemanticColors] injected as an
/// [FColors] extension.
///
/// Preset Forui themes derive all widget styles from [FColors] via `.inherit()`,
/// so constructing a new [FThemeData] with modified colors is equivalent to the
/// preset — no custom styles are lost.
///
/// ## Compact baseline
///
/// `touch: false` selects Forui's desktop (compact) geometry — field heights,
/// list-item heights, paddings — instead of the inflated touch variant. The
/// touch baseline made every component noticeably larger than peer apps.
///
/// Typography is passed **explicitly** as the touch typeface, because
/// [FThemeData] would otherwise derive it from `touch: false` and shrink all
/// text by one step (body.sm 16→14). Components stay compact, text stays
/// readable.
///
/// Whether the theme is being built for a touch-first platform.
///
/// Drives leading only (see [_flattenLineHeight]): phones read one-line labels
/// and want flat leading for density; desktop reads paragraphs and wants
/// Forui's leading back. `kIsWeb` is treated as touch-compatible so the web
/// build keeps the dense baseline it had before — the web target is the phone
/// browser, and desktop web is served by a separate Next.js client (ADR-0008).
bool get _isTouchPlatform =>
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

/// Sets line height per platform — 1.0 on touch, readable leading on desktop.
///
/// Forui ships generous leading per step (`sm` 1.25, `md` 1.5, `lg` 1.75), so a
/// 16px line occupies a 24px box. That leading is the single largest source of
/// vertical bulk in the app: it inflates every card, list row and banner
/// without improving legibility at these sizes. Collapsing it to 1.0 makes each
/// line exactly its font size, leaving vertical rhythm to explicit spacing.
///
/// **That reasoning holds for phone density and stops holding on desktop.**
/// A 16rem sidebar and a 1400px content column are read the way a document is
/// read, and body copy at height 1.0 sets solid — descenders nearly touch
/// ascenders, paragraphs lose their line rhythm, and multi-line Chinese
/// characters (which have no ascender/descender slack) fuse into a block.
/// So desktop keeps Forui's leading for *body* text and only tightens display
/// sizes, where 1.0 is still legible because those lines are short.
FTypography _flattenLineHeight(FTypography typography, {required bool touch}) {
  /// `display` sizes are short and structural (page titles, big numbers);
  /// flattening them is safe on both platforms.
  TextStyle display(TextStyle style) => style.copyWith(height: 1.0);

  /// Body sizes are the ones people actually read. On touch they are
  /// single-line labels, so flat leading buys density; on desktop they form
  /// paragraphs, so they keep Forui's leading.
  TextStyle body(TextStyle style) =>
      touch ? style.copyWith(height: 1.0) : style;

  FTypeface text(FTypeface t) => t.copyWith(
    xs3: body(t.xs3),
    xs2: body(t.xs2),
    xs: body(t.xs),
    sm: body(t.sm),
    md: body(t.md),
    lg: body(t.lg),
    xl: body(t.xl),
    xl2: body(t.xl2),
    xl3: body(t.xl3),
    xl4: body(t.xl4),
  );

  FTypeface headings(FTypeface t) => t.copyWith(
    xs3: display(t.xs3),
    xs2: display(t.xs2),
    xs: display(t.xs),
    sm: display(t.sm),
    md: display(t.md),
    lg: display(t.lg),
    xl: display(t.xl),
    xl2: display(t.xl2),
    xl3: display(t.xl3),
    xl4: display(t.xl4),
  );

  return typography.copyWith(
    display: headings(typography.display),
    body: text(typography.body),
  );
}

/// The one place where the two baselines differ in *behaviour* rather than
/// size is the toast position (top-center on touch, bottom-end otherwise).
/// Since this app only ever runs on phones, the toaster is pinned back to
/// top-center so `AppToast` stays in the thumb zone.
FThemeData appThemeData(AppThemeFamily family, Brightness brightness) {
  final base = _baseThemeData(family, brightness);
  final colors = base.colors.copyWith(
    extensions: [_semanticColorsFor(brightness, base.colors)],
  );

  // Typography follows the same compact (desktop) baseline as the component
  // geometry. Deriving it from `touch: false` is what `FThemeData` does by
  // default; passing it explicitly keeps intent visible.
  //
  // Leading is platform-dependent — see [_flattenLineHeight]. `touch: false`
  // here is the *geometry* baseline (compact control sizes), not a statement
  // that this theme is running on a desktop: the same theme serves phone and
  // desktop. The actual platform comes from `_isTouchPlatform`.
  final typography = _flattenLineHeight(
    FTypography.inherit(colors: colors, touch: false),
    touch: _isTouchPlatform,
  );

  final scaffoldBackgroundColor = SurfaceTokens.scaffoldBackground(colors);
  final subtleBorder = SurfaceTokens.containerBorder(colors);

  return FThemeData(
    touch: false,
    debugLabel: base.debugLabel,
    colors: colors,
    typography: typography,
    scaffoldStyle: FScaffoldStyle.inherit(colors: colors, style: base.style)
        .copyWith(
          backgroundColor: scaffoldBackgroundColor,
          // 侧边栏比页面底色再深一档：桌面端 nav 与内容区同色时，
          // 整屏层次只剩 1px 边框在撑。见 SurfaceTokens。
          sidebarBackgroundColor: SurfaceTokens.sidebarBackground(colors),
        ),
    // Keep toasts at the top of the screen, matching the touch baseline this
    // theme no longer selects. See the doc comment above.
    toasterStyle: base.toasterStyle.copyWith(
      toastAlignment: FToastAlignment.topCenter,
    ),
    // 侧边栏分组：分组标签是导航里唯一的层级信号。
    //
    // 桌面端侧边栏有 16rem 宽，五个 tab 平铺时只有一个层级——分组标签
    // 让小标题（小字号、弱色、字重中等）与条目形成对比，导航才读得出结构。
    // 标签是分区提示，不该和条目抢注意力，所以用 muted 前景色而非正文色。
    sidebarStyle: base.sidebarStyle.copyWith(
      groupStyle: base.sidebarStyle.groupStyle.copyWith(
        labelStyle: TextStyleDelta.delta(
          color: colors.mutedForeground,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
        headerPadding: const EdgeInsetsGeometryDelta.value(
          EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
        ),
        childrenSpacing: 2,
      ),
    ),
    // FCard: white background + subtle 1px border, matching FTileGroup.
    cardStyle:
        FCardStyle.inherit(
          colors: colors,
          typography: typography,
          style: base.style,
          touch: false,
        ).copyWith(
          decoration: DecorationDelta.value(
            ShapeDecoration(
              color: colors.card,
              shape: RoundedSuperellipseBorder(
                side: BorderSide(
                  color: subtleBorder,
                  width: base.style.borderWidth,
                ),
                borderRadius: base.style.borderRadius.lg,
              ),
            ),
          ),
        ),
    // FTileGroup: white background + subtle 1px border + lighter divider,
    // matching FCard for visual consistency.
    tileGroupStyle:
        FTileGroupStyle.inherit(
          colors: colors,
          typography: typography,
          style: base.style,
          hapticFeedback: base.hapticFeedback,
        ).copyWith(
          decoration: DecorationDelta.value(
            ShapeDecoration(
              color: colors.card,
              shape: RoundedSuperellipseBorder(
                side: BorderSide(
                  color: subtleBorder,
                  width: base.style.borderWidth,
                ),
                borderRadius: base.style.borderRadius.md,
              ),
            ),
          ),
          dividerColor: FVariants.all(subtleBorder),
        ),
  );
}

/// Builds the [SemanticColors] extension for a given brightness.
///
/// - [SemanticColor.primary] and [SemanticColor.destructive] derive from the
///   theme family's [FColors].
/// - [SemanticColor.success], [SemanticColor.warning], and [SemanticColor.info]
///   are fixed across all families — a medical-health requirement.
SemanticColors _semanticColorsFor(Brightness brightness, FColors fColors) {
  final isDark = brightness == Brightness.dark;

  return SemanticColors(
    primary: _paletteFromFColor(
      fColors.primary,
      fColors.primaryForeground,
      isDark,
    ),
    destructive: _paletteFromFColor(
      fColors.destructive,
      fColors.destructiveForeground,
      isDark,
    ),
    neutral: SemanticColorPalette(
      solid: fColors.mutedForeground,
      foreground: fColors.background,
      muted: fColors.secondary,
      subtle: fColors.secondary,
      border: fColors.border,
      shimmerBase: fColors.mutedForeground.withValues(
        alpha: isDark ? 0.06 : 0.03,
      ),
      disabled: fColors.mutedForeground.withValues(alpha: 0.5),
      borderStrong: fColors.mutedForeground.withValues(
        alpha: isDark ? 0.40 : 0.30,
      ),
      fill: fColors.mutedForeground.withValues(alpha: 0.55),
      fillStrong: fColors.mutedForeground.withValues(alpha: 0.80),
    ),
    success: _fixedPalette(
      solid: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
      foreground: isDark ? const Color(0xFF052E16) : const Color(0xFFFFFFFF),
      isDark: isDark,
    ),
    warning: _fixedPalette(
      solid: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
      foreground: isDark ? const Color(0xFF451A03) : const Color(0xFFFFFFFF),
      isDark: isDark,
    ),
    info: _fixedPalette(
      solid: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
      foreground: isDark ? const Color(0xFF0C1E3E) : const Color(0xFFFFFFFF),
      isDark: isDark,
    ),
  );
}

/// Derives a [SemanticColorPalette] from a Forui color pair, with dark-mode
/// alpha compensation baked in.
SemanticColorPalette _paletteFromFColor(
  Color solid,
  Color foreground,
  bool isDark,
) => _fixedPalette(solid: solid, foreground: foreground, isDark: isDark);

/// Creates a [SemanticColorPalette] with standardized alpha tones.
///
/// Alpha scale (light → dark) with WCAG 2.1 contrast analysis:
///
/// | Tone    | Light | Dark  | WCAG concern | Analysis |
/// |---------|-------|-------|--------------|----------|
/// | subtle  | 0.05  | 0.10  | Background distinguishability (non-text) | Dark bumped from 0.08→0.10 so empty-state tints are visible on #1C1B1F-class backgrounds. Non-text, so WCAG text contrast N/A; relies on visual distinguishability. |
/// | muted   | 0.10  | 0.18  | Text-on-chip contrast (solid on muted) | In dark mode, solid (#4ADE80-class) on muted (≈#335C3D) yields >7:1 — passes AAA. Light mode similarly passes. |
/// | border  | 0.20  | 0.35  | Semantic border visibility (non-text) | 0.35 in dark creates clearly visible colored borders on dark backgrounds. 0.20 in light is sufficient on light backgrounds. |
/// | shimmerBase| 0.03 | 0.06  | Skeleton/shimmer base | Derived from muted × 0.32. Very faint so shimmer animation is subtle. |
/// | disabled | 0.50  | 0.50  | Disabled foreground | Uniform across modes — disabled state should be clearly distinguishable but muted. |
/// | borderStrong | 0.30 | 0.40 | Emphasized borders/shadows | Higher than border for drag, destructive, shadow. |
/// | fill | 0.55 | 0.55 | Semi-transparent icons/circles | Uniform — decorative, non-text. |
/// | fillStrong | 0.80 | 0.80 | Buttons/sparklines/overlays/text | High opacity fill, covers 0.68–0.92 range. |
///
/// The `foreground` color is used for text/icons placed on top of `solid`
/// (e.g. white on green). Those pairs are chosen by the Forui theme system
/// and always exceed 4.5:1.
SemanticColorPalette _fixedPalette({
  required Color solid,
  required Color foreground,
  required bool isDark,
}) => SemanticColorPalette(
  solid: solid,
  foreground: foreground,
  subtle: solid.withValues(alpha: isDark ? 0.10 : 0.05),
  muted: solid.withValues(alpha: isDark ? 0.18 : 0.10),
  border: solid.withValues(alpha: isDark ? 0.35 : 0.20),
  // shimmerBase ≈ muted × 0.32, pre-computed to avoid runtime alpha arithmetic.
  shimmerBase: solid.withValues(alpha: isDark ? 0.06 : 0.03),
  disabled: solid.withValues(alpha: 0.5),
  borderStrong: solid.withValues(alpha: isDark ? 0.40 : 0.30),
  fill: solid.withValues(alpha: 0.55),
  fillStrong: solid.withValues(alpha: 0.80),
);

ThemeData foruiMaterialTheme(FThemeData theme) {
  final material = theme.toApproximateMaterialTheme();
  // Use the scaffold style's background color (light grey) instead of
  // colors.background (pure white) so Material Scaffold and FScaffold
  // stay in sync.
  final scaffoldBg = theme.scaffoldStyle.backgroundColor;
  return material.copyWith(
    scaffoldBackgroundColor: scaffoldBg,
    canvasColor: scaffoldBg,
    // Brand-wide page transition fallback: every platform uses the M3
    // shared-axis horizontal transition instead of the mixed platform defaults
    // (Windows/Linux Zoom, iOS/macOS Cupertino, Android FadeForwards).
    //
    // DORMANT TODAY — nothing consumes this map. Every route in the app is a
    // `CustomTransitionPage` built by `lib/app/router_helpers.dart`
    // (`slidePage` / `fadePage` / `sidePanelPage`) or, for tab roots, a
    // `NoTransitionPage`; none of them consult `PageTransitionsTheme`. This is
    // purely a guard so a future route that returns a plain `MaterialPage`
    // (which is what `builder:`-only routes get) inherits the shared-axis
    // motion instead of silently falling back to a platform default. Delete it
    // if the per-route helpers are ever removed.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.horizontal,
        ),
        TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.horizontal,
        ),
        TargetPlatform.macOS: SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.horizontal,
        ),
        TargetPlatform.windows: SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.horizontal,
        ),
        TargetPlatform.linux: SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.horizontal,
        ),
        TargetPlatform.fuchsia: SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.horizontal,
        ),
      },
    ),
    cardColor: theme.colors.card,
    dividerColor: theme.colors.border,
    shadowColor: ElevationTokens.shadowColor(theme.colors),
    cardTheme: material.cardTheme.copyWith(
      shape: RoundedSuperellipseBorder(
        side: BorderSide(
          color: SurfaceTokens.containerBorder(theme.colors),
          width: theme.style.borderWidth,
        ),
        borderRadius: theme.style.borderRadius.md,
      ),
    ),
  );
}
