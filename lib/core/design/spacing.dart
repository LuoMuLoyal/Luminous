/// Spacing token scale.
///
/// 12 levels mapped to the Forui design system's spacing values.
/// Semantic names ([xs] through [xl8]) are the primary naming — use them
/// for all padding, margins, gaps, and structural dimensions.
/// The [level1] (4px) through [level12] (128px) names are kept as
/// backward-compatible aliases.
abstract final class Spacing {
  /// 4px — extra small spacing. (= [level1])
  static const double xs = 4;

  /// 6px — small spacing. (= [level2])
  static const double sm = 6;

  /// 10px — medium spacing. (= [level3])
  static const double md = 10;

  /// 14px — large spacing. (= [level4])
  static const double lg = 14;

  /// 20px — extra large spacing. (= [level5])
  static const double xl = 20;

  /// 28px — 2× extra large spacing. (= [level6])
  static const double xl2 = 28;

  /// 36px — 3× extra large spacing. (= [level7])
  static const double xl3 = 36;

  /// 44px — 4× extra large spacing. (= [level8])
  static const double xl4 = 44;

  /// 56px — 5× extra large spacing. (= [level9])
  static const double xl5 = 56;

  /// 72px — 6× extra large spacing. (= [level10])
  static const double xl6 = 72;

  /// 96px — 7× extra large spacing. (= [level11])
  static const double xl7 = 96;

  /// 128px — 8× extra large spacing. (= [level12])
  static const double xl8 = 128;

  /// 4px — backward-compatible alias for [xs].
  static const double level1 = xs;

  /// 6px — backward-compatible alias for [sm].
  static const double level2 = sm;

  /// 10px — backward-compatible alias for [md].
  static const double level3 = md;

  /// 14px — backward-compatible alias for [lg].
  static const double level4 = lg;

  /// 20px — backward-compatible alias for [xl].
  static const double level5 = xl;

  /// 28px — backward-compatible alias for [xl2].
  static const double level6 = xl2;

  /// 36px — backward-compatible alias for [xl3].
  static const double level7 = xl3;

  /// 44px — backward-compatible alias for [xl4].
  static const double level8 = xl4;

  /// 56px — backward-compatible alias for [xl5].
  static const double level9 = xl5;

  /// 72px — backward-compatible alias for [xl6].
  static const double level10 = xl6;

  /// 96px — backward-compatible alias for [xl7].
  static const double level11 = xl7;

  /// 128px — backward-compatible alias for [xl8].
  static const double level12 = xl8;
}
