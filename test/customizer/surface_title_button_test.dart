import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/widgets/common/control/surface_title_button.dart';

import '../helpers/test_forui_app.dart';

/// 标题按钮的全部职责：显示标题；有编排入口时点一下打开**这一页**的编排页。
void main() {
  Widget wrap(Widget child) => TestForuiApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('the title is plain text when no customizer is wired', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const SurfaceTitleButton(
          surface: SurfaceId.medicine,
          title: '用药',
          open: null,
        ),
      ),
    );

    expect(find.text('用药'), findsOneWidget);
    expect(find.byKey(const Key('surface-title-medicine')), findsNothing);
  });

  testWidgets('tapping the title opens the customizer of its own surface', (
    tester,
  ) async {
    SurfaceId? opened;
    await tester.pumpWidget(
      wrap(
        SurfaceTitleButton(
          surface: SurfaceId.medicine,
          title: '用药',
          open: (context, surface) => opened = surface,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('surface-title-medicine')));
    // Forui 的按下/抬起各带一个 100ms 定时器，收起前必须先走完。
    await tester.pumpAndSettle();

    expect(opened, SurfaceId.medicine);
  });
}
