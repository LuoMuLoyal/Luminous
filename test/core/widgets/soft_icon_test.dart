import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui_phosphor/forui_phosphor.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/control/soft_icon.dart';

import '../../helpers/test_forui_app.dart';

/// SoftIcon 的渲染契约测试(2026-08-30 审查 W-3)。
///
/// SoftIcon.build 对非法 icon 类型 fail-loud(`throw StateError`)。调用点
/// 审计结论(2026-09-02):全仓 6 处调用 icon 参数静态类型均为 `IconData`,
/// throw 分支当前不可达;本测试锁定「合法输入正常渲染 + 非法输入 release
/// 下显式抛错(而非静默渲染空白)」的契约,防止未来放宽类型后回归。
void main() {
  Future<void> pumpSoftIcon(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(TestForuiApp(home: Center(child: child)));
    await tester.pump();
  }

  testWidgets('IconData renders as a plain Icon', (tester) async {
    await pumpSoftIcon(
      tester,
      const SoftIcon(icon: Icons.favorite, color: SemanticColor.primary),
    );

    expect(find.byType(Icon), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('duotone + FPhosphorDuotoneIconData renders duotone icon', (
    tester,
  ) async {
    await pumpSoftIcon(
      tester,
      const SoftIcon(
        duotone: true,
        icon: FPhosphorDuotoneIcons.acorn,
        color: SemanticColor.primary,
      ),
    );

    expect(find.byType(FPhosphorDuotoneIcon), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('duotone=true with plain IconData degrades to plain Icon', (
    tester,
  ) async {
    // 设计语义:duotone 仅在 icon 是 FPhosphorDuotoneIconData 时生效,
    // 普通 IconData 降级为普通 Icon 而不是抛错。
    await pumpSoftIcon(
      tester,
      const SoftIcon(
        duotone: true,
        icon: Icons.favorite,
        color: SemanticColor.primary,
      ),
    );

    expect(find.byType(Icon), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('non-IconData icon throws StateError naming the runtimeType', (
    tester,
  ) async {
    await pumpSoftIcon(
      tester,
      // 故意传非法类型(等价于第三方 plugin 返回错误对象),验证
      // fail-loud 契约:错误信息必须带 runtimeType 便于定位。
      // ignore: avoid_redundant_argument_values
      const SoftIcon(icon: 'not-an-icon', color: SemanticColor.primary),
    );

    final exception = tester.takeException();
    expect(exception, isA<StateError>());
    expect((exception as StateError).message, contains('String'));
  });
}
