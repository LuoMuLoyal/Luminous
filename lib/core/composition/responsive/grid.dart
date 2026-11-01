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
///
/// ## 切行的判据是「跨列」，不是「这一行填满了」
///
/// 只有需要独占整行的条目（span == [columns]）才切出一条新「带」。
/// 连续的单列条目全部留在同一个带里，由 [_splitIntoColumns] 按列竖向分配到
/// 左右两列。
///
/// 之前每到 `used == columns` 就切行，等于把卡片按「左右、左右」逐行配对：
/// 视觉上第 2 个条目跑到右上角、第 3 个回到左下角，读起来就是「顺序反了」。
/// 手机端一路竖直往下读，桌面端必须保持同一条阅读轴。
List<GridRowLayout> layoutGridRows(List<GridEntry> entries, int columns) {
  if (columns < 1 || entries.isEmpty) return const [];

  final rows = <GridRowLayout>[];
  var currentEntries = <GridEntry>[];
  var currentSpans = <int>[];

  void flush() {
    if (currentEntries.isEmpty) return;
    rows.add((entries: currentEntries, spans: currentSpans));
    currentEntries = <GridEntry>[];
    currentSpans = <int>[];
  }

  for (final entry in entries) {
    final span = entry.span.clamp(1, columns);
    if (span >= columns) {
      // 整行条目自成一带，前后都不与单列条目混排。
      flush();
      rows.add((entries: [entry], spans: [span]));
      continue;
    }
    currentEntries.add(entry);
    currentSpans.add(span);
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
            rowSpacing: rowSpacing,
          ),
        ],
      ],
    );
  }
}

/// One vertical column of cards inside a band.
///
/// 一个「带」里同一列自上而下的若干条目；每列对应 [Expanded] 的一个 flex 宽度，
/// 空列渲染为 [Spacer] 保持对齐。
typedef _GridColumn = ({List<GridEntry> entries, int flex});

/// 把一个带切成各列。
///
/// 带内的单列条目按**竖向流动**分配：前一半给左列，后一半给右列，这样读的
/// 顺序是「左列从上到下，然后右列从上到下」——与手机端一路竖直向下的阅读轴
/// 一致。
///
/// 不是 `i % columns` 那样交替分配：交替会让左列第 1 个卡片的右邻变成第 2 个
/// 条目，视觉上第 2 项跑到右上角、第 3 项回到左下角，读起来像顺序被打乱。
/// 均分（而不是「列高等高再填下一列」）是因为卡片高度由内容决定、布局期不可知，
/// 按条目数均分是唯一能在流式布局里保持严格阅读顺序的做法。
List<_GridColumn> _splitIntoColumns(List<GridEntry> row, int columns) {
  final count = row.length;
  final buckets = [for (var i = 0; i < columns; i += 1) <GridEntry>[]];
  final flexes = [for (var i = 0; i < columns; i += 1) 0];

  // 每列分到的条目数：向下取整，余数依次补给前面的列。
  final perColumn = count ~/ columns;
  final remainder = count % columns;
  var cursor = 0;
  for (var column = 0; column < columns; column += 1) {
    final take = perColumn + (column < remainder ? 1 : 0);
    for (var i = 0; i < take; i += 1) {
      final entry = row[cursor++];
      buckets[column].add(entry);
      flexes[column] = entry.span.clamp(1, columns);
    }
  }

  return [
    for (var i = 0; i < columns; i += 1)
      if (buckets[i].isNotEmpty) (entries: buckets[i], flex: flexes[i]),
  ];
}

class _GridRow extends StatelessWidget {
  const _GridRow({
    required this.row,
    required this.columns,
    required this.columnSpacing,
    required this.rowSpacing,
  });

  final GridRowLayout row;
  final int columns;
  final double columnSpacing;
  final double rowSpacing;

  @override
  Widget build(BuildContext context) {
    // 整行条目（`wide`）：独占一行，不需要分列。
    if (row.entries.length == 1 && row.spans.first >= columns) {
      return row.entries.first.widget;
    }

    // 多列：每一列是自上而下的 `Column`，列与列并排。
    //
    // `IntrinsicHeight` 在这里同样不能用（理由见下方历史注释）：同列卡片高度
    // 不同是正常的瀑布流外观，强行等高会去问子组件的固有高度，而部分组件
    // 内部含滚动视图，会直接抛异常。
    final split = _splitIntoColumns(row.entries, columns);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < split.length; index += 1) ...[
          if (index > 0) SizedBox(width: columnSpacing),
          Expanded(
            flex: split[index].flex,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < split[index].entries.length; i += 1) ...[
                  if (i > 0) SizedBox(height: rowSpacing),
                  split[index].entries[i].widget,
                ],
              ],
            ),
          ),
        ],
        // 短行补齐剩余列，避免半宽卡片被拉伸到整行。
        if (split.fold<int>(0, (sum, c) => sum + c.flex) < columns)
          Spacer(flex: columns - split.fold<int>(0, (sum, c) => sum + c.flex)),
      ],
    );
  }
}

/// Layout class of the nearest enclosing media query, exposed so callers can
/// branch on it without importing [ComponentLayout] and [Breakpoints] together.
ComponentLayout componentLayoutOf(BuildContext context) =>
    ComponentLayout.of(context);
