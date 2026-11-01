import 'package:fluid_adaptive/fluid_adaptive.dart';
import 'package:flutter/material.dart';
import 'package:luminous/core/design/tokens/breakpoints.dart';
import 'package:luminous/core/design/tokens/spacing.dart';

/// Responsive layout scale resolved from the current screen width.
///
/// This is a layout helper, not a visual design token. The values here
/// describe how page padding, section spacing, card padding, and max content
/// width adapt across breakpoints; they intentionally delegate spacing to
/// [Spacing] rather than defining a second visual scale.
@immutable
class LayoutScale {
  const LayoutScale({
    required this.pageHorizontalPadding,
    required this.sectionVerticalPadding,
    required this.heroVerticalPadding,
    required this.cardPadding,
    required this.cardPaddingLarge,
    required this.componentGap,
    required this.maxContentWidth,
  });

  final double pageHorizontalPadding;
  final double sectionVerticalPadding;
  final double heroVerticalPadding;
  final double cardPadding;
  final double cardPaddingLarge;
  final double componentGap;
  final double maxContentWidth;
}

/// Resolves a [LayoutScale] from the current screen width, plus fixed layout
/// constants for dialogs.
abstract final class LayoutScaleResolver {
  /// 忽略缩放也要保住的设计基线文字宽度（逻辑像素）。
  ///
  /// 取 Pixel 8 Pro（约 448dp，页面左右各 [Spacing.lg]=14dp）在 1.3 档下的实际
  /// 可用文字宽度：`(448 - 28) / 1.3 ≈ 323`，取整为 320。凡是缩放后可用宽度低于
  /// 这条基线的机型，就把生效字号降到「刚好保住基线」的档位。
  static const double designBaselineTextWidth = 320;

  /// 窄屏/小屏上的**生效**字号缩放。
  ///
  /// App 有意不跟随系统字号，只用自身 4 档（0.85/1.0/1.15/1.3，见
  /// `core/accessibility/settings.dart`）。但同一档位在不同宽度上的观感完全不同：
  /// 真机 vivo X200s（约 393dp）用 1.3 时每行字比 Pixel 8 Pro 模拟器（约 448dp）
  /// 少约 13%，换行更多、卡片更高，纵向节奏看起来"变大"了；最窄机型（360/320dp）
  /// 更会出现成片溢出。
  ///
  /// 与其按固定宽度阈值降档（393dp 落在 360dp 阈值之外，问题照旧），不如按
  /// **缩放后的可用文字宽度**收口：让所有机型在缩放后都至少保住
  /// [designBaselineTextWidth]，于是换行数量与纵向节奏在不同宽度上接近一致。
  ///
  /// 规则：只对用户选择 >1.0 的档位设上限（绝不把用户选的档位调大，也不动
  /// 0.85/1.0 这些小档位），且下限保底 1.0。
  static double effectiveTextScale(double screenWidth, double preferredScale) {
    if (preferredScale <= 1.0) {
      return preferredScale;
    }

    // 600dp 以下页面左右各 Spacing.lg；更宽的屏幕宽度充足，规则不会生效。
    final available = (screenWidth - 2 * Spacing.lg) / designBaselineTextWidth;
    if (available <= 1.0) {
      return 1.0;
    }
    return preferredScale < available ? preferredScale : available;
  }

  /// 当前宽度是否属于"最窄机型"档（≤[Breakpoints.compact]，即 360dp）。
  ///
  /// 视觉上需要在一行放多个元素的地方（标题 + 徽章/动作、双按钮行）应该据此
  /// 退化为换行/堆叠，而不是继续挤在一行。
  static bool isCompact(double screenWidth) =>
      screenWidth <= Breakpoints.compact;

  /// Standard dialog max width (calendar pickers, form dialogs).
  static const double dialogMaxWidth = 360;

  /// Wider dialog max width (confirmations, account settings).
  static const double wideDialogMaxWidth = 420;

  /// Standard compact dialog max width (quick-entry selection dialogs).
  static const double dialogStandardMaxWidth = 440.0;

