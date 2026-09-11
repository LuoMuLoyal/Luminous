import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Spacing token scale.
///
/// 12 levels mapped to the Forui design system's spacing values.
/// Semantic names ([xs] through [xl8]) are the primary naming — use them
/// for all padding, margins, gaps, and structural dimensions.
abstract final class Spacing {
  /// 4px — extra small spacing.
  static const double xs = 4;

  /// 6px — small spacing.
  static const double sm = 6;

  /// 10px — medium spacing.
  static const double md = 10;

  /// 14px — large spacing.
  static const double lg = 14;

  /// 20px — extra large spacing.
  static const double xl = 20;

  /// 28px — 2× extra large spacing.
  static const double xl2 = 28;

  /// 36px — 3× extra large spacing.
  static const double xl3 = 36;

  /// 44px — 4× extra large spacing.
  static const double xl4 = 44;

  /// 56px — 5× extra large spacing.
  static const double xl5 = 56;

  /// 72px — 6× extra large spacing.
  static const double xl6 = 72;

  /// 96px — 7× extra large spacing.
  static const double xl7 = 96;

  /// 128px — 8× extra large spacing.
  static const double xl8 = 128;
}

/// 标题与其内容之间的统一间距。
///
/// 全应用统一为 14px：值直接取自 Forui 主题 `context.theme.style.borderRadius.lg`
/// （= 14），与本层 `Spacing.lg` 同值——与圆角、字体一样走 Forui 原语，
/// 不在各处标题下方内联不同档位的间距。
///
/// 用法：在 build 里先取一次局部变量再用（本层「取法约定」），例如
/// ```dart
/// final titleGap = context.titleContentGap;
/// ...
/// SizedBox(height: titleGap),
/// ```
///
/// 「内容」指标题/分组标签直接统领的那块内容；标题与副标题之间的紧凑间距、
/// 桌面端布局的区块分隔不适用本约定。
extension TitleContentGapTokens on BuildContext {
  double get titleContentGap => theme.style.borderRadius.lg.topLeft.x;
}
