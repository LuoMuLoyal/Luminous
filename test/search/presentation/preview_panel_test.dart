import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';
import 'package:luminous/features/search/presentation/providers/medicine_search.dart';
import 'package:luminous/features/search/presentation/widgets/shared/results.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';

void main() {
  group('PreviewPanel', () {
    testWidgets('preview with conditions/checklist renders no clinical or '
        'safety labels', (tester) async {
      const state = MedicineSearchState(
        detailPreview: MedicineSearchSafetyPreview(
          title: '[DEMO] 布洛芬片',
          // 旧造假映射的典型输入：subtitle 按 \n 拆分 + 恒空 checklist。
          conditions: ['0.2g*12片', '石药集团欧意药业有限公司'],
          checklist: ['[DEMO] 已阅读示例说明'],
        ),
      );

      await _pumpPanel(tester, state);

      // 面板标题与所选药品标题保留。
      expect(find.text('选中项预览'), findsOneWidget);
      expect(find.text('[DEMO] 布洛芬片'), findsOneWidget);
      // 不再出现「临床提示 / 安全确认」标签与包装信息行（F-11 去造假）。
      expect(find.text('临床提示'), findsNothing);
      expect(find.text('安全确认'), findsNothing);
      expect(find.text('0.2g*12片'), findsNothing);
      expect(find.text('石药集团欧意药业有限公司'), findsNothing);
      expect(find.text('[DEMO] 已阅读示例说明'), findsNothing);
      // 空态文案不出现（preview 非空）。
      expect(find.text('选择一个药品查看详情'), findsNothing);
    });

    testWidgets('preview null keeps the structured empty state', (
      tester,
    ) async {
      const state = MedicineSearchState();

      await _pumpPanel(tester, state);

      expect(find.text('选中项预览'), findsOneWidget);
      expect(find.text('选择一个药品查看详情'), findsOneWidget);
    });
  });
}

Future<void> _pumpPanel(WidgetTester tester, MedicineSearchState state) async {
  await tester.pumpWidget(
    TestForuiApp(
      home: Scaffold(
        body: Builder(
          builder: (context) =>
              PreviewPanel(state: state, l10n: AppLocalizations.of(context)!),
        ),
      ),
    ),
  );
  await tester.pump();
}
