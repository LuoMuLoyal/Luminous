/// Icon size token scale.
///
/// 5 levels covering all icon sizes used in the app. Use [level1] (12px)
/// through [level5] (32px) for all `Icon(size:)` and `iconSize:` values.
///
/// | Level  | px  | Use case                          |
/// |--------|-----|-----------------------------------|
/// | [level1] | 12 | Status dot, tiny indicator        |
/// | [level2] | 16 | Inline icon, chevron, small action |
/// | [level3] | 20 | Tile prefix, button icon, default  |
/// | [level4] | 24 | Section header, empty-state icon   |
/// | [level5] | 32 | Avatar, hero icon                  |
abstract final class IconSizeTokens {
  /// 12px — status dot, tiny indicator.
  static const double level1 = 12;

  /// 16px — inline icon, chevron, small action.
  static const double level2 = 16;

  /// 20px — tile prefix, button icon, default size.
  static const double level3 = 20;

  /// 24px — section header, empty-state icon.
  static const double level4 = 24;

  /// 32px — avatar, hero icon.
  static const double level5 = 32;
}
