import 'package:flutter/widgets.dart';

/// 全局圆角 token。
///
/// 组件和页面引用此处的语义化常量，避免散落 `BorderRadius.circular()` 魔数。
class AppRadius {
  AppRadius._();

  // -- 组件级 --

  /// 卡片、弹窗等大容器（dialog、bottomSheet、card）。
  static const double container = 24;

  /// 列表项卡片、输入框装饰。
  static const double card = 20;

  /// 输入框、按钮、chip。
  static const double input = 16;

  /// 文本按钮、小 chip。
  static const double small = 14;

  /// 复选框、紧凑型 chip。
  static const double tight = 6;

  // -- 语义级 BorderRadius --

  static BorderRadius get containerRadius => BorderRadius.circular(container);
  static BorderRadius get cardRadius => BorderRadius.circular(card);
  static BorderRadius get inputRadius => BorderRadius.circular(input);
  static BorderRadius get smallRadius => BorderRadius.circular(small);
  static BorderRadius get tightRadius => BorderRadius.circular(tight);

  static BorderRadius get containerTopRadius =>
      const BorderRadius.vertical(top: Radius.circular(container));
}
