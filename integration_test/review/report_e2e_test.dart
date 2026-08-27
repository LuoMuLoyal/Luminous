import 'package:integration_test/integration_test.dart';

import '../../test/review/widgets/review_fixtures.dart';
import '../support/e2e_test_helpers.dart';

/// 报告 Tab 主流程 e2e（离线/mock，不依赖后端）。
///
/// 断言 Review 首屏六状态中的核心路径与 More 入口；旧 dashboard 的
/// readiness 卡 / 综合分数 / 默认导出矩阵不再出现在主路径（Task 6-9）。
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('report signed-out shows no-event card with sign-in banner', (
    tester,
  ) async {
    await pumpOfflineApp(tester);

    await openTab(tester, '报告');

    // 未登录预览：开始观察入口隐藏，登录提示 banner 出现。
    expect(find.byKey(const Key('sign-in-hint-banner')), findsOneWidget);
    expect(find.byKey(const Key('review-no-event-card')), findsOneWidget);
    expect(
      find.byKey(const Key('review-start-observation-action')),
      findsNothing,
    );
    expect(find.text('还没有已结束的观察。'), findsOneWidget);

    // 旧 dashboard 痕迹不出现：无 readiness 锁、无综合分数、无默认导出矩阵。
    expect(find.byKey(const Key('report-readiness-card')), findsNothing);
    expect(find.byKey(const Key('report-score-hero')), findsNothing);
    expect(find.byKey(const Key('report-export-section')), findsNothing);
  });

  testWidgets(
    'report signed-in no-event offers start-observation and recent history',
    (tester) async {
      await pumpOfflineApp(
        tester,
        authSessionOverride: SignedInAuthSessionNotifier.new,
        reviewRepository: E2eReviewRepository(
          page: reviewHistoryPage([
            reviewEventItem(id: 'evt-2', title: '嗓子疼观察'),
          ]),
        ),
      );

      await openTab(tester, '报告');

      expect(find.byKey(const Key('sign-in-hint-banner')), findsNothing);
      expect(find.byKey(const Key('review-no-event-card')), findsOneWidget);
      expect(
        find.byKey(const Key('review-start-observation-action')),
        findsOneWidget,
      );
      // 最近事件按事件逐条展示。
      expect(
        find.byKey(const Key('review-history-item-evt-2')),
        findsOneWidget,
      );
      expect(find.text('嗓子疼观察'), findsOneWidget);
      expect(find.byKey(const Key('report-readiness-card')), findsNothing);
    },
  );

  testWidgets(
    'report signed-in active event renders header, four sections and history',
    (tester) async {
      await pumpOfflineApp(
        tester,
        authSessionOverride: SignedInAuthSessionNotifier.new,
        reviewRepository: E2eReviewRepository(
          current: reviewActive(),
          page: reviewHistoryPage([
            reviewEventItem(id: 'evt-2', title: '嗓子疼观察'),
          ]),
        ),
      );

      await openTab(tester, '报告');

      expect(find.byKey(const Key('review-event-header')), findsOneWidget);
      expect(find.text('感冒观察'), findsOneWidget);
      expect(find.byKey(const Key('review-check-in-action')), findsOneWidget);
      expect(
        find.byKey(const Key('review-what-happened-section')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('review-key-changes-section')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('review-completed-actions-section')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('review-next-step-section')), findsOneWidget);

      // 滚动到历史区并确认历史条目。
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.byKey(const Key('review-history-section')),
        260,
        scrollable: scrollable,
      );
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('嗓子疼观察'), findsOneWidget);

      // 旧 dashboard 痕迹不出现。
      expect(find.byKey(const Key('report-readiness-card')), findsNothing);
      expect(find.byKey(const Key('report-score-hero')), findsNothing);
      expect(find.byKey(const Key('report-export-section')), findsNothing);
    },
  );

  testWidgets('report signed-in ended event shows outcome and no check-in', (
    tester,
  ) async {
    await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      reviewRepository: E2eReviewRepository(current: reviewEnded()),
    );

    await openTab(tester, '报告');

    expect(find.byKey(const Key('review-event-header')), findsOneWidget);
    expect(find.byKey(const Key('review-check-in-action')), findsNothing);
    expect(find.byKey(const Key('review-end-event-action')), findsNothing);
    expect(find.text('已结束'), findsWidgets);
    expect(find.text('好转'), findsWidgets);
    expect(find.byKey(const Key('report-readiness-card')), findsNothing);
  });

  testWidgets('report More action opens the four-entry sheet', (tester) async {
    await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      reviewRepository: E2eReviewRepository(current: reviewActive()),
    );

    await openTab(tester, '报告');

    await tapVisible(tester, find.byKey(const Key('review-more-action')));

    // 四入口：就诊摘要 / PDF / 打印下载 / 历史报告。
    expect(find.byKey(const Key('more-visit-summary')), findsOneWidget);
    expect(find.byKey(const Key('more-pdf')), findsOneWidget);
    expect(find.byKey(const Key('more-print')), findsOneWidget);
    expect(find.byKey(const Key('more-legacy-report')), findsOneWidget);
    expect(find.text('就诊摘要'), findsOneWidget);
    expect(find.text('历史报告'), findsOneWidget);
  });

  testWidgets('report tab navigation round-trip preserves state', (
    tester,
  ) async {
    await pumpOfflineApp(tester);

    await openTab(tester, '报告');
    expect(find.byKey(const Key('review-no-event-card')), findsOneWidget);

    // Navigate away and back — state should be preserved.
    await openTab(tester, '记录');
    await settleE2e(tester);
    expect(find.byKey(const Key('record-timeline')), findsOneWidget);

    await openTab(tester, '报告');
    await settleE2e(tester);
    expect(find.byKey(const Key('review-no-event-card')), findsOneWidget);
  });
}
