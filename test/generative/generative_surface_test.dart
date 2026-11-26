// a2ui_flutter 的 basic catalog 组件建在 framework material 上（包内
// `Card` / `Button` / `TextField` 都 import `package:flutter/material.dart`），
// 类型断言必须对着 framework 类型。
// ignore_for_file: deprecated_member_use
import 'dart:convert';

import 'package:flutter/material.dart' as fw;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/composition/a2ui/a2ui.dart';
import 'package:luminous/features/generative/domain/entities/generation.dart';
import 'package:luminous/features/generative/presentation/widgets/generative_surface.dart';
import 'package:luminous/shared/domain/composition/surface.dart';

import '../helpers/test_forui_app.dart';

/// A2UI 1.0 验收：手写消息必须能渲染出组合布局，**且基础组件全量可用**。
///
/// 这条路径不接 LLM——消息是测试里手写的 JSON，正好模拟「后端已经给出一份序列」
/// 时客户端的行为。
void main() {
  const surfaceId = 'generative.review';

  /// 一份只用布局原语拼的树：Column > [Card(Text), Row(Text, Text), Divider]。
  const layoutMessages = <String>[
    '{"version":"1.0","createSurface":{"surfaceId":"generative.review",'
        '"catalogId":"${GenerativeCatalog.defaultCatalogId}"}}',
    '{"version":"1.0","updateComponents":{"surfaceId":"generative.review","components":['
        '{"id":"root","component":"Column","children":["header","card","stats","sep"]},'
        // v1.0 的 `Text.variant` 只接受 `caption` / `body`：h1–h5 是 v0.9 独有的
        // 东西，1.0 把标题层级交给组件组合而不是单一变体。
        '{"id":"header","component":"Text","text":"本周概览"},'
        '{"id":"card","component":"Card","child":"cardText"},'
        '{"id":"cardText","component":"Text","text":"饮水比上周多了 12%"},'
        '{"id":"stats","component":"Row","children":["s1","s2"]},'
        '{"id":"s1","component":"Text","text":"饮水 1800ml"},'
        '{"id":"s2","component":"Text","text":"睡眠 7.2h"},'
        '{"id":"sep","component":"Divider"}'
        ']}}',
  ];

  /// 含一个未知 type 的树：渲染应降级，不崩。
  const unknownComponentMessages = <String>[
    '{"version":"1.0","createSurface":{"surfaceId":"generative.review",'
        '"catalogId":"${GenerativeCatalog.defaultCatalogId}"}}',
    '{"version":"1.0","updateComponents":{"surfaceId":"generative.review","components":['
        '{"id":"root","component":"Column","children":["a","b"]},'
        '{"id":"a","component":"Text","text":"正常内容"},'
        '{"id":"b","component":"NoSuchComponent","foo":"bar"}'
        ']}}',
  ];

  /// A2UI 1.0 起 Button **在** catalog 里：agent 可以下发可写动作。
  const buttonMessages = <String>[
    '{"version":"1.0","createSurface":{"surfaceId":"generative.review",'
        '"catalogId":"${GenerativeCatalog.defaultCatalogId}"}}',
    '{"version":"1.0","updateComponents":{"surfaceId":"generative.review","components":['
        '{"id":"root","component":"Column","children":["btn","label"]},'
        '{"id":"btn","component":"Button","child":"btnLabel",'
        '"action":{"event":{"name":"delete_all"}}},'
        '{"id":"btnLabel","component":"Text","text":"删除全部记录"},'
        '{"id":"label","component":"Text","text":"可写动作"}'
        ']}}',
  ];

  /// 表单组件：TextField + CheckBox + Slider。
  const formMessages = <String>[
    '{"version":"1.0","createSurface":{"surfaceId":"generative.review",'
        '"catalogId":"${GenerativeCatalog.defaultCatalogId}"}}',
    '{"version":"1.0","updateComponents":{"surfaceId":"generative.review","components":['
        '{"id":"root","component":"Column","children":["field","check","slider"]},'
        '{"id":"field","component":"TextField","label":"药品名称",'
        '"value":{"@path":"/medicine"}},'
        '{"id":"check","component":"CheckBox","label":"每天固定时间",'
        '"value":{"@path":"/daily"}},'
        '{"id":"slider","component":"Slider","label":"剂量","min":0,"max":10,'
        '"value":{"@path":"/dose"}}'
        ']}}',
  ];

  /// catalog id 必须与本仓装配一致：v1.0 按 id 匹配 surface 的默认 catalog。
  GenerativeTransport transport() => GenerativeTransport(
    catalog: GenerativeCatalog(domainComponents: const []),
  );

  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      ProviderScope(
        child: TestForuiApp(home: fw.Scaffold(body: child)),
      ),
    );
    await tester.pump();
  }

  /// 把文档喂进渲染端并渲染。
  Future<void> render(
    WidgetTester tester,
    GenerativeTransport t,
    List<String> jsonl,
  ) async {
    final messages = [
      for (final line in jsonl) jsonDecode(line) as Map<String, Object?>,
    ];
    t.processMessages(messages);
    await pump(
      tester,
      GenerativeSurface(
        state: GenerationReady(
          GenerativeSurfaceDocument(
            surface: SurfaceId.review,
            messages: messages,
            generatedAt: DateTime(2026),
          ),
        ),
        transport: t,
        surfaceId: surfaceId,
      ),
    );
  }

  group('渲染链路', () {
    testWidgets('手写消息渲染出 Column/Card/Row/Text 组合', (tester) async {
      final t = transport();
      addTearDown(t.dispose);

      await render(tester, t, layoutMessages);

      expect(
        t.activeSurfaceIds,
        contains(surfaceId),
        reason: 'createSurface 之后渲染端该有这个 surface',
      );

      // 四个叶子文本都在树上——说明 Column / Card / Row 都被正确展开。
      expect(find.text('本周概览'), findsOneWidget);
      expect(find.text('饮水比上周多了 12%'), findsOneWidget);
      expect(find.text('饮水 1800ml'), findsOneWidget);
      expect(find.text('睡眠 7.2h'), findsOneWidget);
      expect(find.byType(fw.Card), findsWidgets);
      // v1.0 的 Row / Column 由自定义的 `Flex` 实现（带 weight / ownWidth 布局
      // 规则），不是 Material 的 `Row` / `Column` widget。
      expect(find.byType(fw.Flex), findsWidgets);
    });

    testWidgets('未知 component 降级渲染，不崩溃', (tester) async {
      final t = transport();
      addTearDown(t.dispose);

      await render(tester, t, unknownComponentMessages);

      expect(tester.takeException(), isNull);
      expect(find.text('正常内容'), findsOneWidget);
    });
  });

  group('A2UI 1.0：交互组件全量可用', () {
    testWidgets('Button 能渲染出来（不再被白名单剔除）', (tester) async {
      final t = transport();
      addTearDown(t.dispose);

      await render(tester, t, buttonMessages);

      expect(find.text('删除全部记录'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('TextField / CheckBox / Slider 都能渲染', (tester) async {
      final t = transport();
      addTearDown(t.dispose);

      await render(tester, t, formMessages);

      expect(find.byType(fw.TextField), findsWidgets);
      expect(find.byType(fw.Checkbox), findsWidgets);
      expect(find.byType(fw.Slider), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('三态渲染', () {
    testWidgets('没有生成结果 → 返回 null（不占位置）', (tester) async {
      final t = transport();
      addTearDown(t.dispose);

      await pump(
        tester,
        GenerativeSurface(
          state: const GenerationIdle(),
          transport: t,
          surfaceId: surfaceId,
        ),
      );

      expect(
        find.byKey(const Key('generative-surface-skeleton')),
        findsNothing,
      );
      expect(
        tester.getSize(find.byType(GenerativeSurface)),
        Size.zero,
        reason: '默认布局要干净：没生成过时不该占任何空间',
      );
    });

    testWidgets('正在生成 → 骨架', (tester) async {
      final t = transport();
      addTearDown(t.dispose);

      await pump(
        tester,
        GenerativeSurface(
          state: const GenerationInFlight(),
          transport: t,
          surfaceId: surfaceId,
        ),
      );

      expect(
        find.byKey(const Key('generative-surface-skeleton')),
        findsOneWidget,
      );
    });

    testWidgets('失败但保留上一份结果 → 继续渲染上一份', (tester) async {
      final t = transport();
      addTearDown(t.dispose);

      final messages = [
        for (final l in layoutMessages) jsonDecode(l) as Map<String, Object?>,
      ];
      t.processMessages(messages);

      await pump(
        tester,
        GenerativeSurface(
          state: GenerationFailed(
            error: StateError('boom'),
            document: GenerativeSurfaceDocument(
              surface: SurfaceId.review,
              messages: messages,
              generatedAt: DateTime(2026),
            ),
          ),
          transport: t,
          surfaceId: surfaceId,
        ),
      );

      expect(find.text('本周概览'), findsOneWidget);
      expect(
        find.byKey(const Key('generative-surface-skeleton')),
        findsNothing,
        reason: '失败不是「正在生成」，不该给骨架',
      );
    });
  });

  group('三个横排小卡', () {
    const threeCardsMessages = <String>[
      '{"version":"1.0","createSurface":{"surfaceId":"generative.review",'
          '"catalogId":"${GenerativeCatalog.defaultCatalogId}"}}',
      '{"version":"1.0","updateComponents":{"surfaceId":"generative.review","components":['
          '{"id":"root","component":"Column","children":["cards"]},'
          '{"id":"cards","component":"Row","children":["c1","c2","c3"]},'
          '{"id":"c1","component":"Card","child":"t1"},'
          '{"id":"t1","component":"Text","text":"饮水 1800 ml"},'
          '{"id":"c2","component":"Card","child":"t2"},'
          '{"id":"t2","component":"Text","text":"睡眠 7.2 h"},'
          '{"id":"c3","component":"Card","child":"t3"},'
          '{"id":"t3","component":"Text","text":"依从率 82%"}'
          ']}}',
    ];

    testWidgets('三张卡并排渲染，且都在同一行', (tester) async {
      final t = transport();
      addTearDown(t.dispose);

      await render(tester, t, threeCardsMessages);

      expect(find.text('饮水 1800 ml'), findsOneWidget);
      expect(find.text('睡眠 7.2 h'), findsOneWidget);
      expect(find.text('依从率 82%'), findsOneWidget);

      // 卡片确实并排：三者纵向位置相同，横向依次递增。
      final y1 = tester.getCenter(find.text('饮水 1800 ml')).dy;
      final y2 = tester.getCenter(find.text('睡眠 7.2 h')).dy;
      final y3 = tester.getCenter(find.text('依从率 82%')).dy;
      expect((y1 - y2).abs(), lessThan(1.0), reason: '三张卡必须在同一行');
      expect((y2 - y3).abs(), lessThan(1.0), reason: '三张卡必须在同一行');

      final x1 = tester.getCenter(find.text('饮水 1800 ml')).dx;
      final x2 = tester.getCenter(find.text('睡眠 7.2 h')).dx;
      final x3 = tester.getCenter(find.text('依从率 82%')).dx;
      expect(x1, lessThan(x2));
      expect(x2, lessThan(x3));
    });
  });
}
