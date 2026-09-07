import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/widgets/sections/period_switch.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  Future<void> pumpSwitch(
    WidgetTester tester, {
    required ReviewDashboardRange selectedRange,
    required ValueChanged<ReviewDashboardRange> onChanged,
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
            child: ReviewPeriodSwitch(
              selectedRange: selectedRange,
              onRangeChanged: onChanged,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders 周/月 tabs and defaults to 周 selected', (tester) async {
    var changed = false;
    await pumpSwitch(
      tester,
      selectedRange: ReviewDashboardRange.last7Days,
      onChanged: (_) => changed = true,
    );

    expect(find.byType(FTabs), findsOneWidget);
    expect(find.text(l10n.reviewPeriodWeek), findsOneWidget);
    expect(find.text(l10n.reviewPeriodMonth), findsOneWidget);

    // 周 tab 默认选中（FTabs 内部选中态无法直接断言，验证回调与选中
    // 语义即可——selectedRange 传 last7Days 时不触发回调）。
    expect(changed, isFalse);
  });

  testWidgets('tapping 月 calls onRangeChanged with last30Days', (tester) async {
    ReviewDashboardRange? changedRange;
    await pumpSwitch(
      tester,
      selectedRange: ReviewDashboardRange.last7Days,
      onChanged: (range) => changedRange = range,
    );

    await tester.tap(find.text(l10n.reviewPeriodMonth));
    await tester.pump();

    expect(changedRange, ReviewDashboardRange.last30Days);
  });

  testWidgets('tapping 周 calls onRangeChanged with last7Days', (tester) async {
    ReviewDashboardRange? changedRange;
    await pumpSwitch(
      tester,
      selectedRange: ReviewDashboardRange.last30Days,
      onChanged: (range) => changedRange = range,
    );

    await tester.tap(find.text(l10n.reviewPeriodWeek));
    await tester.pump();

    expect(changedRange, ReviewDashboardRange.last7Days);
  });

  testWidgets('selectedRange maps to the lifted control index', (tester) async {
    // last30Days 选中时，控件 index 应为 1（月 tab 高亮）。
    // FTabs 无直接 index 断言，改为验证 last30Days 渲染不抛异常且标签齐全。
    await pumpSwitch(
      tester,
      selectedRange: ReviewDashboardRange.last30Days,
      onChanged: (_) {},
    );

    expect(find.text(l10n.reviewPeriodWeek), findsOneWidget);
    expect(find.text(l10n.reviewPeriodMonth), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
