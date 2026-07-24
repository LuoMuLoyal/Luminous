import 'package:flutter/material.dart';
import 'package:luminous/core/design/breakpoints.dart';
import 'package:luminous/core/design/spacing.dart';

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
        pageHorizontalPadding: Spacing.level4,
        sectionVerticalPadding: Spacing.level7,
        heroVerticalPadding: Spacing.level9,
        cardPadding: Spacing.level4,
        cardPaddingLarge: Spacing.level5,
        componentGap: Spacing.level3,
        maxContentWidth: 560,
      );
    }

    if (width < Breakpoints.tablet) {
      return const LayoutScale(
        pageHorizontalPadding: Spacing.level5,
        sectionVerticalPadding: Spacing.level9,
        heroVerticalPadding: Spacing.level10,
        cardPadding: Spacing.level5,
        cardPaddingLarge: Spacing.level6,
        componentGap: Spacing.level4,
        maxContentWidth: 760,
      );
    }

    if (width < Breakpoints.desktop) {
      return const LayoutScale(
        pageHorizontalPadding: Spacing.level6,
        sectionVerticalPadding: Spacing.level9,
        heroVerticalPadding: Spacing.level10,
        cardPadding: Spacing.level5,
        cardPaddingLarge: Spacing.level6,
        componentGap: Spacing.level4,
        maxContentWidth: 1040,
      );
    }

    return const LayoutScale(
      pageHorizontalPadding: Spacing.level6,
      sectionVerticalPadding: Spacing.level10,
      heroVerticalPadding: Spacing.level12,
      cardPadding: Spacing.level5,
      cardPaddingLarge: Spacing.level6,
      componentGap: Spacing.level5,
      maxContentWidth: 1400,
    );
  }
}
