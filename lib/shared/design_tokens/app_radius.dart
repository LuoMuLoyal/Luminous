import 'package:flutter/widgets.dart';

/// 全局圆角 token。
///
/// 组件和组件引用此处的语义化常量，避免散落 `BorderRadius.circular()` 魔数。
///
/// 参考 Apple 设计语言圆角系统：
/// none(0) / sm(8) / md(11) / lg(18) / pill(9999)
class AppRadius {
  AppRadius._();

  // ── 基础圆角 ──

  /// 0px — 全宽 Tile、无圆角元素。
  static const double none = 0;

  /// 6px — 紧凑型 chip、复选框。
  static const double tight = 6;

  /// 8px — 小按钮、内嵌图片。
  static const double sm = 8;

  /// 12px — 小 chip、辅助元素。
  static const double chip = 12;

  /// 14px — 文本按钮、小输入框。
  static const double small = 14;

  /// 16px — 输入框、普通按钮。
  static const double input = 16;

  /// 18px — 卡片、实用工具卡片（Apple lg）。
  static const double card = 18;

  /// 20px — 列表项卡片。
  static const double cardLarge = 20;

  /// 24px — 大容器（dialog、bottomSheet、card）。
  static const double container = 24;

  /// 9999px — 胶囊按钮（Apple pill）。
  static const double pill = 9999;

  // ── 语义级 BorderRadius ──

  static BorderRadius get tightRadius => BorderRadius.circular(tight);
  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get chipRadius => BorderRadius.circular(chip);
  static BorderRadius get smallRadius => BorderRadius.circular(small);
  static BorderRadius get inputRadius => BorderRadius.circular(input);
  static BorderRadius get cardRadius => BorderRadius.circular(card);
  static BorderRadius get containerRadius =>
      const BorderRadius.all(Radius.circular(container));
  static BorderRadius get pillRadius => BorderRadius.circular(pill);

  static BorderRadius get containerTopRadius =>
      const BorderRadius.vertical(top: Radius.circular(container));
}
