import 'package:flutter/widgets.dart';

/// 全局间距 token。
///
/// 基于 DESIGN.md（Airbnb 设计语言）的 4px 网格间距系统。
/// 页面和组件引用此处的语义化 EdgeInsets / SizedBox 预设。
///
/// Token: xxs(2) · xs(4) · sm(8) · md(12) · base(16) · lg(24) · xl(32) · xxl(48) · section(64)
class AppSpacing {
  AppSpacing._();

  // ── 基础步进（4px 网格）──

  /// 2px — 极小间距（图标与文字间距、密集型元素）。
  static const double xxs = 2;

  /// 4px — 小间距（组件内元素间、category-strip dividers）。
  static const double xs = 4;

  /// 8px — 中间距（caption/date-row gutters、卡片内容）。
  static const double sm = 8;

  /// 12px — 中大间距（列表项内、卡片内边距）。
  static const double md = 12;

  /// 16px — 页面边距（property-card meta、卡片间 gutter）。
  static const double base = 16;

  /// 24px — 大区块间距（host-card、reservation-card padding、footer column gutters）。
  static const double lg = 24;

  /// 32px — 页面级段落间距。
  static const double xl = 32;

  /// 48px — 大段落间距。
  static const double xxl = 48;

  /// 64px — 段落间距（major page bands、全宽区块内边距）。
  static const double section = 64;

  /// 80px — 全宽 Tile 内边距（Apple 风格）。
  static const double tile = 80;

  // ── 常用 EdgeInsets ──

  /// 页面水平边距：H=16。
  static const EdgeInsets hPage = EdgeInsets.symmetric(horizontal: base);

  /// 页面全向边距：16。
  static const EdgeInsets allPage = EdgeInsets.all(base);

  /// 卡片内边距：12。
  static const EdgeInsets allCard = EdgeInsets.all(md);

  /// 卡片内容：L12, T10, R12, B12。
  static const EdgeInsets cardContent = EdgeInsets.fromLTRB(md, 10, md, md);

  /// 输入框：H12, V14（Airbnb text-input padding 14×12）。
  static const EdgeInsets inputContent = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 14,
  );

  /// Chip：H10, V6。
  static const EdgeInsets chipCompact = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 6,
  );

  // ── 常用 SizedBox ──

  static const SizedBox gapXxs = SizedBox(height: xxs);
  static const SizedBox gapXs = SizedBox(height: xs);
  static const SizedBox gapSm = SizedBox(height: sm);
  static const SizedBox gapMd = SizedBox(height: md);
  static const SizedBox gapBase = SizedBox(height: base);
  static const SizedBox gapLg = SizedBox(height: lg);
  static const SizedBox gapXl = SizedBox(height: xl);
  static const SizedBox gapSection = SizedBox(height: section);

  // ── 常用 SizedBox（水平）──

  static const SizedBox gapWXxs = SizedBox(width: xxs);
  static const SizedBox gapWXs = SizedBox(width: xs);
  static const SizedBox gapWSm = SizedBox(width: sm);
  static const SizedBox gapWMd = SizedBox(width: md);
  static const SizedBox gapWBase = SizedBox(width: base);
}
