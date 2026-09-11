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
