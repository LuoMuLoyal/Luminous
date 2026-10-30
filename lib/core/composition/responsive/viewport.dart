import 'package:flutter/widgets.dart';
import 'package:luminous/core/design/tokens/breakpoints.dart';

import '../size.dart';

/// How many columns a surface renders at, i.e. which device class the current
/// viewport is.
///
/// This is the *layout* half of responsiveness: [ComponentSize] says how much
/// room a component wants, this says how much room there is. Keeping them apart
/// is what lets one persisted layout describe a phone, a tablet and a desktop at
/// once — the user arranges components once, and each viewport re-flows them
/// without a second saved layout.
enum ComponentLayout {
  /// One column. Every component is full width and sizes are visually inert.
  mobile(1),

  /// Two columns. A `compact` component takes one, anything else takes both.
  tablet(2),

  /// Three columns. `compact` = 1, `regular` = 2, `wide` = 3.
  desktop(3);

  const ComponentLayout(this.columns);

  /// Number of equal-width columns the surface is divided into.
  final int columns;

  /// Column span of [size] under this layout.
  ///
  /// Always clamped to [columns]: a `wide` component on a phone spans the single
  /// column rather than overflowing it.
  int spanOf(ComponentSize size) {
    final desired = switch (size) {
      ComponentSize.compact => 1,
      ComponentSize.regular =>
        columns == 1
            ? 1
            : columns < 3
            ? columns
            : 2,
      ComponentSize.wide => columns,
    };
    return desired.clamp(1, columns);
  }

  /// Resolves the layout class for an available width.
  ///
  /// Thresholds come from the repo's existing [Breakpoints] rather than new
  /// numbers: `tablet` (960) is where the desktop dual-pane shell takes over, so
  /// anything narrower must stay single-column to match the mobile shell.
  static ComponentLayout fromWidth(double width) {
    if (width >= Breakpoints.desktop) return desktop;
    if (width >= Breakpoints.tablet) return tablet;
    return mobile;
  }

  /// Resolves the layout class for the nearest enclosing media query.
  static ComponentLayout of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  /// Value stored in tests and diagnostics.
  String get wireValue => name;
}
