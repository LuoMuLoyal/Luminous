import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/widgets/common/avatar/avatar_draft.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';

import '../../helpers/test_forui_app.dart';
import '../../helpers/test_helpers.dart';

/// 真机(vivo X200s ≈360dp + 1.3 字缩放)打开「裁剪头像」弹窗时,固定 320dp 画布
/// 叠上弹窗固定 `maxHeight` 会把「取消 / 使用此头像」按钮行挤出弹窗下沿
/// (`BOTTOM OVERFLOWED BY 57 PIXELS`)——标题与按钮标签随字号长高,留给画布的
/// 高度就不够了。这两条用例按窄屏逻辑尺寸 + 1.3 字缩放回归,断言弹窗内没有
/// `RenderFlex overflowed`,且按钮行仍落在弹窗内。
void main() {
  const viewports = <(String, void Function(WidgetTester))>[
    ('compact 360x800', setCompactPhoneScreenSize),
    ('narrow 320x720', setNarrowPhoneScreenSize),
  ];

  for (final (label, apply) in viewports) {
    testWidgets('crop dialog fits a $label viewport at 1.3x scale', (
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

      final bytes = Uint8List.fromList(_pngHeader);

      // 字缩放必须包在 MaterialApp 之外:弹窗挂在根 Navigator 上,包进
      // `TestForuiApp.home`(页面级写法)够不到它,只有像 `bootstrap.dart` 那样
      // 把 `MediaQuery.textScaler` 放在 Navigator 之上,弹窗文本才会跟着放大。
      await tester.pumpWidget(
        scaledForTextScale(
          TestForuiApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => showAvatarCropper(context, bytes: bytes),
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

      final dialog = tester.getRect(find.byType(DialogShell));
      final confirm = tester.getRect(find.text('使用此头像'));
      expect(find.text('取消'), findsOneWidget);
      // 按钮行在弹窗内:溢出时它会被裁到弹窗下沿之外。
      expect(confirm.bottom, lessThanOrEqualTo(dialog.bottom));
      expect(confirm.top, greaterThanOrEqualTo(dialog.top));

      // 画布随可用高度收缩但仍保持 1:1,并且不越过设计上限:有空间时(360dp 视口)
      // 保持 320dp 设计边长,被宽度限住的 320dp 视口退成同宽的正方形。下限断言防止
      // 「按钮行不溢出」是靠把画布压没换来的。
      final canvas = tester.getRect(find.byType(Crop));
      expect(canvas.width, closeTo(canvas.height, 0.5));
      expect(canvas.height, lessThanOrEqualTo(320));
      expect(canvas.height, greaterThanOrEqualTo(240));
    });
  }
}

/// 只有 PNG 的 8 字节签名:这两条用例只验证布局,不依赖画布解码成功。
const List<int> _pngHeader = <int>[
  0x89,
  0x50,
  0x4e,
  0x47,
  0x0d,
  0x0a,
  0x1a,
  0x0a,
];
