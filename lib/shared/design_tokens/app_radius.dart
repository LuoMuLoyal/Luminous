import 'package:flutter/widgets.dart';

/// 全局圆角 token。
///
/// 组件引用此处的语义化常量，避免散落 `BorderRadius.circular()` 魔数。
///
/// 基于 DESIGN.md（Airbnb 设计语言）圆角系统：
/// none(0) / xs(4) / sm(8) / md(14) / lg(20) / xl(32) / full(9999)
class AppRadius {
  AppRadius._();

  // ── 基础圆角（DESIGN.md rounded tokens）──

  /// 0px — 全宽 Tile、无圆角元素。
  static const double none = 0;

  /// 4px — 紧凑型元素（xs）。
  static const double xs = 4;

  /// 8px — 小按钮、内嵌图片、按钮圆角（sm）。
  static const double sm = 8;

  /// 12px — 小 chip、辅助元素。
  static const double chip = 12;

  /// 14px — 卡片圆角、property-card photo（md）。
  static const double md = 14;

  /// 20px — 大卡片（lg）。
  static const double lg = 20;

  /// 32px — category-strip rounded corners（xl）。
  static const double xl = 32;

  /// 9999px — 胶囊按钮、pill（full）。
  static const double full = 9999;

  // ── 语义级圆角（向后兼容）──

  /// 8px — 小按钮、内嵌图片。等同于 [sm]。
  static const double tight = sm;

  /// 8px — 小按钮。等同于 [sm]。
  static const double small = sm;

  /// 16px — 输入框（text-input rounded: sm=8px，但保留 16 兼容旧代码）。
  static const double input = 16;

  /// 14px — 卡片圆角。等同于 [md]。
  static const double card = md;

  /// 20px — 列表项卡片。等同于 [lg]。
  static const double cardLarge = lg;

  /// 32px — 大容器。等同于 [xl]。
  static const double container = xl;

  /// 9999px — 胶囊按钮。等同于 [full]。
  static const double pill = full;

  // ── 语义级 BorderRadius ──

  static BorderRadius get xsRadius => BorderRadius.circular(xs);
  static BorderRadius get tightRadius => BorderRadius.circular(tight);
  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get chipRadius => BorderRadius.circular(chip);
  static BorderRadius get smallRadius => BorderRadius.circular(small);
  static BorderRadius get mdRadius => BorderRadius.circular(md);
  static BorderRadius get inputRadius => BorderRadius.circular(input);
  static BorderRadius get cardRadius => BorderRadius.circular(card);
  static BorderRadius get lgRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
  static BorderRadius get containerRadius =>
      const BorderRadius.all(Radius.circular(container));
  static BorderRadius get pillRadius => BorderRadius.circular(pill);
  static BorderRadius get fullRadius => BorderRadius.circular(full);

  static BorderRadius get containerTopRadius =>
      const BorderRadius.vertical(top: Radius.circular(container));
}
