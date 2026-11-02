import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

import '../../helpers/kv_test_store.dart';
import '../../helpers/test_forui_app.dart';

/// Pumps the app Forui theme (with the `SemanticColors` extension injected)
/// and returns a context under it, so the style factory can resolve both
/// `FColors` and semantic tones.
Future<BuildContext> _themedContext(WidgetTester tester) async {
  await tester.pumpWidget(
    TestForuiApp(
      home: Builder(
        builder: (context) =>
            const SizedBox(key: Key('markdown-style-context')),
      ),
    ),
  );
  return tester.element(find.byKey(const Key('markdown-style-context')));
}

void main() {
  setUp(() {
    KvTestStore.install();
  });

  testWidgets('legal 样式：正文 md、行高 1.7', (tester) async {
    final context = await _themedContext(tester);
    final sheet = MarkdownStyle.legal(context);
    // 长文正文固定 16px：紧凑字阶下对应 body.md（此前用 sm，在紧凑字阶下只有
    // 14px，长文偏小）。
    expect(sheet.p?.fontSize, 16);
    expect(sheet.p?.fontSize, context.theme.typography.body.md.fontSize);
    expect(sheet.p?.height, 1.7);
    // 标题仍高于正文。
    expect(sheet.h1!.fontSize, greaterThan(sheet.p!.fontSize!));
    expect(sheet.h2!.fontSize, greaterThan(sheet.p!.fontSize!));
  });

  testWidgets('ai 样式：blockquote 使用 primary 色左条 4px 与 subtle 底色', (
    tester,
  ) async {
    final context = await _themedContext(tester);
    final sheet = MarkdownStyle.ai(context);
    final decoration = sheet.blockquoteDecoration;
    expect(decoration, isNotNull);
    expect(decoration, isA<BoxDecoration>());
    final box = decoration as BoxDecoration;
    expect(box.color, SemanticColor.primary.subtle(context));
    final border = box.border as Border;
    expect(border.left.width, 4);
    expect(border.left.color, context.theme.colors.primary);
    // 带底色后四边都有 padding，不再只留左侧。
    expect(sheet.blockquotePadding?.left, Spacing.md);
    expect(sheet.blockquotePadding?.top, Spacing.sm);
    expect(sheet.blockquotePadding?.right, Spacing.md);
    expect(sheet.blockquotePadding?.bottom, Spacing.sm);
  });

  testWidgets('ai 样式：h1-h6 字号阶梯递减', (tester) async {
    final context = await _themedContext(tester);
    final sheet = MarkdownStyle.ai(context);

    expect(sheet.h1?.fontSize, greaterThan(sheet.h2!.fontSize!));
    expect(sheet.h2?.fontSize, greaterThan(sheet.h3!.fontSize!));
    expect(sheet.h3?.fontSize, greaterThan(sheet.h4!.fontSize!));
    expect(sheet.h4?.fontSize, greaterThan(sheet.h5!.fontSize!));
    // h5/h6 同字号；h6 回到正文字重收尾（两档制：正文 w400 / 强调 w700）。
    expect(sheet.h5?.fontSize, sheet.h6?.fontSize);
    expect(sheet.h5?.fontWeight, FontWeight.w700);
    expect(sheet.h6?.fontWeight, FontWeight.w400);
    // 与 Forui 阶梯一致：h4→xs (14)、h5/h6→xs2 (12)。
    expect(sheet.h4?.fontSize, context.theme.typography.body.xs.fontSize);
    expect(sheet.h5?.fontSize, context.theme.typography.body.xs2.fontSize);
    expect(sheet.h6?.fontSize, context.theme.typography.body.xs2.fontSize);
  });

  testWidgets('ai 样式：列表缩进走 token、表格用 IntrinsicColumnWidth 支持窄屏横向滚动', (
    tester,
  ) async {
    final context = await _themedContext(tester);
    final sheet = MarkdownStyle.ai(context);

    expect(sheet.listIndent, Spacing.xl);
    expect(sheet.listBulletPadding?.right, Spacing.sm);
    expect(sheet.listBullet?.color, context.theme.colors.primary);
    // flutter_markdown_plus 仅在列宽为 Intrinsic/Fixed 时把表格包进横向滚动容器。
    expect(sheet.tableColumnWidth, isA<IntrinsicColumnWidth>());
    expect(sheet.tableBorder, isNotNull);
    expect(sheet.tableHeadCellsDecoration, isNotNull);
  });

  testWidgets('ai 样式支持 paragraphWeight 参数', (tester) async {
    final context = await _themedContext(tester);
    final sheet = MarkdownStyle.ai(context, paragraphWeight: FontWeight.w700);
    expect(sheet.p?.fontWeight, FontWeight.w700);
  });
}