  /// Resolves a dialog max width based on the current screen width.
  ///
  /// On desktop (>= 1200) dialogs are wider for comfortable reading; on
  /// tablet (>= 960) they are slightly wider than mobile; on mobile the
  /// fixed [dialogMaxWidth] is used.
  static double dialogMaxWidthFor(double screenWidth) {
    if (screenWidth >= Breakpoints.desktop) return 560;
    if (screenWidth >= Breakpoints.expanded) return 480;
    return dialogMaxWidth;
  }

  /// Resolves a wider dialog max width based on the current screen width.
  ///
  /// Used for confirmation dialogs and account settings that benefit from
  /// extra horizontal space on larger screens.
  static double wideDialogMaxWidthFor(double screenWidth) {
    if (screenWidth >= Breakpoints.desktop) return 640;
    if (screenWidth >= Breakpoints.expanded) return 520;
    return wideDialogMaxWidth;
  }

  /// 按宽度解析布局尺度。
  ///
  /// 分档由 [WindowSizeClass] 决定（Material 3 window size class，阈值取
  /// `fluid_adaptive` 的标准值）：
  ///
  /// | WindowSizeClass | 宽度 | 本仓库对应设备 |
  /// | --- | --- | --- |
  /// | `compact` | < 600 | 手机 |
  /// | `medium` | 600–839 | 小平板 / 折叠屏 / 横屏手机 |
  /// | `expanded` | 840–1199 | 大平板 / 小笔记本 |
  /// | `large` | ≥ 1200 | 桌面窗口 |
  ///
  /// 各档的取值就是一张表——**表本身是设计决策，不该再靠 if 链表达**。
  /// [WindowSizeClass.resolve] 提供「大档缺失时回退到次小档」的语义，
  /// 所以档位增减只需改表，不必改分派逻辑。
  ///
  /// 断点直接用 [ResponsiveBreakpoints.standard]（600 / 840 / 1200），
  /// 不再自维护 `Breakpoints` 里那组 600 / 960 / 1200——两套阈值并存时，
  /// 布局分档与组件内判断会各说各的，这是最难查的一类界面缺陷。
  static LayoutScale resolve(double width) {
    return ResponsiveBreakpoints.standard
        .sizeClassFor(width)
        .resolve<LayoutScale>(
          compact: _phone,
          medium: _tablet,
          expanded: _smallDesktop,
          large: _desktop,
        );
  }

  /// `< 600`：手机。
  static const LayoutScale _phone = LayoutScale(
    pageHorizontalPadding: Spacing.lg,
    sectionVerticalPadding: Spacing.xl3,
    heroVerticalPadding: Spacing.xl5,
    cardPadding: Spacing.lg,
    cardPaddingLarge: Spacing.xl,
    componentGap: Spacing.md,
    maxContentWidth: 560,
  );

  /// `600–959`：平板。
  static const LayoutScale _tablet = LayoutScale(
    pageHorizontalPadding: Spacing.xl,
    sectionVerticalPadding: Spacing.xl5,
    heroVerticalPadding: Spacing.xl6,
    cardPadding: Spacing.xl,
    cardPaddingLarge: Spacing.xl2,
    componentGap: Spacing.lg,
    maxContentWidth: 760,
  );

  /// `840–1199`：过渡态「小桌面」——更宽的留白 + 两列网格，
  /// 但还不是完整的双栏。
  static const LayoutScale _smallDesktop = LayoutScale(
    pageHorizontalPadding: Spacing.xl2,
    sectionVerticalPadding: Spacing.xl5,
    heroVerticalPadding: Spacing.xl6,
    cardPadding: Spacing.xl,
    cardPaddingLarge: Spacing.xl2,
    componentGap: Spacing.lg,
    maxContentWidth: 1040,
  );

  /// `≥ 1200`：桌面双栏。
  ///
  /// 超宽屏（≥ 1400）不再单列一档：留白已经由 `xl2` 收敛，
  /// 内容宽度上限用 1600 兜住——再宽也只是两侧留白变多，
  /// 多一档只会让「某宽度下究竟是哪个值」更难追。
  static const LayoutScale _desktop = LayoutScale(
    pageHorizontalPadding: Spacing.xl2,
    sectionVerticalPadding: Spacing.xl6,
    heroVerticalPadding: Spacing.xl8,
    cardPadding: Spacing.xl,
    cardPaddingLarge: Spacing.xl2,
    componentGap: Spacing.xl,
    maxContentWidth: 1600,
  );
}
