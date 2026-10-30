import 'package:flutter/widgets.dart';

import 'viewport.dart';

/// A resolved component, paired with how many columns it asks for.
///
/// Built by the grid hosts so that a placement's span travels with the widget it
/// belongs to. `_resolve` already drops invisible/empty components, so a span can
/// never be stranded on a component that produced no widget (which would leave a
/// hole in the packing).
typedef GridEntry = ({Widget widget, int span});

/// One row of the responsive surface: the entries that share a line, in order.
typedef GridRowLayout = ({List<GridEntry> entries, List<int> spans});

/// Groups [entries] into rows of exactly [columns] columns.
///
/// Placement is **not** delegated to `flutter_layout_grid`'s automatic placement,
/// because that algorithm cannot place spanning items reliably: it advances its
/// cursor one column at a time and, when a wide item does not fit in the
/// remaining columns, it may report `columnStart + span > columns` and throw
/// `GridPlacement.columnEnd cannot exceed column count`. A minimal reproduction
/// is two `columnSpan: 2` items in a 3-column grid — `[2, 2]` throws, while
/// `[3, 2]` does not.
///
/// Since this grid only ever needs "fill left to right, wrap when the next item
/// does not fit", the packing is computed here instead: a row is closed as soon
/// as the next item would overflow it. That is deterministic, unit-testable, and
/// removes the library's placement (and its implicit viewport) from the render
/// path entirely.
///
/// Sparse packing means a row may end with unused columns; those are left blank
/// rather than back-filled by a later small item. That matches what a user
/// arranging "two half-width cards, then a full-width card" expects to see.
///
/// A span larger than [columns] is clamped, so a persisted `wide` on a phone
/// becomes a single full-width row instead of an overflow.
List<GridRowLayout> layoutGridRows(List<GridEntry> entries, int columns) {
  if (columns < 1 || entries.isEmpty) return const [];

  final rows = <GridRowLayout>[];
  var currentEntries = <GridEntry>[];
  var currentSpans = <int>[];
  var used = 0;

  void flush() {
    if (currentEntries.isEmpty) return;
    rows.add((entries: currentEntries, spans: currentSpans));
    currentEntries = <GridEntry>[];
    currentSpans = <int>[];
    used = 0;
  }

  for (final entry in entries) {
    final span = entry.span.clamp(1, columns);
    if (used + span > columns) flush();
    currentEntries.add(entry);
    currentSpans.add(span);
    used += span;
    if (used == columns) flush();
  }
  flush();
  return rows;
}

/// Number of rows [entries] occupy when placed into [columns] columns.
///
/// Derived from [layoutGridRows] so the two can never disagree.
int gridRowCount(List<GridEntry> entries, int columns) =>
    layoutGridRows(entries, columns).length;

/// Renders [entries] as rows of [columns] equal-width columns.
///
/// Each row is a `Row` of `Expanded(flex: span)` children, so column widths are
/// proportional and every row's items share the same height (a `Row` stretches
/// its children by default with `CrossAxisAlignment.stretch`).
///
/// Why not `LayoutGrid`: see [layoutGridRows]. Beyond the placement bug, the
/// library also routes children through an internal shrink-wrapping viewport,
/// which makes any descendant that asks for intrinsic size (Forui's `FBadge`
/// wraps itself in `IntrinsicWidth`) throw
/// "RenderShrinkWrappingViewport does not support returning intrinsic
/// dimensions". `Row`/`Expanded` has neither problem and needs no span clamping
/// against a library's implicit grid.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.entries,
    required this.columns,
    this.rowSpacing = 0,
    this.columnSpacing = 0,
  });

  final List<GridEntry> entries;
  final int columns;

  /// Vertical gap between rows. Never applied after the last row.
  final double rowSpacing;

  /// Horizontal gap between columns within a row.
  final double columnSpacing;

  @override
  Widget build(BuildContext context) {
    final rows = layoutGridRows(entries, columns);
    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < rows.length; index += 1) ...[
          if (index > 0) SizedBox(height: rowSpacing),
          _GridRow(
            row: rows[index],
            columns: columns,
            columnSpacing: columnSpacing,
          ),
        ],
      ],
    );
  }
}

class _GridRow extends StatelessWidget {
  const _GridRow({
    required this.row,
    required this.columns,
    required this.columnSpacing,
  });

  final GridRowLayout row;
  final int columns;
  final double columnSpacing;

  @override
  Widget build(BuildContext context) {
    // `IntrinsicHeight` is deliberately avoided here.
    //
    // Forcing equal row heights would require asking every child for its
    // intrinsic height, and components are arbitrary business widgets — several
    // of them (today's observation card, review's history list) contain their
    // own scroll views, whose `RenderShrinkWrappingViewport` refuses intrinsic
    // queries and throws at layout time.
    //
    // `CrossAxisAlignment.start` lets each card keep its natural height. On a
    // row that pairs two compact cards this can leave a small height difference,
    // which is the accepted trade-off for supporting components that scroll
    // internally.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < row.entries.length; index += 1) ...[
          if (index > 0) SizedBox(width: columnSpacing),
          Expanded(flex: row.spans[index], child: row.entries[index].widget),
        ],
        // Trailing blank columns keep a short row aligned with full ones, so
        // a half-width card does not stretch across the whole surface.
        if (_usedSpans(row.spans) < columns)
          Spacer(flex: columns - _usedSpans(row.spans)),
      ],
    );
  }

  static int _usedSpans(List<int> spans) =>
      spans.fold<int>(0, (sum, span) => sum + span);
}

/// Layout class of the nearest enclosing media query, exposed so callers can
/// branch on it without importing [ComponentLayout] and [Breakpoints] together.
ComponentLayout componentLayoutOf(BuildContext context) =>
    ComponentLayout.of(context);
