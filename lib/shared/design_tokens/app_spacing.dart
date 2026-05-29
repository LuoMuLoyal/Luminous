import 'package:flutter/widgets.dart';

/// 全局间距 token。
///
/// 基于 4px 网格，页面和组件引用此处的语义化 EdgeInsets / SizedBox 预设。
class AppSpacing {
  AppSpacing._();

  // ── 基础步进（4px 网格）──

  /// 4px — 极小间距（图标与文字、紧凑型元素）。
  static const double xxs = 4;

  /// 8px — 小间距（组件内元素间）。
  static const double xs = 8;

  /// 12px — 中间距（列表项内、卡片内容）。
  static const double sm = 12;

  /// 16px — 大间距（页面水平边距、区块内）。
  static const double md = 16;

  /// 20px — 加大间距（卡片间距、区块间）。
  static const double lg = 20;

  /// 24px — 大区块间距。
  static const double xl = 24;

  /// 32px — 页面级段落间距。
  static const double xxl = 32;

  /// 48px — 大段落间距。
  static const double section = 48;

  /// 64px — 全宽区块内边距。
  static const double sectionLg = 64;

  /// 80px — 全宽 Tile 内边距（Apple 风格）。
  static const double tile = 80;

  // ── 常用 EdgeInsets ──

  /// 页面水平边距：H=16。
  static const EdgeInsets hPage = EdgeInsets.symmetric(horizontal: md);

  /// 页面全向边距：16。
  static const EdgeInsets allPage = EdgeInsets.all(md);

  /// 卡片内边距：12。
  static const EdgeInsets allCard = EdgeInsets.all(sm);

  /// 卡片内容：L12, T10, R12, B12。
  static const EdgeInsets cardContent = EdgeInsets.fromLTRB(sm, 10, sm, sm);

  /// 输入框：H14, V14。
  static const EdgeInsets inputContent = EdgeInsets.symmetric(
    horizontal: 14,
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
  static const SizedBox gapLg = SizedBox(height: lg);
  static const SizedBox gapXl = SizedBox(height: xl);
  static const SizedBox gapSection = SizedBox(height: section);

  // ── 常用 SizedBox（水平）──

  static const SizedBox gapWXxs = SizedBox(width: xxs);
  static const SizedBox gapWXs = SizedBox(width: xs);
  static const SizedBox gapWSm = SizedBox(width: sm);
  static const SizedBox gapWMd = SizedBox(width: md);
}
