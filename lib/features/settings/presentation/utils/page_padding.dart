import 'package:luminous/core/design/design.dart';
import 'package:material_ui/material_ui.dart';

/// Unified responsive vertical padding for settings pages.
///
/// Uses [Spacing.xl2] on narrow screens (< [Breakpoints.mobile]), [Spacing.xl3] on wide screens.
double settingsPageVerticalPadding(BuildContext context) {
  return MediaQuery.sizeOf(context).width < Breakpoints.mobile
      ? Spacing.xl2
      : Spacing.xl3;
}
