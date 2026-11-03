import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/shell/presentation/desktop_tab_shell.dart';
import 'package:luminous/features/shell/presentation/detail_pane.dart';
import 'package:luminous/features/shell/presentation/detail_pane_state.dart';
import 'package:luminous/features/shell/presentation/page.dart';

import '../helpers/kv_test_store.dart';
import '../helpers/test_forui_app.dart';
import '../helpers/test_helpers.dart';

/// 桌面右侧详情面板的开关与布局。
///
/// 这里断言的是**结构事实**：关闭时面板不占位、内容区吃满宽度；打开时内容区
/// 让出宽度并在右侧出现面板；关闭后宽度复原。面板内渲染什么（药品详情）由
/// medicine 自己的 fixture 决定，不在这一层测。
void main() {
  setUpAll(() {
    KvTestStore.install(seed: const <String, Object>{});
  });

  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              ShellPage(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const DesktopTabShell(
                    title: 'Shell probe',
                    // 探针必须是**可测量**的：裸 `SizedBox` 在无约束的滚动容器里
                    // 会被布局成零宽，`getRect` 量到的宽度恒为 0，断言就失去意义。
                    // 用一个吃满宽度的卡片代替它。
                    child: SizedBox(
                      key: Key('probe-content'),
                      width: double.infinity,
                      height: 100,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future<ProviderContainer> pumpShell(WidgetTester tester) async {
    setDesktopScreenSize(tester);
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestForuiRouterApp(routerConfig: buildRouter()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    return container;
  }

  double contentWidth(WidgetTester tester) =>
      tester.getRect(find.byKey(const Key('probe-content'))).width;

  testWidgets('panel starts closed', (tester) async {
    final container = await pumpShell(tester);
    expect(find.byType(DesktopDetailPane), findsOneWidget);
    expect(container.read(detailPaneProvider), isNull);
  });

  testWidgets('content keeps full width while closed', (tester) async {
    await pumpShell(tester);

    final screen =
        tester.view.physicalSize.width / tester.view.devicePixelRatio;
    final layout = LayoutScaleResolver.resolve(screen);
    // 关闭态内容区吃满「设计内容列」：桌面壳把内容收口到 min(可用宽度,
    // maxContentWidth)，再扣掉两侧页边距；面板关闭时不再额外让位。
    // 不按屏幕比例卡死——桌面档的 maxContentWidth 是 1040，屏幕再宽内容列
    // 也停在这个值（见 layout_scale.dart 的 _desktop 注释）。
    final available = tester.getRect(find.byType(DesktopTabShell)).width;
    expect(
      contentWidth(tester),
      closeTo(
        math.min(available, layout.maxContentWidth) -
            2 * layout.pageHorizontalPadding,
        0.1,
      ),
    );
  });

  testWidgets('opening the pane shrinks the content area', (tester) async {
    final container = await pumpShell(tester);
    final before = contentWidth(tester);

    container
        .read(detailPaneProvider.notifier)
        .open(const MedicineDetailTarget(source: 'cn', id: 'probe'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      contentWidth(tester),
      lessThan(before),
      reason: '面板打开后内容区必须让出宽度，否则面板是叠在内容上的',
    );
  });

  testWidgets('closing the pane restores the content width', (tester) async {
    final container = await pumpShell(tester);
    final before = contentWidth(tester);

    container
        .read(detailPaneProvider.notifier)
        .open(const MedicineDetailTarget(source: 'cn', id: 'probe'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    container.read(detailPaneProvider.notifier).close();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(contentWidth(tester), closeTo(before, 1.0));
  });
}
