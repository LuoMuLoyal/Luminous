import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/widgets/sections/preview/trend.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';
import '../../helpers/test_helpers.dart';

/// 真机回归（英文、≈393dp 逻辑宽）：趋势卡页脚的数据窗口直接透出契约 ISO 串
/// （`2026-09-28T00:00:00.000Z`），用户看到 `2026-09-28T00:00:00.000Z – 2026-1…`
/// 且 `RIGHT OVERFLOWED BY 124 PIXELS`。窗口边界是后端按本地日期字面量生成的
/// （见 `reviewWindowDateLabel`），必须先本地化再上屏；页脚原先是
/// `Row(Expanded(覆盖率文本), 非 flex 的窗口文本)`，尾部文本拿无界主轴约束，
/// 窄屏 + 1.3 字缩放下只能右溢出。
///
/// 两条断言分别锁住两个缺陷：窗口标签里不得出现 `T00:00:00` / `Z`，且
/// 360dp / 320dp 两个真机逻辑宽下都不得有 `RenderFlex overflowed`。
void main() {
  const viewports = <(String, void Function(WidgetTester))>[
    ('compact 360x800', setCompactPhoneScreenSize),
    ('narrow 320x720', setNarrowPhoneScreenSize),
  ];

  for (final (label, apply) in viewports) {
    testWidgets('trend card footer is localized and fits $label at 1.3x', (
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

      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      await tester.pumpWidget(
        TestForuiApp(
          locale: const Locale('en'),
          home: scaledForTextScale(
            Scaffold(
              body: SingleChildScrollView(
                child: ReviewTrendSection(
                  trends: const [
                    ReviewTrendSeries(
                      kind: ReviewDataKind.water,
                      color: SemanticColor.primary,
                      unit: 'L',
                      values: [1.0, 1.1, 1.2, 1.0, 1.3, 1.1, 1.2],
                      currentValue: '1.2',
                      observedMetric: ReviewObservedMetric(
                        value: 1.2,
                        state: ReviewObservedMetricState.observed,
                        coverage: ReviewObservedMetricCoverage.sufficient,
                        sources: [ReviewObservedMetricSource.manual],
                        observedCount: 4,
                        expectedCount: 7,
                        // 契约原文：ISO 时间戳形式的窗口边界。
                        windowStart: '2026-09-28T00:00:00.000Z',
                        windowEnd: '2026-10-04T00:00:00.000Z',
                      ),
                    ),
                  ],
                  selectedQuery: const ReviewDashboardQuery(
                    range: ReviewDashboardRange.last7Days,
                  ),
                  onQueryChanged: (_) {},
                  l10n: l10n,
                  startDate: '2026-09-28',
                  showRangePill: false,
                ),
              ),
            ),
            1.3,
          ),
        ),
      );
      await tester.pump();

      // 断言前先还原：自定义 onError 仍挂着时抛断言会让 binding 报
      // `_pendingExceptionDetails != null` 而不是给出溢出原因。
      FlutterError.onError = previous;

      expect(
        overflows,
        isEmpty,
        reason: overflows.map((d) => d.exceptionAsString()).join('\n---\n'),
      );

      // 页脚确实渲染了（否则下面的断言会因为组件缺席而假通过）。
      expect(find.textContaining('of 7 days recorded'), findsOneWidget);

      // 窗口标签必须是人话日期，不得透出契约 ISO 串。
      expect(find.textContaining('T00:00:00'), findsNothing);
      final rendered = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data ?? '')
          .join('\n');
      expect(rendered, isNot(contains('T00:00:00')));
      expect(rendered, isNot(contains('Z')));
      expect(find.text('Sep 28 – Oct 4'), findsOneWidget);
    });
  }
}
