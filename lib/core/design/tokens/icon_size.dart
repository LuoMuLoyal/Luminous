/// Icon size token scale.
///
/// 8 levels covering all icon sizes used in the app. Semantic names ([xs]
/// through [xl4]) are the primary naming — use them for all `Icon(size:)`
/// and `iconSize:` values. The [level1] (12px) through [level8] (64px)
/// names are kept as backward-compatible aliases.
///
/// | Name  | px  | Use case                          |
/// |-------|-----|-----------------------------------|
/// | [xs]  | 12  | Status dot, tiny indicator        |
/// | [sm]  | 16  | Inline icon, chevron, small action |
/// | [md]  | 20  | Tile prefix, button icon, default  |
/// | [lg]  | 24  | Section header, empty-state icon   |
/// | [xl]  | 28  | Suggestion card icon, medium hero  |
/// | [xl2] | 32  | Avatar, hero icon, large empty-state |
/// | [xl3] | 48  | Category icon, large hero           |
/// | [xl4] | 64  | Account avatar, extra large         |
abstract final class IconSizeTokens {
  /// 12px — status dot, tiny indicator.
  static const double xs = 12;

  /// 16px — inline icon, chevron, small action.
  static const double sm = 16;

  /// 20px — tile prefix, button icon, default size.
  static const double md = 20;

  /// 24px — section header, empty-state icon.
  static const double lg = 24;

  /// 28px — suggestion card icon, medium hero.
  static const double xl = 28;

  /// 32px — avatar, hero icon, large empty-state.
  static const double xl2 = 32;

  /// 48px — category icon, large hero.
  static const double xl3 = 48;

  /// 64px — account avatar, extra large.
  static const double xl4 = 64;

  /// 12px — status dot, tiny indicator. (= [xs])
  static const double level1 = xs;

  /// 16px — inline icon, chevron, small action. (= [sm])
  static const double level2 = sm;

  /// 20px — tile prefix, button icon, default size. (= [md])
  static const double level3 = md;

  /// 24px — section header, empty-state icon. (= [lg])
  static const double level4 = lg;

  /// 28px — suggestion card icon, medium hero. (= [xl])
  static const double level5 = xl;

  /// 32px — avatar, hero icon, large empty-state. (= [xl2])
  static const double level6 = xl2;

  /// 48px — category icon, large hero. (= [xl3])
  static const double level7 = xl3;

  /// 64px — account avatar, extra large. (= [xl4])
  static const double level8 = xl4;
}
