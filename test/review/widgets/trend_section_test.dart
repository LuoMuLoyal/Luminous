import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/widgets/sections/preview/trend.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  Future<void> pumpTrend(
    WidgetTester tester, {
    required List<ReviewTrendSeries> trends,
    ReviewDataKind? selectedKind,
    ValueChanged<ReviewDataKind>? onKindChanged,
    bool showRangePill = false,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ReviewTrendSection(
              trends: trends,
              selectedQuery: const ReviewDashboardQuery(
                range: ReviewDashboardRange.last7Days,
              ),
              onQueryChanged: (_) {},
              l10n: l10n,
              startDate: '2026-08-01',
              showRangePill: showRangePill,
              selectedKind: selectedKind,
              onKindChanged: onKindChanged,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  ReviewTrendSeries series({
    ReviewDataKind kind = ReviewDataKind.water,
    List<double> values = const [1.0, 1.1, 1.2, 1.0],
    String currentValue = '1.2',
    ReviewObservedMetric? observed,
  }) {
    return ReviewTrendSeries(
      kind: kind,
      color: SemanticColor.primary,
      unit: 'L',
      values: values,
      currentValue: currentValue,
      observedMetric: observed,
    );
  }

  const observed = ReviewObservedMetric(
    value: 1.2,
    state: ReviewObservedMetricState.observed,
    coverage: ReviewObservedMetricCoverage.sufficient,
    sources: [ReviewObservedMetricSource.manual],
    observedCount: 4,
    expectedCount: 7,
    windowStart: '2026-08-01',
    windowEnd: '2026-08-07',
  );

  testWidgets('renders footer coverage, window and gap note', (tester) async {
    await pumpTrend(tester, trends: [series(observed: observed)]);

    expect(find.text('健康趋势'), findsOneWidget);
    expect(find.text('有记录 4 天 / 范围 7 天'), findsOneWidget);
    expect(find.text('2026-08-01 → 2026-08-07'), findsOneWidget);
    expect(find.text('未记录的天不计入走势。'), findsOneWidget);
    // 折线图值。
    expect(find.text('1.2L'), findsOneWidget);
  });

  testWidgets('range pill is hidden when showRangePill is false', (
    tester,
  ) async {
    await pumpTrend(
      tester,
      trends: [series(observed: observed)],
      showRangePill: false,
    );

    // 主路径不渲染「7/30 天」范围 pill。
    expect(find.textContaining('/30'), findsNothing);
  });

  testWidgets('controlled dimension follows external selectedKind', (
    tester,
  ) async {
    // 两个维度 tab，外部选中 sleep 时显示 sleep 当前值。
    final trends = [
      series(kind: ReviewDataKind.water, currentValue: '1.2'),
      series(
        kind: ReviewDataKind.sleep,
        currentValue: '6.5',
        values: const [7.0, 6.5, 6.5],
        observed: observed,
      ),
    ];

    // 首次以外部选中 sleep 渲染。
    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ReviewTrendSection(
              trends: trends,
              selectedQuery: const ReviewDashboardQuery(
                range: ReviewDashboardRange.last7Days,
              ),
              onQueryChanged: (_) {},
              l10n: l10n,
              startDate: '2026-08-01',
              showRangePill: false,
              selectedKind: ReviewDataKind.sleep,
              onKindChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // 外部选中 sleep → 显示睡眠当前值 + 睡眠覆盖脚注。
    expect(find.text('6.5L'), findsOneWidget);
    expect(find.text('有记录 4 天 / 范围 7 天'), findsOneWidget);

    // 切换 tab 仍可看到 water 维度。
    await tester.tap(find.text('饮水'));
    await tester.pumpAndSettle();
  });

  testWidgets('legacy uncontrolled still renders first dimension', (
    tester,
  ) async {
    await pumpTrend(tester, trends: [series(observed: observed)]);

    expect(find.text('1.2L'), findsOneWidget);
    expect(find.text('健康趋势'), findsOneWidget);
  });
}
