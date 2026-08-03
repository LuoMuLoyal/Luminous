import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

void main() {
  testWidgets('legal 样式：正文 level4、行高 1.7', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final sheet = MarkdownStyle.legal(context);
            return SizedBox(child: Text('x', style: sheet.p));
          },
        ),
      ),
    );
    final context = tester.element(find.byType(SizedBox));
    final sheet = MarkdownStyle.legal(context);
    expect(sheet.p?.fontSize, 16);
    expect(sheet.p?.height, 1.7);
  });

  testWidgets('ai 样式：blockquote 使用 primary 色左条 4px', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return const SizedBox();
          },
        ),
      ),
    );
    final context = tester.element(find.byType(SizedBox));
    final sheet = MarkdownStyle.ai(context);
    final decoration = sheet.blockquoteDecoration;
    expect(decoration, isNotNull);
    expect(decoration, isA<BoxDecoration>());
    final border = (decoration as BoxDecoration).border as Border;
    expect(border.left.width, 4);
    expect(border.left.color, context.theme.colors.primary);
  });

  testWidgets('ai 样式支持 paragraphWeight 参数', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return const SizedBox();
          },
        ),
      ),
    );
    final context = tester.element(find.byType(SizedBox));
    final sheet = MarkdownStyle.ai(context, paragraphWeight: FontWeight.w700);
    expect(sheet.p?.fontWeight, FontWeight.w700);
  });
}
