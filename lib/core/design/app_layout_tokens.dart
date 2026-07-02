import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_spacing_tokens.dart';

@immutable
class AppLayoutScale {
  const AppLayoutScale({
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

abstract final class AppLayoutTokens {
  static AppLayoutScale resolve(double width) {
    if (width < AppBreakpoints.mobile) {
      return const AppLayoutScale(
        pageHorizontalPadding: AppSpacingTokens.level4,
        sectionVerticalPadding: AppSpacingTokens.level7,
        heroVerticalPadding: AppSpacingTokens.level9,
        cardPadding: AppSpacingTokens.level4,
        cardPaddingLarge: AppSpacingTokens.level5,
        componentGap: AppSpacingTokens.level3,
        maxContentWidth: 560,
      );
    }

    if (width < AppBreakpoints.tablet) {
      return const AppLayoutScale(
        pageHorizontalPadding: AppSpacingTokens.level5,
        sectionVerticalPadding: AppSpacingTokens.level9,
        heroVerticalPadding: AppSpacingTokens.level10,
        cardPadding: AppSpacingTokens.level5,
        cardPaddingLarge: AppSpacingTokens.level6,
        componentGap: AppSpacingTokens.level4,
        maxContentWidth: 760,
      );
    }

    if (width < AppBreakpoints.desktop) {
      return const AppLayoutScale(
        pageHorizontalPadding: AppSpacingTokens.level6,
        sectionVerticalPadding: AppSpacingTokens.level9,
        heroVerticalPadding: AppSpacingTokens.level10,
        cardPadding: AppSpacingTokens.level5,
        cardPaddingLarge: AppSpacingTokens.level6,
        componentGap: AppSpacingTokens.level4,
        maxContentWidth: 1040,
      );
    }

    return const AppLayoutScale(
      pageHorizontalPadding: AppSpacingTokens.level6,
      sectionVerticalPadding: AppSpacingTokens.level10,
      heroVerticalPadding: AppSpacingTokens.level12,
      cardPadding: AppSpacingTokens.level5,
      cardPaddingLarge: AppSpacingTokens.level6,
      componentGap: AppSpacingTokens.level5,
      maxContentWidth: 1400,
    );
  }
}
