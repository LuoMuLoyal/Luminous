import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';

/// Unified responsive vertical padding for settings pages.
///
/// Uses [Spacing.level6] on narrow screens (< [Breakpoints.mobile]), [Spacing.level7] on wide screens.
double settingsPageVerticalPadding(BuildContext context) {
  return MediaQuery.sizeOf(context).width < Breakpoints.mobile
      ? Spacing.level6
      : Spacing.level7;
}
