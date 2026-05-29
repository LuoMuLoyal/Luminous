import 'package:flutter/widgets.dart';

/// 全局阴影 token。
///
/// 基于 DESIGN.md（Airbnb 设计语言）：
/// 系统本质上只有**一个阴影层级**，用于卡片悬浮、搜索栏、下拉菜单等。
/// 深度主要靠摄影、white-on-white 表面分离和圆角裁剪来表达，而非阴影层级。
class AppShadow {
  AppShadow._();

  // ── Airbnb 标准卡片阴影（系统唯一阴影层级）──
  //
  // CSS: box-shadow:
  //   rgba(0,0,0,0.02) 0 0 0 1px,
  //   rgba(0,0,0,0.04) 0 2px 6px 0,
  //   rgba(0,0,0,0.1) 0 4px 8px 0
  //
  // 用于：property-card hover、search-bar、dropdown menus、reservation-card。

  /// 第一层：0 0 0 1px（1px 描边模拟）。
  static BoxShadow get cardBorder => const BoxShadow(
    color: Color(0x05000000), // rgba(0,0,0,0.02)
    blurRadius: 0,
    spreadRadius: 1,
    offset: Offset(0, 0),
  );

  /// 第二层：0 2px 6px（浅层浮起）。
  static BoxShadow get cardMid => const BoxShadow(
    color: Color(0x0A000000), // rgba(0,0,0,0.04)
    blurRadius: 6,
    offset: Offset(0, 2),
  );

  /// 第三层：0 4px 8px（主要投影）。
  static BoxShadow get cardDeep => const BoxShadow(
    color: Color(0x1A000000), // rgba(0,0,0,0.1)
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  /// Airbnb 标准卡片阴影组合（三层叠加）。
  ///
  /// 用于 property-card hover、search-bar、dropdown、reservation-card。
  static List<BoxShadow> get card => [cardBorder, cardMid, cardDeep];

  // ── 产品图专用阴影（Apple 唯一 drop-shadow）──

  /// 产品图放置在表面上的阴影：rgba(0,0,0,0.22) 3px 5px 30px。
  static BoxShadow get product => const BoxShadow(
    color: Color(0x38000000),
    blurRadius: 30,
    offset: Offset(3, 5),
  );

  // ── 兼容旧代码 ──

  /// 浅阴影：等同于 card 组合。
  static List<BoxShadow> get cardShadows => card;

  /// 深阴影：toast、浮层。
  static BoxShadow get surface => const BoxShadow(
    color: Color(0x33000000),
    blurRadius: 18,
    offset: Offset(0, 10),
  );

  /// light 模式 surface card 次阴影。
  static List<BoxShadow> get surfaceLight => card;

  // ── 底部导航 / 悬浮按钮 ──

  /// 底部 Tab 栏主阴影。
  static BoxShadow bottomBar(Color color) =>
      BoxShadow(color: color, blurRadius: 22, offset: const Offset(0, 10));

  /// 底部 Tab 栏装饰节点阴影。
  static BoxShadow bottomBarOrnament(Color color) =>
      BoxShadow(color: color, blurRadius: 16, offset: const Offset(0, 6));

  // ── 认证页 ──

  /// 登录/注册切换卡阴影。
  static BoxShadow get authCard => const BoxShadow(
    color: Color(0x100F172A),
    blurRadius: 12,
    offset: Offset(0, 6),
  );

  /// 登录/注册选中卡片阴影。
  static BoxShadow authCardSelected(Color color) =>
      BoxShadow(color: color, blurRadius: 14, offset: const Offset(0, 6));
}
