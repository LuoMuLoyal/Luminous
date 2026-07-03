/// Project radius vocabulary mapped to Forui’s `FBorderRadius` scale.
///
/// Forui exposes nine radii: `xs2` (4), `xs` (6), `sm` (8), `md` (10),
/// `lg` (14), `xl` (18), `xl2` (22), `xl3` (26), and `pill` (100).
/// `level1` through `level9` map directly to those nine values in order,
/// replacing the legacy arbitrary numbers with Forui’s scale. `level0` is
/// reserved for "no radius", and `levelFull` is a synonym for `level9` (pill).
abstract final class AppRadiusTokens {
  /// 0px — no radius.
  static const double level0 = 0;

  /// 4px — maps to Forui `xs2`.
  static const double level1 = 4;

  /// 6px — maps to Forui `xs`.
  static const double level2 = 6;

  /// 8px — maps to Forui `sm`.
  static const double level3 = 8;

  /// 10px — maps to Forui `md`.
  static const double level4 = 10;

  /// 14px — maps to Forui `lg`.
  static const double level5 = 14;

  /// 18px — maps to Forui `xl`.
  static const double level6 = 18;

  /// 22px — maps to Forui `xl2`.
  static const double level7 = 22;

  /// 26px — maps to Forui `xl3`.
  static const double level8 = 26;

  /// 100px — maps to Forui `pill`.
  static const double level9 = 100;

  /// 100px — synonym for `level9` / Forui `pill`.
  static const double levelFull = 100;
}
