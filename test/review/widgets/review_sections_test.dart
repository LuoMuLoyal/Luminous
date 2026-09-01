import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/review/domain/entities/review.dart';
import 'package:luminous/features/review/presentation/widgets/sections/completed_actions.dart';
import 'package:luminous/features/review/presentation/widgets/sections/history.dart';
import 'package:luminous/features/review/presentation/widgets/sections/key_changes.dart';
import 'package:luminous/features/review/presentation/widgets/sections/next_step.dart';
import 'package:luminous/features/review/presentation/widgets/sections/what_happened.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';
import 'review_fixtures.dart';

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  Future<void> pumpSection(WidgetTester tester, Widget section) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ProviderScope(
        child: TestForuiApp(
          home: Scaffold(body: SingleChildScrollView(child: section)),
        ),
      ),
    );
    await tester.pump();
  }

  group('WhatHappenedSection', () {
    testWidgets('renders observed facts from the health_event code', (
      tester,
    ) async {
      await pumpSection(
        tester,
        WhatHappenedSection(section: reviewActive().sections.whatHappened),
      );

      expect(find.text(l10n.reviewReviewSectionWhatHappened), findsOneWidget);
      expect(find.text('记录了 5 条症状'), findsOneWidget);
      expect(find.text('确认了 3 次结果'), findsOneWidget);
      expect(find.textContaining('至今'), findsOneWidget);
    });

    testWidgets('unknown state shows the localized reason without a score', (
      tester,
    ) async {
      await pumpSection(
        tester,
        WhatHappenedSection(
          section: reviewUnknownSection(
            ReviewSectionReasonCodes.noObservations,
          ),
        ),
      );

      expect(find.text(l10n.reviewReviewSectionWhatHappened), findsOneWidget);
      expect(find.text(l10n.reviewReviewReasonNoObservations), findsOneWidget);
      expect(find.textContaining('需关注'), findsNothing);
      expect(find.textContaining('分'), findsNothing);
    });

    testWidgets('unrecognized facts code degrades to the generic reason', (
      tester,
    ) async {
      await pumpSection(
        tester,
        WhatHappenedSection(
          section: reviewFactsSection('some_future_code', {'anything': 1}),
        ),
      );

      expect(find.text(l10n.reviewReviewReasonUnknown), findsOneWidget);
    });

    testWidgets('renders the triggering record row after the window row', (
      tester,
    ) async {
      await pumpSection(
        tester,
        WhatHappenedSection(
          section: reviewFactsSection('health_event', {
            'kind': 'symptom',
            'title': '感冒观察',
            'startedAt': '2026-08-01T00:00:00.000Z',
            'endedAt': null,
            'medicineIds': <String>[],
            'symptomRecordCount': 1,
            'checkInCount': 0,
            'reasonRecordTitle': '头晕',
          }),
        ),
      );

      expect(find.text('由记录触发：头晕'), findsOneWidget);
      // 触发记录行位于窗口行之后、症状计数之前。
      final windowDy = tester.getTopLeft(find.textContaining('至今')).dy;
      final reasonDy = tester.getTopLeft(find.text('由记录触发：头晕')).dy;
      final symptomDy = tester
          .getTopLeft(find.text(l10n.reviewReviewWhatHappenedSymptomCount(1)))
          .dy;
      expect(reasonDy, greaterThan(windowDy));
      expect(reasonDy, lessThan(symptomDy));
    });

    testWidgets('omits the triggering record row when the argument is absent', (
      tester,
    ) async {
      await pumpSection(
        tester,
        WhatHappenedSection(
          section: reviewFactsSection('health_event', {
            'kind': 'symptom',
            'title': '感冒观察',
            'startedAt': '2026-08-01T00:00:00.000Z',
            'endedAt': null,
            'medicineIds': <String>[],
            'symptomRecordCount': 1,
            'checkInCount': 0,
          }),
        ),
      );

      expect(find.textContaining('由记录触发'), findsNothing);
    });
  });

  group('KeyChangesSection', () {
    testWidgets('renders outcome, water and sleep trend rows', (tester) async {
      await pumpSection(
        tester,
        KeyChangesSection(section: reviewActive().sections.keyChanges),
      );

      expect(find.text(l10n.reviewReviewSectionKeyChanges), findsOneWidget);
      expect(find.text(l10n.reviewReviewChangeOutcomeTitle), findsOneWidget);
      expect(find.text('从「加重」变为「好转」，共确认 6 次'), findsOneWidget);
      expect(find.text(l10n.reviewReviewChangeWaterTitle), findsOneWidget);
      expect(find.text(l10n.reviewReviewChangeDirectionUp), findsOneWidget);
      expect(find.text('1200 毫升 → 1800 毫升，观察 8 天'), findsOneWidget);
      expect(find.text(l10n.reviewReviewChangeSleepTitle), findsNothing);
    });

    testWidgets('unknown state shows the coverage reason', (tester) async {
      await pumpSection(
        tester,
        KeyChangesSection(
          section: reviewUnknownSection(
            ReviewSectionReasonCodes.insufficientCoverage,
          ),
        ),
      );

      expect(
        find.text(l10n.reviewReviewReasonInsufficientCoverage),
        findsOneWidget,
      );
      expect(find.textContaining('需关注'), findsNothing);
      // 覆盖不足时后端不发 observed_changes，客户端不渲染任何趋势行
      // （包括结果变化与单维数值趋势）。
      expect(find.text(l10n.reviewReviewChangeOutcomeTitle), findsNothing);
      expect(find.text(l10n.reviewReviewChangeWaterTitle), findsNothing);
      expect(find.text(l10n.reviewReviewChangeSleepTitle), findsNothing);
    });

    testWidgets('missing direction shows unknown instead of flat', (
      tester,
    ) async {
      await pumpSection(
        tester,
        KeyChangesSection(
          section: reviewFactsSection('observed_changes', {
            'water': {
              'direction': null,
              'firstValue': 1200,
              'lastValue': 1300,
              'firstDate': '2026-08-02',
              'lastDate': '2026-08-03',
              'observedDays': 2,
            },
          }),
        ),
      );

      expect(
        find.text(l10n.reviewReviewChangeDirectionUnknown),
        findsOneWidget,
      );
      expect(find.text(l10n.reviewReviewChangeDirectionFlat), findsNothing);
    });
  });

  group('CompletedActionsSection', () {
    testWidgets('renders dose slot counts and check-in records', (
      tester,
    ) async {
      await pumpSection(
        tester,
        CompletedActionsSection(
          section: reviewActive().sections.completedActions,
        ),
      );

      expect(
        find.text(l10n.reviewReviewSectionCompletedActions),
        findsOneWidget,
      );
      expect(find.text(l10n.reviewReviewDoseSectionTitle), findsOneWidget);
      expect(find.text('已确认服药 9 次'), findsOneWidget);
      expect(find.text('跳过 2 次'), findsOneWidget);
      expect(find.text('未确认 1 次'), findsOneWidget);
      // 契约日期经 reviewShortDateLabel 本地化，与 header/history 一致。
      expect(find.text('8月2日 · 加重'), findsOneWidget);
      expect(find.text('8月3日 · 差不多'), findsOneWidget);
    });

    testWidgets('unknown state shows the completed-actions reason', (
      tester,
    ) async {
      await pumpSection(
        tester,
        CompletedActionsSection(
          section: reviewUnknownSection(
            ReviewSectionReasonCodes.noCompletedActions,
          ),
        ),
      );

      expect(
        find.text(l10n.reviewReviewReasonNoCompletedActions),
        findsOneWidget,
      );
    });
  });

  group('NextStepSection', () {
    testWidgets('active event without today check-in prompts a check-in', (
      tester,
    ) async {
      await pumpSection(
        tester,
        NextStepSection(section: reviewActive().sections.nextStep),
      );

      expect(find.text(l10n.reviewReviewSectionNextStep), findsOneWidget);
      expect(find.text(l10n.reviewReviewNextStepCheckInPrompt), findsOneWidget);
    });

    testWidgets('active event with today check-in confirms it', (tester) async {
      await pumpSection(
        tester,
        NextStepSection(
          section: reviewFactsSection('active_check_in', {
            'hasTodayCheckIn': true,
          }),
        ),
      );

      expect(
        find.text(l10n.reviewReviewNextStepCheckInDonePrompt),
        findsOneWidget,
      );
    });

    testWidgets('ended event shows the confirmed outcome', (tester) async {
      await pumpSection(
        tester,
        NextStepSection(
          section: reviewFactsSection('event_ended', {'outcome': 'worsened'}),
        ),
      );

      expect(find.text('这段观察已结束，结果：加重'), findsOneWidget);
    });

    testWidgets('renders structured red flags without generated copy', (
      tester,
    ) async {
      await pumpSection(
        tester,
        NextStepSection(
          section: reviewFactsSection('active_check_in', {
            'hasTodayCheckIn': false,
            'redFlags': [
              {
                'rule': 'severeAllergy',
                'medicineName': '阿莫西林',
                'relatedLabel': '青霉素',
              },
              {'rule': 'informationGap', 'medicineName': '布洛芬'},
              {'rule': 'future_rule', 'medicineName': '对乙酰氨基酚'},
            ],
          }),
        ),
      );

      expect(find.text(l10n.reviewReviewRedFlagSectionTitle), findsOneWidget);
      expect(find.text('「阿莫西林」可能含有严重过敏成分「青霉素」'), findsOneWidget);
      expect(find.text('「布洛芬」缺少关键用药信息'), findsOneWidget);
      // 契约外规则按通用文案展示，不生成任何泛化建议。
      expect(find.text('「对乙酰氨基酚」存在安全提醒'), findsOneWidget);
    });

    testWidgets('unknown state shows the reason', (tester) async {
      await pumpSection(
        tester,
        NextStepSection(
          section: reviewUnknownSection(
            ReviewSectionReasonCodes.insufficientCoverage,
          ),
        ),
      );

      expect(
        find.text(l10n.reviewReviewReasonInsufficientCoverage),
        findsOneWidget,
      );
    });
  });

  group('ReviewHistorySection', () {
    testWidgets('lists events most recent first, by event not by month', (
      tester,
    ) async {
      await pumpSection(
        tester,
        ReviewHistorySection(
          history: AsyncValue<ReviewEventPage>.data(
            reviewHistoryPage([
              reviewEventItem(id: 'evt-2', title: '嗓子疼观察'),
              reviewEventItem(
                id: 'evt-1',
                title: '头痛观察',
                outcome: ReviewEventOutcome.worsened,
              ),
            ]),
          ),
        ),
      );

      expect(find.text(l10n.reviewReviewHistoryTitle), findsOneWidget);
      expect(find.text('嗓子疼观察'), findsOneWidget);
      expect(find.text('头痛观察'), findsOneWidget);
      final firstDy = tester
          .getTopLeft(find.byKey(const Key('review-history-item-evt-2')))
          .dy;
      final secondDy = tester
          .getTopLeft(find.byKey(const Key('review-history-item-evt-1')))
          .dy;
      expect(firstDy, lessThan(secondDy));
    });

    testWidgets('shows the empty explanation when there are no events', (
      tester,
    ) async {
      await pumpSection(
        tester,
        const ReviewHistorySection(
          history: AsyncValue<ReviewEventPage>.data(
            ReviewEventPage(items: [], total: 0),
          ),
        ),
      );

      expect(find.text(l10n.reviewReviewHistoryEmpty), findsOneWidget);
    });

    testWidgets('shows a progress placeholder while history loads', (
      tester,
    ) async {
      await pumpSection(
        tester,
        const ReviewHistorySection(
          history: AsyncValue<ReviewEventPage>.loading(),
        ),
      );

      expect(find.byType(FProgress), findsOneWidget);
    });

    testWidgets('shows a lightweight failure line with an inline retry', (
      tester,
    ) async {
      var retryTapped = false;
      await pumpSection(
        tester,
        ReviewHistorySection(
          history: AsyncValue<ReviewEventPage>.error(
            Exception('boom'),
            StackTrace.current,
          ),
          onRetry: () => retryTapped = true,
        ),
      );

      expect(find.text(l10n.reviewReviewHistoryLoadFailed), findsOneWidget);
      final retryButton = find.byKey(const Key('review-history-retry'));
      expect(retryButton, findsOneWidget);
      await tester.tap(retryButton);
      expect(retryTapped, isTrue);
      await tester.pumpAndSettle();
    });

    testWidgets('renders the status filter with all selected by default', (
      tester,
    ) async {
      await pumpSection(
        tester,
        const ReviewHistorySection(
          history: AsyncValue<ReviewEventPage>.data(
            ReviewEventPage(items: [], total: 0),
          ),
        ),
      );

      expect(find.text(l10n.reviewReviewHistoryFilterAll), findsOneWidget);
      expect(find.text(l10n.reviewReviewStatusActive), findsOneWidget);
      expect(find.text(l10n.reviewReviewStatusEnded), findsOneWidget);
      // 默认选中「全部」：all chip 选中，其余未选中。
      expect(_filterChipSelected(tester, 'all'), isTrue);
      expect(_filterChipSelected(tester, 'active'), isFalse);
      expect(_filterChipSelected(tester, 'ended'), isFalse);
    });

    testWidgets('marks the selected filter as primary', (tester) async {
      await pumpSection(
        tester,
        const ReviewHistorySection(
          history: AsyncValue<ReviewEventPage>.data(
            ReviewEventPage(items: [], total: 0),
          ),
          selectedStatus: ReviewEventStatus.ended,
        ),
      );

      expect(_filterChipSelected(tester, 'ended'), isTrue);
      expect(_filterChipSelected(tester, 'all'), isFalse);
      expect(_filterChipSelected(tester, 'active'), isFalse);
    });

    testWidgets('tapping a filter emits the selected status', (tester) async {
      ReviewEventStatus? selected;
      await pumpSection(
        tester,
        ReviewHistorySection(
          history: const AsyncValue<ReviewEventPage>.data(
            ReviewEventPage(items: [], total: 0),
          ),
          selectedStatus: null,
          onStatusChanged: (status) => selected = status,
        ),
      );

      await tester.tap(find.byKey(const Key('review-history-filter-active')));
      await tester.pumpAndSettle();
      expect(selected, ReviewEventStatus.active);

      await tester.tap(find.byKey(const Key('review-history-filter-ended')));
      await tester.pumpAndSettle();
      expect(selected, ReviewEventStatus.ended);
    });

    testWidgets('tapping a history row emits the event through onEventTap', (
      tester,
    ) async {
      ReviewEvent? tapped;
      await pumpSection(
        tester,
        ReviewHistorySection(
          history: AsyncValue<ReviewEventPage>.data(
            reviewHistoryPage([reviewEventItem(id: 'evt-1', title: '头痛观察')]),
          ),
          onEventTap: (event) => tapped = event,
        ),
      );

      await tester.tap(find.byKey(const Key('review-history-item-evt-1')));
      await tester.pumpAndSettle();
      expect(tapped?.id, 'evt-1');
    });

    testWidgets('history rows stay read-only without onEventTap', (
      tester,
    ) async {
      await pumpSection(
        tester,
        ReviewHistorySection(
          history: AsyncValue<ReviewEventPage>.data(
            reviewHistoryPage([reviewEventItem(id: 'evt-1', title: '头痛观察')]),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('review-history-item-evt-1')));
      await tester.pumpAndSettle();
      // 不可点时历史行不应被包成 FTappable（筛选行自己的 chip 除外），
      // 也不应抛错或触发任何动作。
      expect(
        find.ancestor(
          of: find.byKey(const Key('review-history-item-evt-1')),
          matching: find.byType(FTappable),
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('auto-loads the next page when the trigger becomes visible', (
      tester,
    ) async {
      final secondPage = Completer<ReviewEventPage>();
      await pumpSection(
        tester,
        ReviewHistorySection(
          history: const AsyncValue<ReviewEventPage>.data(
            ReviewEventPage(
              items: [
                ReviewEvent(
                  id: 'evt-1',
                  kind: ReviewEventKind.symptom,
                  title: '头痛观察',
                  status: ReviewEventStatus.ended,
                  startedAt: '2026-08-01T00:00:00.000Z',
                  endedAt: '2026-08-10T00:00:00.000Z',
                  outcome: ReviewEventOutcome.improved,
                  currentMedicineIds: [],
                ),
              ],
              total: 3,
              nextCursor: 'cursor-1',
            ),
          ),
          onLoadMore: (cursor) async {
            expect(cursor, 'cursor-1');
            return secondPage.future;
          },
        ),
      );

      // 触发器在首帧被绘制（SingleChildScrollView 下始终可见），帧末
      // 自动发起加载；下一页未返回前不出现追加内容。
      await tester.pump();
      expect(find.text('嗓子疼观察'), findsNothing);

      secondPage.complete(
        ReviewEventPage(
          items: [reviewEventItem(id: 'evt-2', title: '嗓子疼观察')],
          total: 3,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('头痛观察'), findsOneWidget);
      expect(find.text('嗓子疼观察'), findsOneWidget);
      // 下一页无 nextCursor，触发器移除，不再继续加载。
      expect(find.text(l10n.reviewReviewHistoryLoadMoreFailed), findsNothing);
    });

    testWidgets('does not auto-load when nextCursor is null', (tester) async {
      var loadMoreCalled = false;
      await pumpSection(
        tester,
        ReviewHistorySection(
          history: AsyncValue<ReviewEventPage>.data(
            reviewHistoryPage([reviewEventItem(id: 'evt-1', title: '头痛观察')]),
          ),
          onLoadMore: (_) async {
            loadMoreCalled = true;
            return const ReviewEventPage(items: [], total: 1);
          },
        ),
      );

      await tester.pumpAndSettle();
      // 无 nextCursor：不渲染触发器，也不发起加载。
      expect(loadMoreCalled, isFalse);
    });

    testWidgets('does not auto-load without onLoadMore callback', (
      tester,
    ) async {
      await pumpSection(
        tester,
        const ReviewHistorySection(
          history: AsyncValue<ReviewEventPage>.data(
            ReviewEventPage(items: [], total: 25, nextCursor: 'cursor-abc'),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text(l10n.reviewReviewHistoryLoadMoreFailed), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows manual retry after auto-load failure', (tester) async {
      await pumpSection(
        tester,
        ReviewHistorySection(
          history: const AsyncValue<ReviewEventPage>.data(
            ReviewEventPage(
              items: [
                ReviewEvent(
                  id: 'evt-1',
                  kind: ReviewEventKind.symptom,
                  title: '头痛观察',
                  status: ReviewEventStatus.ended,
                  startedAt: '2026-08-01T00:00:00.000Z',
                  endedAt: '2026-08-10T00:00:00.000Z',
                  outcome: ReviewEventOutcome.improved,
                  currentMedicineIds: [],
                ),
              ],
              total: 3,
              nextCursor: 'cursor-1',
            ),
          ),
          onLoadMore: (_) async => throw Exception('network error'),
        ),
      );

      // 首帧自动触发加载，失败后转为错误行 + 手动重试（不自动重试，
      // 避免错误循环）。
      await tester.pumpAndSettle();

      expect(find.text(l10n.reviewReviewHistoryLoadMoreFailed), findsOneWidget);
      // 重试按钮使用独立 key（自动触发器无按钮）。
      final retryButton = find.byKey(
        const Key('review-history-load-more-retry'),
      );
      expect(retryButton, findsOneWidget);
      expect(
        find.descendant(
          of: retryButton,
          matching: find.text(l10n.todayRetryAction),
        ),
        findsOneWidget,
      );
    });

    testWidgets('resets appended items when status filter changes', (
      tester,
    ) async {
      // 用 StatefulBuilder 让测试能在同一个 widget instance 上触发重建。
      var status = ReviewEventStatus.ended;
      var nextCursor = 'cursor-1';
      late StateSetter testSetState;

      await pumpSection(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            testSetState = setState;
            return ReviewHistorySection(
              history: AsyncValue<ReviewEventPage>.data(
                ReviewEventPage(
                  items: [
                    reviewEventItem(
                      id: 'evt-1',
                      title: '头痛观察',
                      status: ReviewEventStatus.ended,
                    ),
                  ],
                  total: 3,
                  nextCursor: nextCursor,
                ),
              ),
              selectedStatus: status,
              onLoadMore: (cursor) async => ReviewEventPage(
                // cursor-1（切换前）返回 evt-2；切换重置后触发器自动重载
                // cursor-2 返回空页，避免把切换前的追加内容又拉回来。
                items: cursor == 'cursor-1'
                    ? [reviewEventItem(id: 'evt-2', title: '嗓子疼观察')]
                    : const [],
                total: 3,
              ),
            );
          },
        ),
      );

      // 加载第二页（滚动到底自动触发）。
      await tester.pumpAndSettle();
      expect(find.text('嗓子疼观察'), findsOneWidget);

      // 筛选切换 + 首页 nextCursor 变化，触发 _syncFromFirstPage 重置。
      testSetState(() {
        status = ReviewEventStatus.active;
        nextCursor = 'cursor-2';
      });
      await tester.pumpAndSettle();

      // 筛选切换后追加的 evt-2 应该消失。
      expect(find.text('嗓子疼观察'), findsNothing);
    });
  });
}

/// 读取历史筛选 chip 的选中态（Semantics.selected）。
bool _filterChipSelected(WidgetTester tester, String key) {
  final semantics = tester.widget<Semantics>(
    find.byKey(Key('review-history-filter-$key')),
  );
  return semantics.properties.selected!;
}
