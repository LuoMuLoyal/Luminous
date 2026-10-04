import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';

/// Shows a forui calendar date-picker dialog and returns the picked [DateTime].
///
/// Returns `null` if the user dismisses the dialog without selecting a date.
/// The selected date is truncated to a day-only [DateTime] (no time component).
///
/// This is the shared version of the pattern used across the app (record,
/// medicine reminders, health forms). All date-picker entry points should
/// delegate here instead of re-implementing `showFDialog + FCalendar.grid`.
///
/// 宽度前提：`FCalendar` 的头部（"October 2026" + 翻页箭头）在 1.3 字缩放下需要约
/// 262dp，而 320–360dp 机型上 Forui 对话框默认左右各 40dp inset + 本壳 padding 会把
/// 内容压到 240dp 以下——真机实测右溢 44px、日期列被裁。因此 `DialogShell` 在窄屏收窄
/// inset，这里再把本壳 padding 收到 `Spacing.sm`，保证头部有足够宽度；日期格保持
/// Forui 的触摸尺寸（44dp），不再靠缩格子回避问题。
Future<DateTime?> showForuiDatePicker(
  BuildContext context, {
  required DateTime initial,
  required DateTime first,
  required DateTime last,
}) {
  final width = MediaQuery.sizeOf(context).width;

  return showFDialog<DateTime?>(
    context: context,
    builder: (dialogContext, style, animation) => DialogShell(
      maxWidth: LayoutScaleResolver.dialogMaxWidthFor(width),
      padding: const EdgeInsets.all(Spacing.sm),
      builder: (_) => SizedBox(
        height: 360,
        // 日历的固有宽度是 `7 × daySize`（触摸端 44 → 308dp），而头部
        // （"October 2026" + 翻页箭头）在 1.3 字缩放下需要约 307dp——一旦弹窗把
        // 日历压窄（320dp 机型只剩约 272dp），头部与日期列就会右溢出/被裁。
        // 这里给日历一个横向可滚动容器：宽度不再被压缩（头部完整、日期列完整），
        // 弹窗比日历窄时改为横向滚动，而不是溢出。
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: FCalendar.grid(
            control: FGridCalendarControl(start: first, end: last),
            selectionControl: FDateSelectionControl.liftedSingle(
              value: _dateOnly(initial),
              onChange: (date) => Navigator.of(dialogContext).pop(date),
              toggleable: false,
            ),
          ),
        ),
      ),
    ),
  );
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
