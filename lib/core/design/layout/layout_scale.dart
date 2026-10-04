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
    if (screenWidth >= Breakpoints.tablet) return 480;
    return dialogMaxWidth;
  }

  /// Resolves a wider dialog max width based on the current screen width.
  ///
  /// Used for confirmation dialogs and account settings that benefit from
  /// extra horizontal space on larger screens.
  static double wideDialogMaxWidthFor(double screenWidth) {
    if (screenWidth >= Breakpoints.desktop) return 640;
    if (screenWidth >= Breakpoints.tablet) return 520;
    return wideDialogMaxWidth;
  }

  static LayoutScale resolve(double width) {
    if (width < Breakpoints.mobile) {
      return const LayoutScale(
        pageHorizontalPadding: Spacing.lg,
        sectionVerticalPadding: Spacing.xl3,
        heroVerticalPadding: Spacing.xl5,
        cardPadding: Spacing.lg,
        cardPaddingLarge: Spacing.xl,
        componentGap: Spacing.md,
        maxContentWidth: 560,
      );
    }

    if (width < Breakpoints.tablet) {
      return const LayoutScale(
        pageHorizontalPadding: Spacing.xl,
        sectionVerticalPadding: Spacing.xl5,
        heroVerticalPadding: Spacing.xl6,
        cardPadding: Spacing.xl,
        cardPaddingLarge: Spacing.xl2,
        componentGap: Spacing.lg,
        maxContentWidth: 760,
      );
    }

    // 960–1200: transitional "small desktop" — wider padding + 2-col grid
    // maxContentWidth, but not full dual-pane.
    if (width < Breakpoints.desktop) {
      return const LayoutScale(
        pageHorizontalPadding: Spacing.xl2,
        sectionVerticalPadding: Spacing.xl5,
        heroVerticalPadding: Spacing.xl6,
        cardPadding: Spacing.xl,
        cardPaddingLarge: Spacing.xl2,
        componentGap: Spacing.lg,
        maxContentWidth: 1040,
      );
    }

    // 1200–1400: standard desktop dual-pane.
    if (width < Breakpoints.wide) {
      return const LayoutScale(
        pageHorizontalPadding: Spacing.xl2,
        sectionVerticalPadding: Spacing.xl6,
        heroVerticalPadding: Spacing.xl8,
        cardPadding: Spacing.xl,
        cardPaddingLarge: Spacing.xl2,
        componentGap: Spacing.xl,
        maxContentWidth: 1400,
      );
    }

    // ≥1400: wide desktop — same spacing, wider content allowance.
    return const LayoutScale(
      pageHorizontalPadding: Spacing.xl3,
      sectionVerticalPadding: Spacing.xl6,
      heroVerticalPadding: Spacing.xl8,
      cardPadding: Spacing.xl,
      cardPaddingLarge: Spacing.xl2,
      componentGap: Spacing.xl,
      maxContentWidth: 1600,
    );
  }
}
