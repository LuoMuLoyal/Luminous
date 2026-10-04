import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/widgets/common/control/date_picker.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';

import '../../helpers/test_forui_app.dart';
import '../../helpers/test_helpers.dart';

/// 真机（vivo X200s ≈360dp）在「记录页 → 右上日期」打开日历时，Forui 对话框默认
/// 左右各 40dp inset 只留约 240dp，而 `FCalendar` 的网格需要 7×daySize(44)=308dp，
/// 结果分隔头部右溢 44px、日期列被裁。这两条用例按真机逻辑尺寸 + 1.3 字缩放回归。
void main() {
  const viewports = <(String, void Function(WidgetTester))>[
    ('compact 360x800', setCompactPhoneScreenSize),
    ('narrow 320x720', setNarrowPhoneScreenSize),
  ];

  for (final (label, apply) in viewports) {
    testWidgets('date picker fits a $label viewport at 1.3x scale', (
      tester,
    ) async {
      apply(tester);

      final overflows = <FlutterErrorDetails>[];
      final previous = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) {
          overflows.add(details);
        } else {
          previous?.call(details);
        }
      };
      addTearDown(() => FlutterError.onError = previous);

      await tester.pumpWidget(
        // 字缩放必须包在 MaterialApp 之外:弹窗挂在根 Navigator 上,包进
        // `TestForuiApp.home`(页面级写法)够不到它。
        scaledForTextScale(
          TestForuiApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => showForuiDatePicker(
                      context,
                      initial: DateTime(2026, 10, 4),
                      first: DateTime(2020),
                      last: DateTime(2030),
                    ),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
          1.3,
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // 断言前先还原:自定义 onError 仍挂着时抛断言会让 binding 报
      // `_pendingExceptionDetails != null` 而不是给出溢出原因。
      FlutterError.onError = previous;
      expect(
        overflows,
        isEmpty,
        reason: overflows.map((d) => d.exceptionAsString()).join('\n---\n'),
      );

      // 弹窗宽度必须容得下日历头部（1.3 字缩放下约 262dp）。
      final dialogWidth = tester.getSize(find.byType(DialogShell)).width;
      expect(dialogWidth, greaterThanOrEqualTo(288));
    });
  }
}
