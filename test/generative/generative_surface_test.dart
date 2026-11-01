import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/composition/genui/genui.dart';
import 'package:luminous/features/generative/domain/entities/generation.dart';
import 'package:luminous/features/generative/presentation/widgets/generative_surface.dart';
import 'package:luminous/shared/domain/composition/surface.dart';

import '../helpers/test_forui_app.dart';

/// A7a 验收：手写 A2UI 消息必须能渲染出组合布局。
///
/// 这条路径不接 LLM——消息是测试里手写的 JSON 行，正好模拟「后端已经给出一
/// 份序列」时客户端的行为。A7b 把这份序列换成 SSE 流，渲染层不变。
void main() {
  /// 一份只用展示原语拼的树：Column > [Card(Text), Row(Text, Text), Divider]。
  ///
  /// 覆盖验收里的「手写消息渲染出 Column/Row/Card/Text 组合」。
  const layoutMessages = <String>[
    '{"version":"v0.9","createSurface":{"surfaceId":"generative.review","catalogId":"com.luminous.generative"}}',
    '{"version":"v0.9","updateComponents":{"surfaceId":"generative.review","components":['
        '{"id":"root","component":"Column","children":["header","card","stats","sep"]},'
        '{"id":"header","component":"Text","text":"本周概览","variant":"h4"},'
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
    '{"version":"v0.9","createSurface":{"surfaceId":"generative.review","catalogId":"com.luminous.generative"}}',
    '{"version":"v0.9","updateComponents":{"surfaceId":"generative.review","components":['
        '{"id":"root","component":"Column","children":["a","b"]},'
        '{"id":"a","component":"Text","text":"正常内容"},'
        '{"id":"b","component":"NoSuchComponent","foo":"bar"}'
        ']}}',
  ];

  /// 被 catalog 剔除的可写控件：不应渲染出交互元素。
  const forbiddenMessages = <String>[
    '{"version":"v0.9","createSurface":{"surfaceId":"generative.review","catalogId":"com.luminous.generative"}}',
    '{"version":"v0.9","updateComponents":{"surfaceId":"generative.review","components":['
        '{"id":"root","component":"Column","children":["btn"]},'
        '{"id":"btn","component":"Button","action":"submit","label":"删除全部记录"}'
        ']}}',
  ];

  /// 把 JSONL 喂进 transport。
  ///
  /// 只断言「surface 已经创建」——`SurfaceContext` 是 `genui` 的内部类型，本仓
  /// 的测试不该依赖它（这也正是把 `genui` 关在 `core/composition/genui/` 里
  /// 的意义）。
  void feed(GenerativeTransport transport, List<String> lines) {
    for (final line in lines) {
      transport.feedJsonLine(line);
    }
  }

  /// catalog id 必须与消息里 `createSurface.catalogId` 一致：`genui` 按 id
  /// 把 surface 匹配回它的 catalog，对不上就不渲染任何组件（不报错，只是空）。
  GenerativeTransport transport() => GenerativeTransport(
    catalog: GenerativeCatalog(
      catalogId: 'com.luminous.generative',
      domainItems: const [],
    ),
  );

  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      ProviderScope(
        child: TestForuiApp(home: Scaffold(body: child)),
      ),
    );
    await tester.pump();
  }

  group('渲染链路', () {
    testWidgets('手写消息渲染出 Column/Card/Row/Text 组合', (tester) async {
      final t = transport();
      addTearDown(t.dispose);
      feed(t, layoutMessages);

      expect(
        t.activeSurfaceIds,
        contains('generative.review'),
        reason: 'createSurface 之后引擎里该有这个 surface',
      );

      await pump(
        tester,
        GenerativeSurface(
          state: GenerationReady(
            GenerativeSurfaceDocument(
              surface: SurfaceId.review,
              messages: [
                for (final l in layoutMessages)
                  jsonDecode(l) as Map<String, Object?>,
              ],
              generatedAt: DateTime(2026),
            ),
          ),
          transport: t,
          surfaceId: 'generative.review',
        ),
      );

      // 四个叶子文本都在树上——说明 Column / Card / Row 都被正确展开。
      expect(find.text('本周概览'), findsOneWidget);
      expect(find.text('饮水比上周多了 12%'), findsOneWidget);
      expect(find.text('饮水 1800ml'), findsOneWidget);
      expect(find.text('睡眠 7.2h'), findsOneWidget);
      // Card 与 Row 确实参与布局（不是被拍平成一段文本）。
      expect(find.byType(Card), findsWidgets);
      expect(find.byType(Row), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('未知 component 降级渲染，不崩溃', (tester) async {
      final t = transport();
      addTearDown(t.dispose);
      feed(t, unknownComponentMessages);

      await pump(
        tester,
        GenerativeSurface(
          state: GenerationReady(
            GenerativeSurfaceDocument(
              surface: SurfaceId.review,
              messages: [
                for (final l in unknownComponentMessages)
                  jsonDecode(l) as Map<String, Object?>,
              ],
              generatedAt: DateTime(2026),
            ),
          ),
          transport: t,
          surfaceId: 'generative.review',
        ),
      );

      expect(tester.takeException(), isNull);
      // 合法的兄弟节点照常渲染：一棵坏树只坏自己那一支。
      expect(find.text('正常内容'), findsOneWidget);
    });

    testWidgets('Button 不在 catalog 里，查不到即降级', (tester) async {
      final t = transport();
      addTearDown(t.dispose);
      feed(t, forbiddenMessages);

      await pump(
        tester,
        GenerativeSurface(
          state: GenerationReady(
            GenerativeSurfaceDocument(
              surface: SurfaceId.review,
              messages: [
                for (final l in forbiddenMessages)
                  jsonDecode(l) as Map<String, Object?>,
              ],
              generatedAt: DateTime(2026),
            ),
          ),
          transport: t,
          surfaceId: 'generative.review',
        ),
      );

      // 核心断言：可写动作没有出现在屏幕上。
      expect(find.widgetWithText(FilledButton, '删除全部记录'), findsNothing);
      expect(find.widgetWithText(ElevatedButton, '删除全部记录'), findsNothing);
      expect(find.text('删除全部记录'), findsNothing);
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
          surfaceId: 'generative.review',
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
          surfaceId: 'generative.review',
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
      feed(t, layoutMessages);

      await pump(
        tester,
        GenerativeSurface(
          state: GenerationFailed(
            error: StateError('boom'),
            document: GenerativeSurfaceDocument(
              surface: SurfaceId.review,
              messages: [
                for (final l in layoutMessages)
                  jsonDecode(l) as Map<String, Object?>,
              ],
              generatedAt: DateTime(2026),
            ),
          ),
          transport: t,
          surfaceId: 'generative.review',
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

  // ── 三个横排小卡 ──────────────────────────────────────────────────
  //
  // 这是「一张图看懂生成式 UI 能干什么」的最小形态：三张并排的卡，每张一句
  // 短指标。结构只用展示原语（Row + Card + Text），不依赖任何领域 item，
  // 因此与 review 的数据源无关——在哪个 surface 上都渲染得出来。
  group('三个横排小卡', () {
    const threeCardsMessages = <String>[
      '{"version":"v0.9","createSurface":{"surfaceId":"generative.review","catalogId":"com.luminous.generative"}}',
      '{"version":"v0.9","updateComponents":{"surfaceId":"generative.review","components":['
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
      feed(t, threeCardsMessages);

      await pump(
        tester,
        GenerativeSurface(
          state: GenerationReady(
            GenerativeSurfaceDocument(
              surface: SurfaceId.review,
              messages: [
                for (final l in threeCardsMessages)
                  jsonDecode(l) as Map<String, Object?>,
              ],
              generatedAt: DateTime(2026),
            ),
          ),
          transport: t,
          surfaceId: 'generative.review',
        ),
      );

      // 三句文案都在树上——说明 Row 的三个子节点都渲染了。
      expect(find.text('饮水 1800 ml'), findsOneWidget);
      expect(find.text('睡眠 7.2 h'), findsOneWidget);
      expect(find.text('依从率 82%'), findsOneWidget);

      // 卡片确实并排：三者纵向位置相同，横向依次递增。
      // 这是「横排」与「竖排」的唯一可断言区别——只查文案在不在树上，
      // 竖排的写法也能通过。
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
