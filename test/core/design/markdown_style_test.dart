import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

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
  testWidgets('legal 样式：正文 level4、行高 1.7', (tester) async {
    final context = await _themedContext(tester);
    final sheet = MarkdownStyle.legal(context);
    expect(sheet.p?.fontSize, 16);
    expect(sheet.p?.height, 1.7);
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
    expect(sheet.blockquotePadding?.left, Spacing.level3);
    expect(sheet.blockquotePadding?.top, Spacing.level2);
    expect(sheet.blockquotePadding?.right, Spacing.level3);
    expect(sheet.blockquotePadding?.bottom, Spacing.level2);
  });

  testWidgets('ai 样式：h1-h6 字号阶梯递减', (tester) async {
    final context = await _themedContext(tester);
    final sheet = MarkdownStyle.ai(context);

    expect(sheet.h1?.fontSize, greaterThan(sheet.h2!.fontSize!));
    expect(sheet.h2?.fontSize, greaterThan(sheet.h3!.fontSize!));
    expect(sheet.h3?.fontSize, greaterThan(sheet.h4!.fontSize!));
    expect(sheet.h4?.fontSize, greaterThan(sheet.h5!.fontSize!));
    // h5/h6 同字号，h6 降一档字重收尾。
    expect(sheet.h5?.fontSize, sheet.h6?.fontSize);
    expect(sheet.h5?.fontWeight, FontWeight.w600);
    expect(sheet.h6?.fontWeight, FontWeight.w500);
    // 与 TypographyToken 阶梯一致：h4→level3 (14)、h5/h6→level2 (12)。
    expect(sheet.h4?.fontSize, TypographyToken.level3.body(context).fontSize);
    expect(sheet.h5?.fontSize, TypographyToken.level2.body(context).fontSize);
    expect(sheet.h6?.fontSize, TypographyToken.level2.body(context).fontSize);
  });

  testWidgets('ai 样式：列表缩进走 token、表格用 IntrinsicColumnWidth 支持窄屏横向滚动', (
    tester,
  ) async {
    final context = await _themedContext(tester);
    final sheet = MarkdownStyle.ai(context);

    expect(sheet.listIndent, Spacing.level5);
    expect(sheet.listBulletPadding?.right, Spacing.level2);
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
